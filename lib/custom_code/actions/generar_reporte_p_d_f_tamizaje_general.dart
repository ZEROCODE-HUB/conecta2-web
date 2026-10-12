// Automatic FlutterFlow imports
import '/tamizajes/shared/assist_utils.dart'
    show esEncuestaAssist, evaluarAssist;
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future generarReportePDFTamizajeGeneral(
  String? colegio,
  String? nivelRiesgo,
  String? sustancia,
  String? tamizaje,
) async {
  try {
    // Normalizar parametros
    final colegioFiltro = _normalizarFiltro(colegio);
    final nivelRiesgoFiltro = _normalizarFiltro(nivelRiesgo);
    final sustanciaFiltro = _normalizarFiltro(sustancia);
    final tamizajeFiltro = _normalizarFiltro(tamizaje);

    print('=== GENERANDO REPORTE GENERAL (ALERTAS) ===');
    print('Colegio: ${colegioFiltro ?? "TODOS"}');
    print('Nivel Riesgo: ${nivelRiesgoFiltro ?? "TODOS"}');
    print('Sustancia: ${sustanciaFiltro ?? "TODAS"}');
    print('Tamizaje: ${tamizajeFiltro ?? "TODOS"}');
    print('============================================');

    // Obtener encuestas
    Query<Map<String, dynamic>> encuestasQuery = FirebaseFirestore.instance
        .collection('Encuestas')
        .where('tipo', isEqualTo: 'Tamizajes')
        .where('Publicado', isEqualTo: true);

    if (tamizajeFiltro != null) {
      encuestasQuery =
          encuestasQuery.where('titulo', isEqualTo: tamizajeFiltro);
    }

    final encuestasSnapshot = await encuestasQuery.get();

    if (encuestasSnapshot.docs.isEmpty) {
      throw Exception('No se encontraron tamizajes publicados');
    }

    print('Total encuestas encontradas: ${encuestasSnapshot.docs.length}');

    List<Map<String, dynamic>> datosGenerales = [];

    for (var encuestaDoc in encuestasSnapshot.docs) {
      final encuestaData = encuestaDoc.data();
      final encuestaId = encuestaDoc.id;
      final tituloTamizaje = encuestaData['titulo'] ?? 'Sin titulo';
      final alertas = encuestaData['alertas'] as List<dynamic>? ?? [];
      final preguntasEncuesta =
          encuestaData['Preguntas'] as List<dynamic>? ?? [];

      // Este reporte es por sustancia: solo aplica a los ASSIST.
      if (!esEncuestaAssist(
          (encuestaData['categoria'] ?? '').toString(), '$tituloTamizaje')) {
        continue;
      }

      print('\nProcesando tamizaje: $tituloTamizaje');

      final respuestasSnapshot = await FirebaseFirestore.instance
          .collection('Encuestas')
          .doc(encuestaId)
          .collection('Respuestas')
          .get();

      print('  Respuestas encontradas: ${respuestasSnapshot.docs.length}');

      Map<String, Map<String, dynamic>> estadisticasPorSustancia = {};
      Set<String> usuariosUnicos = {};
      Map<String, int> distribucionPorColegio = {};
      int totalAlertas = 0;

      for (var respuestaDoc in respuestasSnapshot.docs) {
        final respuestaData = respuestaDoc.data();
        final userRef = respuestaData['User_respuesta'] as DocumentReference?;

        if (userRef == null) continue;

        final userDoc = await userRef.get();
        if (!userDoc.exists) continue;

        final userData = userDoc.data() as Map<String, dynamic>;
        final colegioUsuario = userData['colegio'] as String? ?? '';

        // FILTRO 1: Por colegio
        if (colegioFiltro != null &&
            colegioUsuario.isNotEmpty &&
            !colegioUsuario
                .toUpperCase()
                .contains(colegioFiltro.toUpperCase())) {
          continue;
        }

        final userId = userRef.id;
        usuariosUnicos.add(userId);
        if (colegioUsuario.isNotEmpty) {
          distribucionPorColegio[colegioUsuario] =
              (distribucionPorColegio[colegioUsuario] ?? 0) + 1;
        }

        if (respuestaData['invalidado'] == true) continue;

        // Puntaje y nivel por la sustancia asignada a cada pregunta (acepta
        // 'Tamizaje (Sustancias)' y el legacy 'Tamizaje'), con la regla única
        // de nivel (rangos de la encuesta o cortes OMS).
        final resultadoAssist = evaluarAssist(
          preguntas: preguntasEncuesta,
          test: respuestaData['test'] as List<dynamic>? ?? [],
          alertas: alertas,
        );

        // Evaluar cada sustancia y CONTAR ALERTAS
        for (final entrada in resultadoAssist.porSustancia.entries) {
          final sustanciaItem = entrada.key;
          final puntaje = entrada.value.puntaje.toDouble();
          final nivel = entrada.value.nivel;

          // FILTRO 2: Por sustancia
          if (sustanciaFiltro != null &&
              !sustanciaItem
                  .toUpperCase()
                  .contains(sustanciaFiltro.toUpperCase())) {
            continue;
          }

          // FILTRO 3: Por nivel de riesgo
          if (nivelRiesgoFiltro != null &&
              nivel.toUpperCase() != nivelRiesgoFiltro.toUpperCase()) {
            continue;
          }

          // Contar esta alerta
          totalAlertas++;

          // Inicializar estadisticas si no existen
          if (!estadisticasPorSustancia.containsKey(sustanciaItem)) {
            estadisticasPorSustancia[sustanciaItem] = {
              'total': 0,
              'bajo': 0,
              'moderado': 0,
              'alto': 0,
              'sumaPuntajes': 0.0,
            };
          }

          estadisticasPorSustancia[sustanciaItem]!['total'] =
              (estadisticasPorSustancia[sustanciaItem]!['total'] as int) + 1;
          estadisticasPorSustancia[sustanciaItem]!['sumaPuntajes'] =
              (estadisticasPorSustancia[sustanciaItem]!['sumaPuntajes']
                      as double) +
                  puntaje;

          switch (nivel.toUpperCase()) {
            case 'BAJO':
              estadisticasPorSustancia[sustanciaItem]!['bajo'] =
                  (estadisticasPorSustancia[sustanciaItem]!['bajo'] as int) + 1;
              break;
            case 'MODERADO':
              estadisticasPorSustancia[sustanciaItem]!['moderado'] =
                  (estadisticasPorSustancia[sustanciaItem]!['moderado']
                          as int) +
                      1;
              break;
            case 'ALTO':
              estadisticasPorSustancia[sustanciaItem]!['alto'] =
                  (estadisticasPorSustancia[sustanciaItem]!['alto'] as int) + 1;
              break;
          }
        }
      }

      print('  Total alertas contadas: $totalAlertas');
      print('  Usuarios únicos: ${usuariosUnicos.length}');

      if (estadisticasPorSustancia.isNotEmpty) {
        datosGenerales.add({
          'titulo': tituloTamizaje,
          'totalUsuarios': usuariosUnicos.length,
          'totalAlertas': totalAlertas,
          'estadisticas': estadisticasPorSustancia,
          'distribucionColegios': distribucionPorColegio,
        });
      }
    }

    if (datosGenerales.isEmpty) {
      print('No se encontraron datos, generando reporte vacío');
      final pdf = await _crearPDFVacio(
          colegioFiltro, nivelRiesgoFiltro, sustanciaFiltro, tamizajeFiltro);
      await _mostrarPDFGeneral(pdf);
      return 'success_no_data';
    }

    // Generar PDF
    final pdf = await _crearPDFGeneral(
      datosGenerales,
      colegioFiltro,
      nivelRiesgoFiltro,
      sustanciaFiltro,
      tamizajeFiltro,
    );

    await _mostrarPDFGeneral(pdf);

    print('PDF general generado exitosamente');
    return 'success';
  } catch (e) {
    print('Error al generar el PDF general: $e');
    throw Exception('Error al generar el PDF general: $e');
  }
}

