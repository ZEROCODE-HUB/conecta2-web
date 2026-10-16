import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A tappable question title with a count suffix. Used as the header of
/// every question block in the results list.
class ResultadoPreguntaHeader extends StatelessWidget {
  const ResultadoPreguntaHeader({
    super.key,
    required this.pregunta,
    required this.countLabel,
    required this.onTap,
    this.textAlign,
  });

  final String pregunta;
  final String countLabel;
  final VoidCallback onTap;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final bodyMedium = FlutterFlowTheme.of(context).bodyMedium;
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: RichText(
        textScaler: MediaQuery.of(context).textScaler,
        textAlign: textAlign ?? TextAlign.start,
        text: TextSpan(
          style: bodyMedium.override(
            font: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontStyle: bodyMedium.fontStyle,
            ),
            fontSize: 18.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(text: pregunta),
            TextSpan(
              text: ' ($countLabel repuestas)',
              style: const TextStyle(
                color: Color(0xFF265294),
                fontWeight: FontWeight.w500,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Styled option row used inside "Tamizaje" and "selección" blocks.
class ResultadoOptionRow extends StatelessWidget {
  const ResultadoOptionRow({
    super.key,
    required this.label,
    required this.trailingText,
    this.showCheckbox = true,
    this.checkboxValue,
    this.onCheckboxChanged,
  });

  final String label;
  final String trailingText;
  final bool showCheckbox;
  final bool? checkboxValue;
  final ValueChanged<bool?>? onCheckboxChanged;

  @override
  Widget build(BuildContext context) {
    final bodyMedium = FlutterFlowTheme.of(context).bodyMedium;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        height: 47.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: const [
            BoxShadow(
              blurRadius: 20.0,
              color: Color(0x27000000),
              offset: Offset(5.0, 5.0),
            ),
          ],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: const Color(0xFF6E98D7), width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (showCheckbox)
                Theme(
                  data: ThemeData(
                    checkboxTheme: CheckboxThemeData(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    unselectedWidgetColor:
                        FlutterFlowTheme.of(context).secondaryText,
                  ),
                  child: Checkbox(
                    value: checkboxValue ?? false,
                    onChanged: onCheckboxChanged,
                    side: BorderSide(
                      width: 2,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                    activeColor: const Color(0xFF265294),
                    checkColor: FlutterFlowTheme.of(context).info,
                  ),
                ),
              RichText(
                textScaler: MediaQuery.of(context).textScaler,
                text: TextSpan(
                  style: bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: bodyMedium.fontWeight,
                      fontStyle: bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                  ),
                  children: [
                    TextSpan(
                      text: label,
                      style: bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontStyle: bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '-',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF265294),
                        fontWeight: FontWeight.w600,
                        fontSize: 18.0,
                      ),
                    ),
                    TextSpan(
                      text: trailingText,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF265294),
                        fontWeight: FontWeight.w600,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A Verdadero/Falso selector (display-only) used in the results list.
class ResultadoTrueFalseRow extends StatelessWidget {
  const ResultadoTrueFalseRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _booleanCard(context, label: 'Verdadero'),
          const SizedBox(width: 10),
          _booleanCard(context, label: 'Falso'),
        ],
      ),
    );
  }

  Widget _booleanCard(BuildContext context, {required String label}) {
    final bodyMedium = FlutterFlowTheme.of(context).bodyMedium;
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 20.0,
            color: Color(0x27000000),
            offset: Offset(5.0, 5.0),
          ),
        ],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFF6E98D7), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Theme(
              data: ThemeData(
                checkboxTheme: CheckboxThemeData(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                unselectedWidgetColor:
                    FlutterFlowTheme.of(context).secondaryText,
              ),
              child: Checkbox(
                value: true,
                onChanged: null,
                side: BorderSide(
                  width: 2,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
                activeColor: const Color(0xFF265294),
                checkColor: null,
              ),
            ),
            Text(
              label,
              style: bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontStyle: bodyMedium.fontStyle,
                ),
                fontSize: 18.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Callback fired when the user taps a question header to filter results.
typedef PreguntaSelected = void Function({
  required String? tipo,
  required String? pregunta,
  required int index,
});

/// Renders one item in the list of questions on the left side of the
/// resultados page, delegating visual style based on [pregunta.tipo].
class ResultadoPreguntaItem extends StatelessWidget {
  const ResultadoPreguntaItem({
    super.key,
    required this.pregunta,
    required this.index,
    required this.respuestasCount,
    required this.respuestasCountEncuesta,
    required this.onTap,
    required this.tamizajeCheckboxMap,
    required this.seleccionCheckboxMap,
    required this.onTamizajeChanged,
    required this.onSeleccionChanged,
  });

  final PreguntasEncuestaStruct pregunta;
  final int index;
  final int respuestasCount;
  final String respuestasCountEncuesta;
  final VoidCallback onTap;
  final Map<AtributosStruct, bool> tamizajeCheckboxMap;
  final Map<String, bool> seleccionCheckboxMap;
  final void Function(AtributosStruct, bool) onTamizajeChanged;
  final void Function(String, bool) onSeleccionChanged;

  @override
  Widget build(BuildContext context) {
    final tipo = pregunta.tipo;
    final header = ResultadoPreguntaHeader(
      pregunta: pregunta.pregunta,
      countLabel: tipo == 'Verdadero o falso'
          ? respuestasCountEncuesta
          : respuestasCount.toString(),
      onTap: onTap,
    );

    switch (tipo) {
      case 'Tamizaje':
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              ...pregunta.respuestaTamizaje.map(
                (item) => ResultadoOptionRow(
                  label: item.etiqueta,
                  trailingText: item.valor.toString(),
                  checkboxValue: tamizajeCheckboxMap[item] ?? false,
                  onCheckboxChanged: (v) => onTamizajeChanged(item, v ?? false),
                ),
              ),
            ],
          ),
        );
      case 'Condicionante':
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [header],
          ),
        );
      case 'abiertas':
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Align(
                    alignment: const AlignmentDirectional(-1.0, 0.0),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                      child: Text(
                        'Escribe tu repuesta',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: const Color(0xFF9E8888),
                              fontSize: 18.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'selección':
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              ...pregunta.respuestaSelection.map(
                (item) => ResultadoOptionRow(
                  label: item,
                  trailingText: 'Pronto',
                  checkboxValue: seleccionCheckboxMap[item] ?? true,
                  onCheckboxChanged: (v) => onSeleccionChanged(item, v ?? false),
                ),
              ),
            ],
          ),
        );
      case 'Selección única':
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              ...pregunta.respuestasSeleccionUnica.map(
                (item) => ResultadoOptionRow(
                  label: item,
                  trailingText: 'Pronto',
                  showCheckbox: false,
                ),
              ),
            ],
          ),
        );
      case 'Verdadero o falso':
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const ResultadoTrueFalseRow(),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

