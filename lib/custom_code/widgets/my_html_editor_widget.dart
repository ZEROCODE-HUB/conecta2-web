// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class MyHtmlEditorWidget extends StatefulWidget {
  const MyHtmlEditorWidget(
      {Key? key, this.width, this.height, this.initialHtml})
      : super(key: key);

  final double? width;
  final double? height;
  final String? initialHtml;

  @override
  _MyHtmlEditorWidgetState createState() => _MyHtmlEditorWidgetState();
}

class _MyHtmlEditorWidgetState extends State<MyHtmlEditorWidget> {
  late quill.QuillController _controller;
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.initialHtml != null && widget.initialHtml!.isNotEmpty) {
      if (widget.initialHtml!.startsWith('<!-- quill-delta: ')) {
        final endIndex = widget.initialHtml!.indexOf('-->');
        if (endIndex != -1) {
          final deltaStr = widget.initialHtml!.substring(18, endIndex).trim();
          try {
            final deltaJson = jsonDecode(deltaStr) as List;
            final doc = quill.Document.fromJson(deltaJson);
            _controller = quill.QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0),
            );
          } catch (e) {
            final doc = quill.Document()..insert(0, widget.initialHtml!);
            _controller = quill.QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0),
            );
          }
        } else {
          final doc = quill.Document()..insert(0, widget.initialHtml!);
          _controller = quill.QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
          );
        }
      } else {
        final doc = quill.Document()..insert(0, widget.initialHtml!);
        _controller = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      _controller = quill.QuillController.basic();
    }

    _startContentUpdateTimer();
  }

  void _startContentUpdateTimer() {
    _debounce = Timer.periodic(const Duration(seconds: 1), (timer) {
      try {
        final delta = _controller.document.toDelta().toJson();
        final converter = QuillDeltaToHtmlConverter(
          List.castFrom(delta),
        );
        final rawHtml = converter.convert();
        final deltaJson = jsonEncode(delta);
        final newContent = '<!-- quill-delta: $deltaJson -->\n$rawHtml';

        if (newContent != FFAppState().HTML) {
          FFAppState().update(() {
            FFAppState().HTML = newContent;
          });
          print("Contenido actualizado en AppState con formato HTML.");
        }
      } catch (e) {
        print("Error converting to HTML: $e");
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: const Locale('es'), // 👈 idioma por defecto
      delegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        quill.FlutterQuillLocalizations.delegate, // ✅ correcto
      ],
      child: Container(
        width: widget.width,
        height: widget.height ?? 400,
        child: Column(
          children: [
            quill.QuillSimpleToolbar(
              controller: _controller,
              config: const quill.QuillSimpleToolbarConfig(
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: true,
                showColorButton: true,
                showBackgroundColorButton: true,
                showClearFormat: true,
                showAlignmentButtons: true,
                showDirection: true,
                showHeaderStyle: true,
                showListNumbers: true,
                showListBullets: true,
                showCodeBlock: true,
                showQuote: true,
                showIndent: true,
                showLink: true,
                showUndo: true,
                showRedo: true,
                showFontSize: true,
                showFontFamily: true,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: quill.QuillEditor(
                  controller: _controller,
                  focusNode: _focusNode,
                  scrollController: _scrollController,
                  config: const quill.QuillEditorConfig(
                    padding: EdgeInsets.zero,
                    placeholder: 'Escribe tu texto aquí...',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
