import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'text_field_alerta_model.dart';
export 'text_field_alerta_model.dart';

class TextFieldAlertaWidget extends StatefulWidget {
  const TextFieldAlertaWidget({
    super.key,
    this.parameter1,
    required this.accion,
  });

  final int? parameter1;
  final Future Function(int nuevoTexto)? accion;

  @override
  State<TextFieldAlertaWidget> createState() => _TextFieldAlertaWidgetState();
}

class _TextFieldAlertaWidgetState extends State<TextFieldAlertaWidget> {
  late TextFieldAlertaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TextFieldAlertaModel());

    _model.textFieldMin1TextController ??=
        TextEditingController(text: widget.parameter1?.toString());
    _model.textFieldMin1FocusNode ??= FocusNode();
    _model.textFieldMin1FocusNode!.addListener(
      () async {
        await widget.accion?.call(
          int.parse(_model.textFieldMin1TextController.text),
        );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void didUpdateWidget(covariant TextFieldAlertaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parameter1 != widget.parameter1) {
      final newText = widget.parameter1?.toString() ?? '';
      if (_model.textFieldMin1TextController.text != newText) {
        _model.textFieldMin1TextController.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
      child: TextFormField(
        controller: _model.textFieldMin1TextController,
        focusNode: _model.textFieldMin1FocusNode,
        onChanged: (_) => EasyDebounce.debounce(
          '_model.textFieldMin1TextController',
          Duration(milliseconds: 2000),
          () async {
            await widget.accion?.call(
              int.parse(_model.textFieldMin1TextController.text),
            );
          },
        ),
        autofocus: false,
        obscureText: false,
        decoration: InputDecoration(
          labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                font: GoogleFonts.inter(
                  fontWeight:
                      FlutterFlowTheme.of(context).labelMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                ),
                letterSpacing: 0.0,
                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
              ),
          hintText: '0',
          hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                font: GoogleFonts.inter(
                  fontWeight:
                      FlutterFlowTheme.of(context).labelMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                ),
                color: Color(0xFF9E8888),
                fontSize: 16.0,
                letterSpacing: 0.0,
                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
              ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0x00000000),
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0x00000000),
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0x00000000),
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0x00000000),
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Color(0xFFF5F5F5),
        ),
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(
                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              letterSpacing: 0.0,
              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
            ),
        validator:
            _model.textFieldMin1TextControllerValidator.asValidator(context),
      ),
    );
  }
}