String? _normalizarFiltro(String? filtro) {
  if (filtro == null || filtro.trim().isEmpty) return null;
  final normalized = filtro.trim().toUpperCase();
  if (normalized == 'TODOS' || normalized == 'TODAS') return null;
  return filtro.trim();
}

Future<Uint8List> _crearPDFVacio(
  String? colegio,
  String? nivelRiesgo,
  String? sustancia,
  String? tamizaje,
) async {
  final pdf = pw.Document();

  DateTime ahora = DateTime.now();
  String fecha =
      '${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year}';
  String hora =
      '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(2.0 * PdfPageFormat.cm),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeaderGeneral(fecha, hora),
            pw.SizedBox(height: 20),
            _buildTitleGeneral(),
            pw.SizedBox(height: 15),
            _buildFiltrosAplicados(colegio, nivelRiesgo, sustancia, tamizaje),
            pw.SizedBox(height: 40),
            pw.Center(
              child: pw.Container(
                padding: pw.EdgeInsets.all(30),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange50,
                  border: pw.Border.all(color: PdfColors.orange700, width: 2),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  children: [
                    pw.Icon(
                      pw.IconData(0xe88e),
                      size: 50,
                      color: PdfColors.orange700,
                    ),
                    pw.SizedBox(height: 15),
                    pw.Text(
                      'NO SE ENCONTRARON DATOS',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange900,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'No hay registros que coincidan con los filtros aplicados.',
                      style: pw.TextStyle(fontSize: 11),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Intente modificar los filtros para obtener resultados.',
                      style:
                          pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            pw.Spacer(),
            _buildFirmasGeneral(fecha),
          ],
        );
      },
    ),
  );

  return await pdf.save();
}

