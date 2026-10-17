import '/backend/backend.dart';
import '/tamizajes/shared/tamizaje_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/resultados/resultados_model.dart';
import 'widgets/resultado_card.dart';
import 'widgets/resultado_filters.dart';
import 'widgets/resultado_notas.dart';

export '../model/resultados/resultados_model.dart';

class ResultadosWidget extends StatefulWidget {
  const ResultadosWidget({
    super.key,
    required this.documentID,
    this.onClose,
  });

  final DocumentReference? documentID;

  /// Flecha "volver". Sin callback limpia `FFAppState().selectUser`, que en
  /// la sección Encuestas regresa al listado; fuera de ella (p. ej. el
  /// perfil del profesional) se pasa uno propio.
  final VoidCallback? onClose;

  @override
  State<ResultadosWidget> createState() => _ResultadosWidgetState();
}

class _ResultadosWidgetState extends State<ResultadosWidget> {
  late ResultadosModel _model;

  /// Usuarios cuyas respuestas se muestran; null = todos (no profesional).
  late Future<Set<DocumentReference>?> _visibles;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResultadosModel());
    _visibles = TamizajeService.refsVisiblesParaProfesional();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  void _selectPregunta({required String? tipo, required String? pregunta, required int index}) {
    _model.tipo2 = tipo;
    _model.pregunta = pregunta;
    _model.itemlist = index;
    safeSetState(() {});
  }

  void _resetPregunta() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      FFAppState().selectUser = '';
    }
    safeSetState(() {});
    _model.tipo2 = null;
    _model.pregunta = null;
    _model.itemlist = null;
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EncuestasRecord>(
      stream: EncuestasRecord.getDocument(widget.documentID!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _loader(context);
        }
        final encuesta = snapshot.data!;
        return Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
          ),
          child: SingleChildScrollView(
            primary: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: FutureBuilder<Set<DocumentReference>?>(
                          future: _visibles,
                          builder: (context, visiblesSnap) {
                            if (visiblesSnap.connectionState !=
                                ConnectionState.done) {
                              return _loader(context);
                            }
                            // Si no se pudo leer la asignación, un
                            // profesional no ve respuestas de nadie.
                            final visibles = visiblesSnap.hasError
                                ? <DocumentReference>{}
                                : visiblesSnap.data;
                            return StreamBuilder<List<RespuestasRecord>>(
                          stream: queryRespuestasRecord(parent: widget.documentID),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return _loader(context);
                            }
                            // Un profesional solo ve las respuestas de sus
                            // adolescentes asignados (y las suyas).
                            final respuestas = visibles == null
                                ? snapshot.data!
                                : snapshot.data!
                                    .where((r) => visibles
                                        .contains(r.userRespuesta))
                                    .toList();
                            return Container(
                              height: MediaQuery.sizeOf(context).height,
                              decoration: const BoxDecoration(),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    40, 20, 40, 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ResultadoFilters(onReset: _resetPregunta),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            0, 45, 0, 0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: _PreguntasPanel(
                                                encuesta: encuesta,
                                                respuestas: respuestas,
                                                model: _model,
                                                onSelect: _selectPregunta,
                                              ),
                                            ),
                                            ResultadoNotas(
                                              respuestas: respuestas,
                                              pregunta: _model.pregunta,
                                              tipo: _model.tipo2,
                                              itemIndex: _model.itemlist,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _loader(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 50.0,
        height: 50.0,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            FlutterFlowTheme.of(context).primary,
          ),
        ),
      ),
    );
  }
}

/// Left-hand panel that lists every question in the encuesta and renders
/// a type-specific preview for each. Delegates individual question
/// rendering to [ResultadoPreguntaItem].
class _PreguntasPanel extends StatelessWidget {
  const _PreguntasPanel({
    required this.encuesta,
    required this.respuestas,
    required this.model,
    required this.onSelect,
  });

  final EncuestasRecord encuesta;
  final List<RespuestasRecord> respuestas;
  final ResultadosModel model;
  final PreguntaSelected onSelect;

  @override
  Widget build(BuildContext context) {
    final bodyMedium = FlutterFlowTheme.of(context).bodyMedium;
    final preguntas = encuesta.preguntas.toList();
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.7,
      height: MediaQuery.sizeOf(context).height,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            blurRadius: 50.0,
            color: Color(0x26000000),
            offset: Offset(20, 20),
          ),
        ],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                child: Text(
                  encuesta.titulo,
                  style: bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle: bodyMedium.fontStyle,
                    ),
                    fontSize: 24.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                child: Text(
                  encuesta.descripcion,
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
              ),
              ...List.generate(preguntas.length, (index) {
                final item = preguntas[index];
                return ResultadoPreguntaItem(
                  pregunta: item,
                  index: index,
                  respuestasCount: respuestas.length,
                  respuestasCountEncuesta: functions.countEncuesta(
                        respuestas
                            .map((e) => e.userRespuesta?.id)
                            .withoutNulls
                            .toList(),
                      ) ??
                      '0',
                  onTap: () => onSelect(
                    tipo: item.tipo,
                    pregunta: item.pregunta,
                    index: index,
                  ),
                  tamizajeCheckboxMap: model.checkboxValueMap1,
                  seleccionCheckboxMap: model.checkboxValueMap2,
                  onTamizajeChanged: (k, v) {
                    model.checkboxValueMap1[k] = v;
                  },
                  onSeleccionChanged: (k, v) {
                    model.checkboxValueMap2[k] = v;
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
