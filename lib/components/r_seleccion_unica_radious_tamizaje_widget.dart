import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'r_seleccion_unica_radious_tamizaje_model.dart';
export 'r_seleccion_unica_radious_tamizaje_model.dart';

class RSeleccionUnicaRadiousTamizajeWidget extends StatefulWidget {
  const RSeleccionUnicaRadiousTamizajeWidget({
    super.key,
    this.parameter1,
    this.index,
  });

  final List<AtributosStruct>? parameter1;
  final int? index;

  @override
  State<RSeleccionUnicaRadiousTamizajeWidget> createState() =>
      _RSeleccionUnicaRadiousTamizajeWidgetState();
}

class _RSeleccionUnicaRadiousTamizajeWidgetState
    extends State<RSeleccionUnicaRadiousTamizajeWidget> {
  late RSeleccionUnicaRadiousTamizajeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RSeleccionUnicaRadiousTamizajeModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterFlowRadioButton(
      options: widget.parameter1!.map((e) => e.etiqueta).toList(),
      onChanged: (val) async {
        safeSetState(() {});
        FFAppState().updateRespuestaEncAtIndex(
          widget.index!,
          (e) => e
            ..respuestaTamizaje = widget.parameter1!
                .where((e) => _model.radioButtonValue == e.etiqueta)
                .toList(),
        );
        FFAppState().update(() {});
      },
      controller: _model.radioButtonValueController ??=
          FormFieldController<String>(null),
      optionHeight: null,
      optionWidth: MediaQuery.sizeOf(context).width - 64,
      textStyle: FlutterFlowTheme.of(context).labelMedium.override(
            font: GoogleFonts.inter(
              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
            ),
            fontSize: 14.0,
            letterSpacing: 0.0,
            fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
            fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
          ),
      buttonPosition: RadioButtonPosition.left,
      direction: Axis.vertical,
      radioButtonColor: FlutterFlowTheme.of(context).secondary,
      inactiveRadioButtonColor: FlutterFlowTheme.of(context).tertiary,
      toggleable: false,
      horizontalAlignment: WrapAlignment.start,
      verticalAlignment: WrapCrossAlignment.start,
    );
  }
}