Future<Uint8List> _crearPDFGeneral(
  List<Map<String, dynamic>> datosGenerales,
  String? colegio,
  String? nivelRiesgo,
  String? sustancia,
  String? tamizaje,
) async {
  final pdf = pw.Document();

  DateTime ahora = DateTime.now();
  String fecha =
      '${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year}';
  String hora =
      '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(2.0 * PdfPageFormat.cm),
      build: (pw.Context context) {
        List<pw.Widget> contenido = [];

        contenido.add(_buildHeaderGeneral(fecha, hora));
        contenido.add(pw.SizedBox(height: 20));
        contenido.add(_buildTitleGeneral());
        contenido.add(pw.SizedBox(height: 15));
        contenido.add(
            _buildFiltrosAplicados(colegio, nivelRiesgo, sustancia, tamizaje));
        contenido.add(pw.SizedBox(height: 20));

        for (var datos in datosGenerales) {
          contenido.add(_buildResumenTamizajeGeneral(datos));
          contenido.add(pw.SizedBox(height: 15));
        }

        contenido.add(pw.SizedBox(height: 20));
        contenido.add(_buildFirmasGeneral(fecha));

        return contenido;
      },
    ),
  );

  return await pdf.save();
}

pw.Widget _buildHeaderGeneral(String fecha, String hora) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Text(
        'CONECTA2 - REPORTE GENERAL DE ALERTAS',
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
        textAlign: pw.TextAlign.center,
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Fecha: $fecha',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Hora: $hora',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
      pw.Divider(thickness: 1.5),
    ],
  );
}

pw.Widget _buildTitleGeneral() {
  return pw.Container(
    width: double.infinity,
    padding: pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.blue50,
      border: pw.Border.all(color: PdfColors.blue700),
    ),
    child: pw.Text(
      'REPORTE ESTADISTICO DE ALERTAS POR TAMIZAJE',
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.Widget _buildFiltrosAplicados(
    String? colegio, String? nivelRiesgo, String? sustancia, String? tamizaje) {
  List<String> filtros = [];
  if (colegio != null) {
    filtros.add('Institución: $colegio');
  }
  if (nivelRiesgo != null) {
    filtros.add('Nivel de Riesgo: $nivelRiesgo');
  }
  if (sustancia != null) {
    filtros.add('Sustancia: $sustancia');
  }
  if (tamizaje != null) {
    filtros.add('Tamizaje: $tamizaje');
  }

  if (filtros.isEmpty) {
    filtros.add('Sin filtros - Mostrando todos los datos');
  }

  return pw.Container(
    width: double.infinity,
    padding: pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      border: pw.Border.all(color: PdfColors.grey400),
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'FILTROS APLICADOS:',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        ...filtros.map((filtro) => pw.Container(
              margin: pw.EdgeInsets.only(bottom: 3),
              child: pw.Row(
                children: [
                  pw.Text('• ', style: pw.TextStyle(fontSize: 9)),
                  pw.Text(filtro, style: pw.TextStyle(fontSize: 9)),
                ],
              ),
            )),
      ],
    ),
  );
}

