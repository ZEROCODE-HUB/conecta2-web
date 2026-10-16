// Excel export helper for the TamizajeDataTable widget.

import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio
    hide Column, Row;

// Import condicional: en web usa dart:html, en móvil/desktop usa un stub.
import 'excel_download_stub.dart'
    if (dart.library.html) 'excel_download_web.dart';

import '../data/substance_data.dart';

void _aplicarEstiloBase(xlsio.Style style) {
  style.hAlign = xlsio.HAlignType.center;
  style.vAlign = xlsio.VAlignType.center;
  style.borders.all.lineStyle = xlsio.LineStyle.thin;
  style.borders.all.color = '#FF000000';
}

Future<void> exportarTamizajeAExcel({
  required BuildContext context,
  required String? tamizajeNombre,
  required List<Map<String, dynamic>> datosAExportar,
  required Map<String, bool> columnasVisibles,
  required List<Map<String, String>> ordenColumnas,
}) async {
  if (datosAExportar.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No hay datos para exportar'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generando Excel con colores...'),
            ],
          ),
        );
      },
    );

    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    final headersVisibles = ordenColumnas
        .where((col) => columnasVisibles[col['clave']] ?? true)
        .map((col) => col['label']!)
        .toList();

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final xlsio.Style headerStyle = workbook.styles.add('Header_$timestamp');
    headerStyle.backColor = '#265295';
    headerStyle.fontColor = '#FFFFFF';
    headerStyle.bold = true;
    headerStyle.hAlign = xlsio.HAlignType.center;
    headerStyle.vAlign = xlsio.VAlignType.center;
    headerStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
    headerStyle.borders.all.color = '#FF000000';

    final xlsio.Style estiloSinAlarma =
        workbook.styles.add('SinAlarma_$timestamp');
    estiloSinAlarma.backColor = '#F0F0F0';
    estiloSinAlarma.fontColor = '#000000';
    _aplicarEstiloBase(estiloSinAlarma);

    final xlsio.Style estiloBajo = workbook.styles.add('Bajo_$timestamp');
    estiloBajo.backColor = '#D1EDC5';
    _aplicarEstiloBase(estiloBajo);

    final xlsio.Style estiloModerado =
        workbook.styles.add('Moderado_$timestamp');
    estiloModerado.backColor = '#F5E09D';
    _aplicarEstiloBase(estiloModerado);

    final xlsio.Style estiloAlto = workbook.styles.add('Alto_$timestamp');
    estiloAlto.backColor = '#FFCDCD';
    _aplicarEstiloBase(estiloAlto);

    final xlsio.Style estiloNormal = workbook.styles.add('Normal_$timestamp');
    estiloNormal.backColor = '#FFFFFF';
    estiloNormal.hAlign = xlsio.HAlignType.center;
    estiloNormal.vAlign = xlsio.VAlignType.center;
    estiloNormal.borders.all.lineStyle = xlsio.LineStyle.thin;
    estiloNormal.borders.all.color = '#FFCCCCCC';
    estiloNormal.bold = false;

    final Map<String, xlsio.Style> riesgoStyles = {
      'Sin alarma': estiloSinAlarma,
      'Sin alerta': estiloSinAlarma,
      'Bajo': estiloBajo,
      'Moderado': estiloModerado,
      'Alto': estiloAlto,
    };

    for (int i = 0; i < headersVisibles.length; i++) {
      final xlsio.Range headerCell = sheet.getRangeByIndex(1, i + 1);
      headerCell.setText(headersVisibles[i]);
      headerCell.cellStyle = headerStyle;
    }

    for (int i = 0; i < datosAExportar.length; i++) {
      final data = datosAExportar[i];
      int colIndex = 1;

      for (final col in ordenColumnas) {
        final clave = col['clave']!;
        if (columnasVisibles[clave] ?? true) {
          final xlsio.Range cell = sheet.getRangeByIndex(i + 2, colIndex);
          final dynamic value = data[clave] ?? '';

          if (value is num) {
            cell.setNumber(value.toDouble());
          } else {
            cell.setText(value.toString());
          }

          if (clave.endsWith('_RIESGO')) {
            final nivelRiesgo = value.toString();
            cell.cellStyle = riesgoStyles[nivelRiesgo] ?? estiloNormal;
          } else if (value.toString() == 'Sí') {
            cell.cellStyle = estiloAlto;
          } else if (value.toString() == 'No') {
            cell.cellStyle = estiloSinAlarma;
          } else {
            cell.cellStyle = estiloNormal;
          }

          colIndex++;
        }
      }
    }

    for (int i = 1; i <= headersVisibles.length; i++) {
      sheet.autoFitColumn(i);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final fileName =
        'Tamizaje_${tamizajeNombre}_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    if (kIsWeb) {
      descargarExcelWeb(bytes, fileName);
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles([XFile(file.path)],
          text: 'Exportación de tamizaje $tamizajeNombre');
    }

    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Excel con colores generado: $fileName (${datosAExportar.length} registros)'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
