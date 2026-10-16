import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/footer_parents/footer_parents_widget.dart';
import '/components/list_card/list_card_widget.dart';
import '/components/profesional_header/profesional_header_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'aprendizaje_parents_model.dart';
export 'aprendizaje_parents_model.dart';

class AprendizajeParentsWidget extends StatefulWidget {
  const AprendizajeParentsWidget({super.key});

  static String routeName = 'AprendizajeParents';
  static String routePath = '/aprendizajeParents';

  @override
  State<AprendizajeParentsWidget> createState() =>
      _AprendizajeParentsWidgetState();
}

class _AprendizajeParentsWidgetState extends State<AprendizajeParentsWidget> {
  late AprendizajeParentsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AprendizajeParentsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 45.0, 0.0, 0.0),
                child: Container(
                  decoration: BoxDecoration(),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 100.0),
                    child: SingleChildScrollView(
                      primary: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 20.0),
                                    child: Text(
                                      'Bienvenidos al Módulo de Acudientes sección Artículos',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                            ),
                                            fontSize: 18.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 20.0),
                                    child: Text(
                                      'En esta sección encontrarán artículos informativos, consejos prácticos y estrategias para fortalecer la relación con sus hijos, comprender y manejar sus emociones, así como orientación para afrontar desafíos comunes en la crianza.',
                                      textAlign: TextAlign.justify,
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            font: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                            ),
                                            fontSize: 18.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 24.0, 0.0, 0.0),
                                    child: AuthUserStreamWidget(
                                      builder: (context) =>
                                          StreamBuilder<List<ContenidoRecord>>(
                                        stream: queryContenidoRecord(
                                          // Solo publicados (como adolescente
                                          // y profesional).
                                          queryBuilder: (contenidoRecord) =>
                                              contenidoRecord
                                                  .where('Publicado',
                                                      isEqualTo: true)
                                                  .where(
                                            'Roles',
                                            arrayContains: valueOrDefault(
                                                currentUserDocument?.rol, ''),
                                          ),
                                        ),
                                        builder: (context, snapshot) {
                                          // Customize what your widget looks like when it's loading.
                                          if (!snapshot.hasData) {
                                            return Center(
                                              child: SizedBox(
                                                width: 50.0,
                                                height: 50.0,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          List<ContenidoRecord>
                                              listViewContenidoRecordList =
                                              snapshot.data!;

                                          return ListView.separated(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount:
                                                listViewContenidoRecordList
                                                    .length,
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 8.0),
                                            itemBuilder:
                                                (context, listViewIndex) {
                                              final listViewContenidoRecord =
                                                  listViewContenidoRecordList[
                                                      listViewIndex];
                                              return InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.pushNamed(
                                                    AprendizajeParentsOpenWidget
                                                        .routeName,
                                                    queryParameters: {
                                                      'contenido':
                                                          serializeParam(
                                                        listViewContenidoRecord
                                                            .reference,
                                                        ParamType
                                                            .DocumentReference,
                                                      ),
                                                    }.withoutNulls,
                                                    extra: <String, dynamic>{
                                                      '__transition_info__':
                                                          TransitionInfo(
                                                        hasTransition: true,
                                                        transitionType:
                                                            PageTransitionType
                                                                .fade,
                                                        duration: Duration(
                                                            milliseconds: 0),
                                                      ),
                                                    },
                                                  );
                                                },
                                                child: ListCardWidget(
                                                  key: Key(
                                                      'Keybtx_${listViewIndex}_of_${listViewContenidoRecordList.length}'),
                                                  showImage: true,
                                                  titulo:
                                                      listViewContenidoRecord
                                                          .titulo,
                                                  imagen:
                                                      listViewContenidoRecord
                                                          .imageProfile,
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.footerParentsModel,
                  updateCallback: () => safeSetState(() {}),
                  updateOnChange: true,
                  child: FooterParentsWidget(
                    active: 3,
                  ),
                ),
              ),
              wrapWithModel(
                model: _model.profesionalHeaderModel,
                updateCallback: () => safeSetState(() {}),
                updateOnChange: true,
                child: ProfesionalHeaderWidget(
                  name: 'Literatura',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