pw.Widget _buildResumenTamizajeGeneral(Map<String, dynamic> datos) {
  final titulo = datos['titulo'] as String;
  final totalUsuarios = datos['totalUsuarios'] as int;
  final totalAlertas = datos['totalAlertas'] as int;
  final estadisticas =
      datos['estadisticas'] as Map<String, Map<String, dynamic>>;
  final distribucionColegios =
      datos['distribucionColegios'] as Map<String, int>;

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Titulo del tamizaje
      pw.Container(
        width: double.infinity,
        padding: pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.blue100,
          border: pw.Border.all(color: PdfColors.blue700),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                titulo,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ),
            pw.Row(
              children: [
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue700,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    '$totalUsuarios usuarios',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(width: 5),
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red700,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    '$totalAlertas alertas',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // Distribucion por colegio
      if (distribucionColegios.isNotEmpty)
        pw.Container(
          padding: pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'DISTRIBUCIÓN POR INSTITUCIÓN:',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Wrap(
                spacing: 10,
                runSpacing: 5,
                children: distribucionColegios.entries.map((entry) {
                  return pw.Container(
                    padding:
                        pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Text(
                      '${entry.key}: ${entry.value}',
                      style: pw.TextStyle(fontSize: 7),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

      // Estadisticas por sustancia
      pw.Container(
        padding: pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border(
            left: pw.BorderSide(color: PdfColors.grey400),
            right: pw.BorderSide(color: PdfColors.grey400),
            bottom: pw.BorderSide(color: PdfColors.grey400),
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'ESTADÍSTICAS DE ALERTAS POR SUSTANCIA:',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),

            // Tabla de estadisticas
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: pw.FlexColumnWidth(2.5),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(1),
                3: pw.FlexColumnWidth(1),
                4: pw.FlexColumnWidth(1),
                5: pw.FlexColumnWidth(1.2),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildTableCellGeneral('Sustancia', true),
                    _buildTableCellGeneral('Total', true),
                    _buildTableCellGeneral('Bajo', true),
                    _buildTableCellGeneral('Moderado', true),
                    _buildTableCellGeneral('Alto', true),
                    _buildTableCellGeneral('Promedio', true),
                  ],
                ),

                // Filas de datos
                ...estadisticas.entries.map((entry) {
                  final sustancia = entry.key;
                  final stats = entry.value;
                  final total = stats['total'] as int;
                  final bajo = stats['bajo'] as int;
                  final moderado = stats['moderado'] as int;
                  final alto = stats['alto'] as int;
                  final sumaPuntajes = stats['sumaPuntajes'] as double;
                  final promedio = total > 0 ? sumaPuntajes / total : 0.0;

                  return pw.TableRow(
                    children: [
                      _buildTableCellGeneral(sustancia, false),
                      _buildTableCellGeneral('$total', false),
                      _buildTableCellGeneral('$bajo', false,
                          bgColor: PdfColors.green50),
                      _buildTableCellGeneral('$moderado', false,
                          bgColor: PdfColors.yellow50),
                      _buildTableCellGeneral('$alto', false,
                          bgColor: PdfColors.red50),
                      _buildTableCellGeneral(
                          promedio.toStringAsFixed(1), false),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _buildTableCellGeneral(String text, bool isHeader,
    {PdfColor? bgColor}) {
  return pw.Container(
    padding: pw.EdgeInsets.all(5),
    color: bgColor,
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: isHeader ? 8 : 7,
        fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
      textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
    ),
  );
}

pw.Widget _buildFirmasGeneral(String fecha) {
  return pw.Center(
    child: pw.Column(
      children: [
        pw.Container(
          width: 250,
          margin: pw.EdgeInsets.only(bottom: 5),
          child: pw.Divider(thickness: 1),
        ),
        pw.Text(
          'PROFESIONAL RESPONSABLE',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'Fecha: $fecha',
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );
}

Future<void> _mostrarPDFGeneral(Uint8List pdfBytes) async {
  try {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
    print('PDF general mostrado exitosamente');
  } catch (e) {
    print('Error al mostrar PDF general: $e');
    await _compartirPDFGeneral(pdfBytes);
  }
}

Future<void> _compartirPDFGeneral(Uint8List pdfBytes) async {
  try {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename:
          'reporte_general_alertas_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    print('PDF general compartido exitosamente');
  } catch (e) {
    print('Error al compartir PDF general: $e');
    throw Exception('No se pudo mostrar ni compartir el PDF general');
  }
}
