// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:conecta2/backend/schema/encuestas_record.dart';
import 'package:conecta2/backend/schema/respuestas_record.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

import '/components/rich_text_notas/rich_text_notas_widget.dart'
    show quillDeltaToPlainText;

import '/custom_code/actions/informe_pdf/builders/pdf_user_info.dart';
import '/tamizajes/shared/assist_utils.dart';

// ─── Paleta de marca ─────────────────────────────────────────────────────────
const PdfColor _yellowBrand = PdfColor.fromInt(0xFFF6C04F);
const PdfColor _redAlert = PdfColor.fromInt(0xFFE83F3F);
const PdfColor _navyBrand = PdfColor.fromInt(0xFF1E3A8A);
const PdfColor _obsBlueBg = PdfColor.fromInt(0xFFE8F0FE);
const PdfColor _lightGrey = PdfColor.fromInt(0xFFB0B0B0);
const PdfColor _darkGrey = PdfColor.fromInt(0xFF6B6B6B);
const PdfColor _decorPink = PdfColor.fromInt(0xFFF5C8C0);
const PdfColor _decorYellowSoft = PdfColor.fromInt(0xFFFDE9B5);

/// Genera un PDF con los datos del tamizaje y lo descarga/imprime.
///
/// Sigue el estilo visual institucional (IPS Asociación Niñ@s de Papel):
/// barra superior amarilla, tarjetas con borde redondeado, colores de
/// severidad y decoración inferior.
Future<void> exportarResultadosPDF({
  required String titloTamizaje,
  required String nombrePaciente,
  required String fecha,
  required int puntaje,
  required String notas,
  required List<_PreguntaExport> preguntas,
  required bool invalidado,
  required bool hayIdeacionSuicida,
  RespuestasRecord? respuesta,
}) async {
  final logoData = await rootBundle.load('assets/pdf/logo.png');
  final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

  Map<String, dynamic> datosPaciente = generarDatosPersonalesPorDefecto(
      respuesta?.userRespuesta?.id ?? 'Desconocido');
  if (respuesta != null && respuesta.userRespuesta != null) {
    final datos =
        await obtenerDatosPacienteFirestoreSeguro(respuesta.userRespuesta!.id);
    if (datos != null) {
      datosPaciente = datos;
    } else {
      datosPaciente['nombres'] = nombrePaciente;
      datosPaciente['apellidos'] = '';
    }
  } else {
    datosPaciente['nombres'] = nombrePaciente;
    datosPaciente['apellidos'] = '';
  }

  final pdf = pw.Document();

  _Severity severity = _deriveSeverity(
    puntaje: puntaje,
    hayIdeacionSuicida: hayIdeacionSuicida,
    invalidado: invalidado,
  );

  String? cdiCalculation;
  ResultadoAssist? assist;
  var preguntasVisibles = preguntas;
  if (respuesta != null) {
    try {
      final encuesta =
          await EncuestasRecord.getDocumentOnce(respuesta.parentReference);
      // ASSIST: severidad = peor sustancia (Alto → SEVERO, Moderado → ALTO);
      // el umbral genérico sobre el puntaje total no tiene sentido aquí.
      if (esEncuestaAssist(encuesta.categoria, encuesta.titulo)) {
        assist = evaluarAssistDesdeStructs(
          preguntas: encuesta.preguntas,
          test: respuesta.test,
          alertas: encuesta.alertas,
        );
        if (!invalidado && !hayIdeacionSuicida) {
          severity = switch (assist.nivelGlobal) {
            'Alto' => _Severity.severo,
            'Moderado' => _Severity.alto,
            _ => _Severity.normal,
          };
        }
        final noAplican = {
          for (final item in respuesta.test)
            if (itemSustanciaNoAplica(item, encuesta.preguntas)) item.nPregunta,
        };
        preguntasVisibles = [
          for (final p in preguntas)
            if (!noAplican.contains(p.numero)) p,
        ];
      }
      if (encuesta.categoria == 'CDI') {
        int d = 0, a = 0;
        bool tieneVariables = false;
        final listPreguntas = encuesta.preguntas;
        for (int i = 0; i < respuesta.test.length; i++) {
          final r = respuesta.test[i];
          final pregIdx = r.nPregunta > 0 ? r.nPregunta - 1 : i;
          if (pregIdx < listPreguntas.length) {
            final variable =
                listPreguntas[pregIdx].variable.trim().toUpperCase();
            final isDisforia = variable == 'D' || variable.contains('DISFORIA');
            final isAutoestima =
                variable == 'A' || variable.contains('AUTOESTIMA');
            if (isDisforia || isAutoestima) tieneVariables = true;
            final valor = r.respuestaTamizaje.isNotEmpty
                ? r.respuestaTamizaje.first.valor
                : 0;
            if (isDisforia) d += valor;
            if (isAutoestima) a += valor;
          }
        }
        if (tieneVariables) {
          cdiCalculation = 'Disforia $d | Autoestima negativa $a';
        }
      }
    } catch (_) {}
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 0, 40, 40),
      header: (pw.Context ctx) => _buildTopBar(),
      footer: (pw.Context ctx) => _buildFooter(ctx),
      build: (pw.Context context) {
        return [
          pw.SizedBox(height: 14),
          // ── Encabezado institucional ────────────────────────────────
          _buildInstitutionalHeader(logoImage),
          pw.SizedBox(height: 24),

          // ── Título del tamizaje + subtítulo ─────────────────────────
          _buildTitleSection(
            titulo: titloTamizaje,
            fecha: fecha,
          ),
          pw.SizedBox(height: 16),

          // ── Información del Paciente ─────────────────────────────────
          buildPatientHeaderBlock(datosPaciente),
          pw.SizedBox(height: 6),
          pw.Divider(color: PdfColors.grey500, thickness: 1),
          buildContactoBlock(datosPaciente),
          pw.Divider(color: PdfColors.grey500, thickness: 1),
          pw.SizedBox(height: 12),

          // ── Tarjeta resumen (Nivel / Puntaje / Estado) ──────────────
          _buildSummaryCard(
            severity: severity,
            puntaje: puntaje,
            invalidado: invalidado,
            cdiCalculation: cdiCalculation,
          ),
          pw.SizedBox(height: 16),

          // ── ASSIST: riesgo por sustancia ─────────────────────────────
          if (assist != null) ...[
            _buildRiesgoSustanciasSection(assist),
            pw.SizedBox(height: 16),
          ],

          // ── Badges de alerta ─────────────────────────────────────────
          if (hayIdeacionSuicida ||
              severity == _Severity.severo ||
              severity == _Severity.alto) ...[
            _buildAlertBadges(
              hayIdeacionSuicida: hayIdeacionSuicida,
              severity: severity,
            ),
          ],

          // ── Respuestas ───────────────────────────────────────────────
          if (preguntasVisibles.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            _buildRespuestasSection(preguntasVisibles),
          ],

          pw.SizedBox(height: 22),

          // ── Observaciones médicas ────────────────────────────────────
          _buildObservacionesSection(notas),
        ];
      },
    ),
  );

  final bytes = await pdf.save();
  final fileName = 'tamizaje_${nombrePaciente.replaceAll(' ', '_')}.pdf';

  if (kIsWeb) {
    await Printing.layoutPdf(onLayout: (_) => bytes, name: fileName);
  } else {
    await Printing.layoutPdf(onLayout: (_) => bytes, name: fileName);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Secciones
// ─────────────────────────────────────────────────────────────────────────────

pw.Widget _buildTopBar() {
  return pw.Column(
    children: [
      pw.Container(
        height: 5,
        width: double.infinity,
        color: _yellowBrand,
      ),
      pw.SizedBox(height: 25),
    ],
  );
}

pw.Widget _buildInstitutionalHeader(pw.MemoryImage logoImage) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      // Logo placeholder + NIT
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Image(logoImage, width: 50, height: 50),
          pw.SizedBox(height: 6),
          pw.Text(
            'NIT 0123456789',
            style: pw.TextStyle(
              fontSize: 9,
              color: _darkGrey,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
      // Contacto
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            '318 2106656',
            style: pw.TextStyle(
              fontSize: 10,
              color: _darkGrey,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'atencionalusuario@ninosdepapel.org',
            style: const pw.TextStyle(fontSize: 9, color: _darkGrey),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildTitleSection({
  required String titulo,
  required String fecha,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        titulo.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 22,
          fontWeight: pw.FontWeight.bold,
          color: _navyBrand,
          letterSpacing: 0.3,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'FECHA DE REALIZACIÓN: $fecha',
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: _darkGrey,
        ),
      ),
    ],
  );
}

pw.Widget _buildSummaryCard({
  required _Severity severity,
  required int puntaje,
  required bool invalidado,
  String? cdiCalculation,
}) {
  final bool riskIsRed =
      severity == _Severity.alto || severity == _Severity.severo;

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'NIVEL DE RIESGO: ${severity.label}',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: riskIsRed ? _redAlert : PdfColors.black,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'PUNTAJE: ${puntaje.toString()}',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
            pw.SizedBox(height: 6),
            _summaryLine(
              label: 'ESTADO:',
              value: invalidado ? 'INVALIDADA' : 'VÁLIDA',
              valueColor: invalidado ? _redAlert : _darkGrey,
              valueBold: invalidado,
            ),
            if (cdiCalculation != null) ...[
              pw.SizedBox(height: 4),
              _summaryLine(
                label: 'SUBESCALAS:',
                value: cdiCalculation,
                valueColor: _darkGrey,
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

pw.Widget _summaryLine({
  required String label,
  required String value,
  required PdfColor valueColor,
  bool valueBold = false,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label ',
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.TextSpan(
            text: value,
            style: pw.TextStyle(
              fontSize: 8.5,
              color: valueColor,
              fontWeight: valueBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

pw.Widget _buildAlertBadges({
  required bool hayIdeacionSuicida,
  required _Severity severity,
}) {
  final List<pw.Widget> badges = [];

  if (hayIdeacionSuicida) {
    badges.add(_riskVitalBadge());
  } else if (severity == _Severity.severo || severity == _Severity.alto) {
    badges.add(_impactoBadge());
  }

  if (badges.isEmpty) return pw.Container(height: 0, width: 0);

  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 14),
    child: pw.Row(
      children: [
        for (int i = 0; i < badges.length; i++) ...[
          pw.Expanded(child: badges[i]),
          if (i < badges.length - 1) pw.SizedBox(width: 12),
        ],
      ],
    ),
  );
}

pw.Widget _riskVitalBadge() {
  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: _decorPink,
      borderRadius: pw.BorderRadius.circular(10),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 20,
              height: 20,
              decoration: pw.BoxDecoration(
                color: _redAlert,
                borderRadius: pw.BorderRadius.circular(3),
              ),
              alignment: pw.Alignment.center,
              child: pw.Text(
                '!',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              'RIESGO VITAL',
              style: pw.TextStyle(
                color: _redAlert,
                fontWeight: pw.FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Pensamientos o deseos suicidas',
          style: const pw.TextStyle(fontSize: 10, color: _darkGrey),
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: PdfColors.white, height: 1, thickness: 0.6),
        pw.SizedBox(height: 4),
        pw.Text(
          'REMISIÓN MÉDICA INMEDIATA',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: _redAlert,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _impactoBadge() {
  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: _decorYellowSoft,
      borderRadius: pw.BorderRadius.circular(10),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 20,
              height: 20,
              decoration: pw.BoxDecoration(
                color: _yellowBrand,
                borderRadius: pw.BorderRadius.circular(3),
              ),
              alignment: pw.Alignment.center,
              child: pw.Text(
                '!',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Text(
                'IMPACTO IMPORTANTE EN ACTIVIDADES COTIDIANAS',
                style: pw.TextStyle(
                  color: PdfColors.black,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: PdfColors.white, height: 1, thickness: 0.6),
        pw.SizedBox(height: 4),
        pw.Text(
          'ACOMPAÑAMIENTO MÉDICO',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: _darkGrey,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildRespuestasSection(List<_PreguntaExport> preguntas) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Center(
        child: pw.Text(
          'RESPUESTAS DEL PACIENTE',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: _navyBrand,
            letterSpacing: 0.4,
          ),
        ),
      ),
      pw.SizedBox(height: 12),
      ...preguntas.map((p) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${p.numero}. ${p.pregunta}',
                style: pw.TextStyle(
                  fontSize: 10.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Respuesta: ${p.respuesta}',
                style: const pw.TextStyle(
                  fontSize: 10.5,
                  color: _darkGrey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ],
  );
}


/// ASSIST: tabla con el puntaje y el nivel de cada sustancia evaluada.
pw.Widget _buildRiesgoSustanciasSection(ResultadoAssist r) {
  PdfColor colorNivel(String nivel) => switch (nivel) {
        'Alto' => PdfColors.red700,
        'Moderado' => PdfColors.orange700,
        'Bajo' => PdfColors.green700,
        _ => _darkGrey,
      };
  final filas = r.porSustancia.values.toList();
  final usaOms = filas.any((s) => s.origen == OrigenNivel.oms);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Text(
        'RIESGO POR SUSTANCIA',
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: _navyBrand,
          letterSpacing: 0.4,
        ),
      ),
      if (r.sustanciasMarcadas.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Text(
          'Marcadas en el condicionante: ${r.sustanciasMarcadas.join(', ')}',
          style: const pw.TextStyle(fontSize: 9.5, color: _darkGrey),
        ),
      ],
      pw.SizedBox(height: 8),
      if (filas.isEmpty)
        pw.Text(
          'No se evaluó ninguna sustancia (no se marcó consumo en el condicionante).',
          style: const pw.TextStyle(fontSize: 10, color: _darkGrey),
        )
      else
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(1.2),
            2: pw.FlexColumnWidth(1.5),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: ['Sustancia', 'Puntaje', 'Nivel']
                  .map((h) => pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(h,
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      ))
                  .toList(),
            ),
            for (final s in filas)
              pw.TableRow(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(s.sustancia,
                      style: const pw.TextStyle(fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('${s.puntaje}',
                      style: const pw.TextStyle(fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    s.origen == OrigenNivel.oms ? '${s.nivel} *' : s.nivel,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: colorNivel(s.nivel),
                    ),
                  ),
                ),
              ]),
          ],
        ),
      if (usaOms) ...[
        pw.SizedBox(height: 4),
        pw.Text(
          '* Sin rangos configurados para la sustancia: se usan los cortes ASSIST de la OMS.',
          style: pw.TextStyle(
              fontSize: 8.5, fontStyle: pw.FontStyle.italic, color: _darkGrey),
        ),
      ],
    ],
  );
}

pw.Widget _buildObservacionesSection(String notas) {
  // Notas may come as a Quill Delta JSON string (rich editor) or as legacy
  // plain text; normalise to plain text for PDF rendering.
  notas = quillDeltaToPlainText(notas);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'OBSERVACIONES MÉDICAS',
        style: pw.TextStyle(
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
          color: _navyBrand,
          letterSpacing: 0.3,
        ),
      ),
      pw.SizedBox(height: 12),
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8, bottom: 14),
        child: pw.Text(
          notas.trim().isNotEmpty ? notas : 'Sin notas registradas.',
          style: pw.TextStyle(
            fontSize: 10.5,
            color: notas.trim().isNotEmpty ? PdfColors.black : _darkGrey,
            lineSpacing: 2,
          ),
        ),
      ),
    ],
  );
}

pw.Widget _buildFooter(pw.Context ctx) {
  final now = DateTime.now();
  final dateStr =
      '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  final bool isLast = ctx.pageNumber == ctx.pagesCount;

  return pw.Stack(
    children: [
      pw.Container(
        padding: const pw.EdgeInsets.only(top: 10, bottom: 8),
        alignment: pw.Alignment.center,
        child: pw.Text(
          'Documento generado el $dateStr',
          style: const pw.TextStyle(fontSize: 9, color: _darkGrey),
        ),
      ),
      if (isLast)
        pw.Positioned(
          right: 0,
          bottom: 0,
          child: _decorativeCircles(),
        ),
    ],
  );
}

pw.Widget _decorativeCircles() {
  return pw.Container(
    width: 110,
    height: 70,
    child: pw.Stack(
      children: [
        pw.Positioned(
          left: 0,
          top: 10,
          child: pw.Container(
            width: 55,
            height: 55,
            decoration: pw.BoxDecoration(
              color: _decorYellowSoft,
              shape: pw.BoxShape.circle,
            ),
          ),
        ),
        pw.Positioned(
          left: 50,
          top: 0,
          child: pw.Container(
            width: 28,
            height: 28,
            decoration: pw.BoxDecoration(
              color: _decorPink,
              shape: pw.BoxShape.circle,
            ),
          ),
        ),
        pw.Positioned(
          left: 70,
          top: 35,
          child: pw.Container(
            width: 32,
            height: 32,
            decoration: pw.BoxDecoration(
              color: _navyBrand,
              shape: pw.BoxShape.circle,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

pw.Widget _logoPlaceholder(double size) {
  return pw.Container(
    width: size,
    height: size,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Center(
      child: pw.Text(
        'LOGO',
        style: pw.TextStyle(color: PdfColors.grey500, fontSize: 10),
      ),
    ),
  );
}

_Severity _deriveSeverity({
  required int puntaje,
  required bool hayIdeacionSuicida,
  required bool invalidado,
}) {
  if (invalidado) return _Severity.normal;
  if (hayIdeacionSuicida) return _Severity.severo;
  if (puntaje >= 30) return _Severity.severo;
  if (puntaje >= 15) return _Severity.alto;
  return _Severity.normal;
}

enum _Severity {
  normal('N/A'),
  alto('ALTO'),
  severo('SEVERO');

  const _Severity(this.label);
  final String label;
}

// ─────────────────────────────────────────────────────────────────────────────
// Data class pública
// ─────────────────────────────────────────────────────────────────────────────

class PreguntaExport {
  const PreguntaExport({
    required this.numero,
    required this.pregunta,
    required this.respuesta,
  });

  final int numero;
  final String pregunta;
  final String respuesta;
}

// Alias privado para uso interno del archivo.
typedef _PreguntaExport = PreguntaExport;
