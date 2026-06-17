// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

import '/components/rich_text_notas/rich_text_notas_widget.dart'
    show quillDeltaToPlainText;

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
}) async {
  final logoData = await rootBundle.load('assets/pdf/logo.png');
  final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

  final pdf = pw.Document();

  // Nivel de riesgo derivado del puntaje y la ideación suicida.
  final _Severity severity = _deriveSeverity(
    puntaje: puntaje,
    hayIdeacionSuicida: hayIdeacionSuicida,
    invalidado: invalidado,
  );

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
            paciente: nombrePaciente,
            fecha: fecha,
          ),
          pw.SizedBox(height: 22),

          // ── Tarjeta resumen (Nivel / Puntaje / Estado) ──────────────
          _buildSummaryCard(
            severity: severity,
            puntaje: puntaje,
            invalidado: invalidado,
          ),
          pw.SizedBox(height: 16),

          // ── Badges de alerta ─────────────────────────────────────────
          _buildAlertBadges(
            hayIdeacionSuicida: hayIdeacionSuicida,
            severity: severity,
          ),

          // ── Respuestas ───────────────────────────────────────────────
          if (preguntas.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            _buildRespuestasSection(preguntas),
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
  return pw.Container(
    height: 5,
    width: double.infinity,
    color: _yellowBrand,
    margin: const pw.EdgeInsets.only(bottom: 0),
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
  required String paciente,
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
      pw.SizedBox(height: 6),
      pw.Row(
        children: [
          pw.Text(
            paciente.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: _darkGrey,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Container(width: 1, height: 12, color: _lightGrey),
          pw.SizedBox(width: 10),
          pw.Text(
            'Fecha: $fecha',
            style: const pw.TextStyle(fontSize: 11, color: _darkGrey),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildSummaryCard({
  required _Severity severity,
  required int puntaje,
  required bool invalidado,
}) {
  final PdfColor borderColor;
  switch (severity) {
    case _Severity.severo:
      borderColor = _yellowBrand;
      break;
    case _Severity.alto:
      borderColor = _redAlert;
      break;
    case _Severity.normal:
      borderColor = _lightGrey;
      break;
  }

  final bool riskIsRed =
      severity == _Severity.alto || severity == _Severity.severo;

  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: borderColor, width: 1.4),
      borderRadius: pw.BorderRadius.circular(16),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _summaryLine(
          label: 'NIVEL DE RIESGO:',
          value: severity.label,
          valueColor: riskIsRed ? _redAlert : _darkGrey,
          valueBold: true,
        ),
        pw.SizedBox(height: 6),
        _summaryLine(
          label: 'PUNTAJE:',
          value: puntaje.toString(),
          valueColor: _darkGrey,
        ),
        pw.SizedBox(height: 6),
        _summaryLine(
          label: 'ESTADO:',
          value: invalidado ? 'INVALIDADA' : 'VÁLIDA',
          valueColor: invalidado ? _redAlert : _darkGrey,
          valueBold: invalidado,
        ),
      ],
    ),
  );
}

pw.Widget _summaryLine({
  required String label,
  required String value,
  required PdfColor valueColor,
  bool valueBold = false,
}) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
      pw.SizedBox(width: 6),
      pw.Text(
        value,
        style: pw.TextStyle(
          fontSize: 11,
          color: valueColor,
          fontWeight:
              valueBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    ],
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

  if (badges.isEmpty) return pw.SizedBox();

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
      pw.Table(
        border: pw.TableBorder(
          horizontalInside:
              pw.BorderSide(color: PdfColors.grey300, width: 0.4),
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.4),
        ),
        columnWidths: {
          0: const pw.FixedColumnWidth(34),
          1: const pw.FlexColumnWidth(2.2),
          2: const pw.FlexColumnWidth(2.8),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: _decorYellowSoft),
            children: [
              _headerCell('#'),
              _headerCell('Pregunta'),
              _headerCell('Respuesta'),
            ],
          ),
          for (int i = 0; i < preguntas.length; i++)
            pw.TableRow(
              decoration: pw.BoxDecoration(
                color: i.isEven ? PdfColors.white : PdfColors.grey50,
              ),
              children: [
                _bodyCell('${preguntas[i].numero}', center: true),
                _bodyCell(preguntas[i].pregunta, bold: true),
                _bodyCell(preguntas[i].respuesta),
              ],
            ),
        ],
      ),
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
      pw.SizedBox(height: 8),
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: _obsBlueBg,
          borderRadius: pw.BorderRadius.circular(10),
        ),
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

pw.Widget _headerCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10.5,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.black,
      ),
    ),
  );
}

pw.Widget _bodyCell(String text, {bool bold = false, bool center = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    child: pw.Text(
      text,
      textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      style: pw.TextStyle(
        fontSize: 10,
        color: PdfColors.black,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
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
