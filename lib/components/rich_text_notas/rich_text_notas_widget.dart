// ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// A reusable rich-text editor for "Notas del profesional".
///
/// Stores its value as a **Quill Delta JSON** string (see
/// `QuillController.document.toDelta().toJson()`), which preserves inline
/// formats (bold/italic/underline), headers (H1/H2/H3) and lists.
///
/// Gracefully supports legacy records where `initialValue` is plain text
/// (non-JSON): such values are converted to a single-paragraph Delta on load.
///
/// The value is propagated via [onChanged] on every document change.
class RichTextNotasEditor extends StatefulWidget {
  const RichTextNotasEditor({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.readOnly = false,
    this.minHeight = 200,
    this.placeholder = 'Escribe las observaciones...',
  });

  /// Initial content — either a Quill Delta JSON string (preferred) or a
  /// plain-text string for legacy records.
  final String initialValue;

  /// Called every time the document changes with the new Delta JSON string.
  final ValueChanged<String> onChanged;

  /// Disables editing and hides the toolbar when `true`.
  final bool readOnly;

  /// Minimum visible height of the editor area.
  final double minHeight;

  /// Placeholder shown when the document is empty.
  final String placeholder;

  @override
  State<RichTextNotasEditor> createState() => _RichTextNotasEditorState();
}

class _RichTextNotasEditorState extends State<RichTextNotasEditor> {
  late quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = _buildController(widget.initialValue, widget.readOnly);
    _controller.document.changes.listen((_) {
      final json = jsonEncode(_controller.document.toDelta().toJson());
      widget.onChanged(json);
    });
  }

  @override
  void didUpdateWidget(covariant RichTextNotasEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.readOnly != widget.readOnly) {
      _controller.readOnly = widget.readOnly;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Builds a [quill.QuillController] from a string. Falls back to a
  /// single-paragraph plain-text document when the string is not valid
  /// Quill Delta JSON.
  static quill.QuillController _buildController(
    String raw,
    bool readOnly,
  ) {
    quill.Document doc;
    if (raw.trim().isEmpty) {
      doc = quill.Document();
    } else {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          doc = quill.Document.fromJson(decoded);
        } else {
          doc = quill.Document()..insert(0, raw);
        }
      } catch (_) {
        doc = quill.Document()..insert(0, raw);
      }
    }
    return quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: readOnly,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E7EC)),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.readOnly) _buildToolbar(),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: widget.minHeight),
              child: quill.QuillEditor(
                controller: _controller,
                focusNode: _focusNode,
                scrollController: _scrollController,
                config: quill.QuillEditorConfig(
                  placeholder: widget.placeholder,
                  padding: const EdgeInsets.all(16),
                  scrollable: true,
                  expands: false,
                  autoFocus: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toolbar completa y responsive: usa todo el ancho disponible con scroll
  /// horizontal y separadores verticales entre grupos de botones.
  Widget _buildToolbar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FA),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE4E7EC)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: quill.QuillSimpleToolbar(
        controller: _controller,
        config: const quill.QuillSimpleToolbarConfig(
          multiRowsDisplay: true,
          toolbarIconAlignment: WrapAlignment.start,
          toolbarIconCrossAlignment: WrapCrossAlignment.center,
          showDividers: true,
          showHeaderStyle: true,
          showBoldButton: true,
          showItalicButton: true,
          showUnderLineButton: true,
          showStrikeThrough: true,
          showSmallButton: false,
          showSubscript: true,
          showSuperscript: true,
          showColorButton: true,
          showBackgroundColorButton: true,
          showClearFormat: true,
          showListNumbers: true,
          showListBullets: true,
          showListCheck: true,
          showQuote: true,
          showIndent: true,
          showInlineCode: false,
          showCodeBlock: true,
          showLink: true,
          showAlignmentButtons: true,
          showJustifyAlignment: true,
          showLeftAlignment: true,
          showCenterAlignment: true,
          showRightAlignment: true,
          showDirection: false,
          showFontFamily: false,
          showFontSize: true,
          showSearchButton: false,
          showUndo: true,
          showRedo: true,
          showLineHeightButton: false,
        ),
      ),
    );
  }
}

/// Converts a Quill Delta JSON string to plain text. When the input is not
/// valid Delta JSON (e.g. legacy plain-text notes), the input is returned
/// as-is.
String quillDeltaToPlainText(String deltaJson) {
  final trimmed = deltaJson.trim();
  if (trimmed.isEmpty) return '';
  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is! List) return deltaJson;
    final doc = quill.Document.fromJson(decoded);
    // `toPlainText` returns the document text with a trailing newline; trim it.
    return doc.toPlainText().trimRight();
  } catch (_) {
    return deltaJson;
  }
}
