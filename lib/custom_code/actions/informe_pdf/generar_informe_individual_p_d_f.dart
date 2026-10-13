// Main orchestrator for generating the individual tamizaje PDF report,
// styled to match the Niños de Papel branded reference.

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '/auth/firebase_auth/auth_util.dart';

import 'builders/pdf_footer.dart';
import 'builders/pdf_header.dart';
import 'builders/pdf_tamizajes_section.dart';
import 'builders/pdf_user_info.dart';
import 'helpers/pdf_assets.dart';
import 'helpers/pdf_styles.dart';

/// Generates an individual PDF report for the given user UID and either
/// prints it or shares it. Resilient to missing/partial data.
Future<void> generarInformeIndividualPDF(String userUid) async {
  Map<String, dynamic>? datosPersonales;
  List<ResultadoTamizaje> resultados = [];
  String nombreCompleto = 'Usuario';
  final erroresEncontrados = <String>[];

  try {
    if (userUid.isEmpty) {
      erroresEncontrados.add('UID de usuario no proporcionado');
      throw Exception('No se proporcionó un UID de usuario válido');
    }

    // Personal data
    try {
      datosPersonales = await obtenerDatosPacienteFirestoreSeguro(userUid);
      if (datosPersonales != null && datosPersonales.isNotEmpty) {
        nombreCompleto =
            '${datosPersonales['nombres']} ${datosPersonales['apellidos']}';
      } else {
        erroresEncontrados.add('Datos personales no encontrados');
        datosPersonales = generarDatosPersonalesPorDefecto(userUid);
        nombreCompleto = 'Usuario No Encontrado';
      }
    } catch (e) {
      erroresEncontrados
          .add('Error al obtener datos personales: ${e.toString()}');
      datosPersonales = generarDatosPersonalesPorDefecto(userUid);
      nombreCompleto = 'Usuario (Error en datos)';
    }

    // Tamizajes: una tarjeta por tamizaje realizado, cada una con su fecha y
    // sus propias notas del profesional.
    try {
      resultados = await obtenerTamizajesPorDocumento(userUid);
      if (resultados.isEmpty) {
        erroresEncontrados.add('Sin respuestas de tamizaje disponibles');
      }
    } catch (e) {
      erroresEncontrados.add('Error al obtener tamizaje: ${e.toString()}');
      resultados = [];
    }

    // Build + show
    Uint8List? pdfBytes;
    try {
      pdfBytes = await _crearInformeIndividualPDF(
        datosPersonales,
        resultados,
      );
    } catch (e) {
      erroresEncontrados.add('Error al crear PDF: ${e.toString()}');
      pdfBytes = await _crearPDFMinimo(datosPersonales, erroresEncontrados);
    }

    try {
      await _mostrarPDFIndividualSeguro(pdfBytes, nombreCompleto);
    } catch (_) {
      await _compartirPDFIndividualSeguro(pdfBytes, nombreCompleto);
    }
    return;
  } catch (e) {
    try {
      datosPersonales ??= generarDatosPersonalesPorDefecto(userUid);
      final pdfEmergencia = await _crearPDFMinimo(
        datosPersonales,
        [...erroresEncontrados, 'Error crítico: ${e.toString()}'],
      );
      await _mostrarPDFIndividualSeguro(pdfEmergencia, nombreCompleto);
      return;
    } catch (finalError) {
      throw Exception(
          'Error total al generar el informe: $e\nError final: $finalError');
    }
  }
}

Future<Uint8List> _crearInformeIndividualPDF(
  Map<String, dynamic> datosPersonales,
  List<ResultadoTamizaje> resultados,
) async {
  // Cargar fuente Inter (soporta Unicode: •, acentos, ñ, etc.)
  // Esto reemplaza Helvetica base que no puede renderizar bullets/emojis.
  final interRegular = await PdfGoogleFonts.interRegular();
  final interBold = await PdfGoogleFonts.interBold();
  final interItalic = await PdfGoogleFonts.interItalic();

  // Load branded assets (logo + warning triangles). Fall back to null
  // if loading fails so the PDF still renders with placeholders.
  PdfAssets? assets;
  try {
    assets = await PdfAssets.load();
  } catch (_) {
    assets = null;
  }

  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(
      base: interRegular,
      bold: interBold,
      italic: interItalic,
    ),
  );

  // Build the full list of body widgets once. MultiPage will paginate them
  // automatically. The branded header is rendered on every page via the
  // `header` callback.
  final body = <pw.Widget>[
    buildPatientHeaderBlock(datosPersonales),
    pw.SizedBox(height: 6),
    buildContactoBlock(datosPersonales),
    pw.SizedBox(height: 26),
  ];

  if (resultados.isEmpty) {
    body.add(buildMensajeSinDatosTamizaje());
    body.add(pw.SizedBox(height: 30));
  } else {
    body.addAll(buildTamizajeCards(resultados, assets: assets));
  }

  // Las observaciones del profesional van dentro de cada tarjeta.
  body.add(pw.SizedBox(height: 68));

  final nombreProfesional =
      currentUserDisplayName.trim().isEmpty ? '-' : currentUserDisplayName;
  body.add(buildSignatureFooter(nombreProfesional, assets: assets));

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.only(
        left: 0,
        right: 0,
        top: 0,
        bottom: 24,
      ),
      header: (pw.Context context) => buildBrandedPageHeader(assets: assets),
      build: (pw.Context context) => body
          .map((w) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 32),
                child: w,
              ))
          .toList(),
    ),
  );

  return pdf.save();
}

Future<Uint8List> _crearPDFMinimo(
  Map<String, dynamic> datosPersonales,
  List<String> errores,
) async {
  final pdf = pw.Document();
  final stamp = formatearFechaHoraAhora();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(2.0 * PdfPageFormat.cm),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'INFORME INDIVIDUAL',
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Fecha: ${stamp.fecha} - Hora: ${stamp.hora}',
                style: const pw.TextStyle(fontSize: 12)),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Text('DATOS DEL PACIENTE',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(
                'Nombre: ${datosPersonales['nombres']} ${datosPersonales['apellidos']}'),
            pw.Text(
                'Identificación: ${datosPersonales['numeroIdentificacion']}'),
            pw.Text('Edad: ${datosPersonales['edad']}'),
            pw.Text('Email: ${datosPersonales['email']}'),
            pw.Text('Teléfono: ${datosPersonales['telefono']}'),
            pw.SizedBox(height: 30),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.orange, width: 2),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('NOTA IMPORTANTE',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Este informe contiene únicamente los datos personales del usuario. '
                    'Los datos de tamizaje no están disponibles o no se pudieron cargar.',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            if (errores.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text('Advertencias técnicas:',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              ...errores.map((error) => pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                    child: pw.Text('- $error',
                        style: const pw.TextStyle(fontSize: 9)),
                  )),
            ],
            pw.Spacer(),
            pw.Divider(),
            pw.Text(
              'Documento generado automáticamente',
              style:
                  const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              textAlign: pw.TextAlign.center,
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

Future<void> _mostrarPDFIndividualSeguro(
    Uint8List pdfBytes, String paciente) async {
  try {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  } catch (e) {
    await _compartirPDFIndividualSeguro(pdfBytes, paciente);
  }
}

Future<void> _compartirPDFIndividualSeguro(
    Uint8List pdfBytes, String paciente) async {
  try {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename:
          'informe_${sanitizarNombreArchivoSeguro(paciente)}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  } catch (e) {
    throw Exception('No se pudo mostrar ni compartir el informe: $e');
  }
}
