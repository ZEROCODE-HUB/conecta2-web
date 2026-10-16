import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'verdaderofalso_model.dart';
export 'verdaderofalso_model.dart';

/// Respuesta de una pregunta "Verdadero o falso".
///
/// Las dos opciones se excluyen entre sí. La opción marcada se lee siempre de
/// `FFAppState().RespuestaEnc[parameter2].trueAndFalse` (1 = Verdadero,
/// 0 = Falso, sin valor = sin responder). Tocar otra vez la opción marcada la
/// desmarca, y la pregunta vuelve a contar como no respondida.
class VerdaderofalsoWidget extends StatefulWidget {
  const VerdaderofalsoWidget({
    super.key,
    this.parameter1,
    this.parameter2,
  });

  final int? parameter1;

  /// Índice de la pregunta en `FFAppState().RespuestaEnc`.
  final int? parameter2;

  @override
  State<VerdaderofalsoWidget> createState() => _VerdaderofalsoWidgetState();
}

class _VerdaderofalsoWidgetState extends State<VerdaderofalsoWidget> {
  late VerdaderofalsoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VerdaderofalsoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  bool get _indiceValido {
    final i = widget.parameter2;
    return i != null && i >= 0 && i < FFAppState().RespuestaEnc.length;
  }

  /// 1 = Verdadero, 0 = Falso, null = sin responder.
  int? get _seleccion {
    if (!_indiceValido) return null;
    final r = FFAppState().RespuestaEnc[widget.parameter2!];
    return r.hasTrueAndFalse() ? r.trueAndFalse : null;
  }

  void _elegir(int valor) {
    if (!_indiceValido) return;
    final nuevo = _seleccion == valor ? null : valor;
    FFAppState().updateRespuestaEncAtIndex(
      widget.parameter2!,
      (e) => e..trueAndFalse = nuevo,
    );
    // La pantalla padre recalcula si ya se puede enviar.
    _model.updatePage(() {});
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final seleccion = _seleccion;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 10.0, 0.0),
          child: _opcion(
            context,
            etiqueta: 'Verdadero',
            seleccionada: seleccion == 1,
            onTap: () => _elegir(1),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
          child: _opcion(
            context,
            etiqueta: 'Falso',
            seleccionada: seleccion == 0,
            onTap: () => _elegir(0),
          ),
        ),
      ],
    );
  }

  Widget _opcion(
    BuildContext context, {
    required String etiqueta,
    required bool seleccionada,
    required VoidCallback onTap,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Semantics(
      button: true,
      selected: seleccionada,
      label: etiqueta,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: seleccionada
                  ? theme.primary.withValues(alpha: 0.08)
                  : theme.primaryBackground,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: theme.primary,
                width: seleccionada ? 2.0 : 1.0,
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 12.0, 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    seleccionada
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: seleccionada ? theme.primary : theme.secondaryText,
                    size: 22.0,
                  ),
                  SizedBox(width: 6.0),
                  Text(
                    etiqueta,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontStyle: theme.bodyMedium.fontStyle,
                      ),
                      fontSize: 18.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      fontStyle: theme.bodyMedium.fontStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
