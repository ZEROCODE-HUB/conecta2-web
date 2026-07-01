// "Observaciones médicas" light-blue card.

import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../helpers/pdf_styles.dart';

pw.Widget buildObservacionesSection(String observaciones) {
  final baseStyle = pw.TextStyle(
    fontSize: 9,
    color: PdfBrand.darkGrey,
  );

  final contentWidgets = parseQuillDeltaToPdf(observaciones, baseStyle);

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'OBSERVACIONES MEDICAS',
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(18),
        decoration: pw.BoxDecoration(
          color: PdfBrand.obsBlueBg,
          border: pw.Border.all(
            color: PdfColor.fromInt(0x801D3F8C),
            width: 0.8,
          ),
          borderRadius: pw.BorderRadius.circular(12),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: contentWidgets,
        ),
      ),
    ],
  );
}

List<pw.Widget> parseQuillDeltaToPdf(String deltaJson, pw.TextStyle baseStyle) {
  final trimmed = deltaJson.trim();
  if (trimmed.isEmpty) {
    return [pw.Text('No hay observaciones registradas', style: baseStyle)];
  }

  List<dynamic> ops;
  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is List) {
      ops = decoded;
    } else {
      return _plainTextToWidgets(trimmed, baseStyle);
    }
  } catch (_) {
    return _plainTextToWidgets(trimmed, baseStyle);
  }

  final paragraphs = <pw.Widget>[];
  var currentSpans = <pw.InlineSpan>[];

  for (final op in ops) {
    if (op is! Map) continue;
    final insert = op['insert'];
    if (insert == null) continue;
    final attrs = (op['attributes'] as Map<String, dynamic>?) ?? {};

    if (insert is String) {
      final text = insert;
      
      // Determine style for this run
      final isBold = attrs['bold'] == true;
      final isItalic = attrs['italic'] == true;
      final isUnderline = attrs['underline'] == true;
      
      final runStyle = baseStyle.copyWith(
        fontWeight: isBold ? pw.FontWeight.bold : baseStyle.fontWeight,
        fontStyle: isItalic ? pw.FontStyle.italic : baseStyle.fontStyle,
        decoration: isUnderline ? pw.TextDecoration.underline : baseStyle.decoration,
      );

      if (text.contains('\n')) {
        final parts = text.split('\n');
        for (var i = 0; i < parts.length; i++) {
          if (parts[i].isNotEmpty) {
            currentSpans.add(pw.TextSpan(text: parts[i], style: runStyle));
          }
          if (i < parts.length - 1) {
            // New line means we end the current paragraph
            if (currentSpans.isNotEmpty) {
              paragraphs.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.RichText(
                    text: pw.TextSpan(children: currentSpans),
                  ),
                ),
              );
              currentSpans = [];
            } else {
              // Empty line/paragraph spacing
              paragraphs.add(pw.SizedBox(height: 6));
            }
          }
        }
      } else {
        currentSpans.add(pw.TextSpan(text: text, style: runStyle));
      }
    }
  }

  if (currentSpans.isNotEmpty) {
    paragraphs.add(
      pw.RichText(
        text: pw.TextSpan(children: currentSpans),
      ),
    );
  }

  return paragraphs;
}

List<pw.Widget> _plainTextToWidgets(String text, pw.TextStyle style) {
  // Simple check for HTML tags
  if (text.contains('<p>') || text.contains('<b>') || text.contains('<strong>') || text.contains('<i>') || text.contains('<em>') || text.contains('<u>') || text.contains('<br>') || text.contains('<li>')) {
    return _parseHtmlToPdf(text, style);
  }

  final lines = text.split('\n');
  return lines.map((line) {
    final trimmedLine = line.trim();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
        trimmedLine.isEmpty ? ' ' : trimmedLine,
        style: style,
      ),
    );
  }).toList();
}

List<pw.Widget> _parseHtmlToPdf(String html, pw.TextStyle baseStyle) {
  final paragraphs = <pw.Widget>[];
  var currentSpans = <pw.InlineSpan>[];
  
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;

  // Extremely basic regex parser for common HTML tags
  final regex = RegExp(r'(<[^>]+>|[^<]+)');
  final matches = regex.allMatches(html);

  for (final match in matches) {
    final token = match.group(0)!;
    if (token.startsWith('<')) {
      final tag = token.toLowerCase();
      if (tag == '<b>' || tag == '<strong>') isBold = true;
      else if (tag == '</b>' || tag == '</strong>') isBold = false;
      else if (tag == '<i>' || tag == '<em>') isItalic = true;
      else if (tag == '</i>' || tag == '</em>') isItalic = false;
      else if (tag == '<u>') isUnderline = true;
      else if (tag == '</u>') isUnderline = false;
      else if (tag == '<br>' || tag == '<br/>' || tag == '</p>' || tag == '</li>') {
        if (currentSpans.isNotEmpty) {
          paragraphs.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.RichText(text: pw.TextSpan(children: currentSpans)),
            ),
          );
          currentSpans = [];
        } else {
          paragraphs.add(pw.SizedBox(height: 6));
        }
      }
    } else {
      final text = token.replaceAll('&nbsp;', ' ').replaceAll('&lt;', '<').replaceAll('&gt;', '>');
      if (text.isNotEmpty) {
        final runStyle = baseStyle.copyWith(
          fontWeight: isBold ? pw.FontWeight.bold : baseStyle.fontWeight,
          fontStyle: isItalic ? pw.FontStyle.italic : baseStyle.fontStyle,
          decoration: isUnderline ? pw.TextDecoration.underline : baseStyle.decoration,
        );
        currentSpans.add(pw.TextSpan(text: text, style: runStyle));
      }
    }
  }

  if (currentSpans.isNotEmpty) {
    paragraphs.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.RichText(text: pw.TextSpan(children: currentSpans)),
      ),
    );
  }

  return paragraphs.isEmpty ? [pw.Text(' ')] : paragraphs;
}
