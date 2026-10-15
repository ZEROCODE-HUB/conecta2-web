import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/footer_professionals/footer_professionals_widget.dart';
import '/components/list_card/list_card_widget.dart';
import '/components/profesional_header/profesional_header_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'literatura_pro_model.dart';
export 'literatura_pro_model.dart';

class LiteraturaProWidget extends StatefulWidget {
  const LiteraturaProWidget({super.key});

  static String routeName = 'LiteraturaPro';
  static String routePath = '/literaturaPro';

  @override
  State<LiteraturaProWidget> createState() => _LiteraturaProWidgetState();
}

class _LiteraturaProWidgetState extends State<LiteraturaProWidget> {
  late LiteraturaProModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LiteraturaProModel());

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
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
                child: Container(
                  decoration: BoxDecoration(),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 100.0),
                    child: SingleChildScrollView(
                      primary: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 30.0),
                                  child: Text(
                                    'En esta sección encontrarán artículos informativos, consejos prácticos y estrategias en la educación y tratamiento de adolescentes.',
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
                                AuthUserStreamWidget(
                                  builder: (context) => PagedListView<
                                      DocumentSnapshot<Object?>?,
                                      ContenidoRecord>.separated(
                                    pagingController:
                                        _model.setListViewController(
                                      ContenidoRecord.collection
                                          .where('Publicado', isEqualTo: true)
                                          .where(
                                        'Roles',
                                        arrayContains: valueOrDefault(
                                            currentUserDocument?.rol, ''),
                                      ),
                                    ),
                                    padding: EdgeInsets.zero,
                                    primary: false,
                                    shrinkWrap: true,
                                    reverse: false,
                                    scrollDirection: Axis.vertical,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 5.0),
                                    builderDelegate: PagedChildBuilderDelegate<
                                        ContenidoRecord>(
                                      // Customize what your widget looks like when it's loading the first page.
                                      firstPageProgressIndicatorBuilder: (_) =>
                                          Center(
                                        child: SizedBox(
                                          width: 50.0,
                                          height: 50.0,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Customize what your widget looks like when it's loading another page.
                                      newPageProgressIndicatorBuilder: (_) =>
                                          Center(
                                        child: SizedBox(
                                          width: 50.0,
                                          height: 50.0,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      ),

                                      itemBuilder: (context, _, listViewIndex) {
                                        final listViewContenidoRecord = _model
                                            .listViewPagingController!
                                            .itemList![listViewIndex];
                                        return InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            context.pushNamed(
                                              LiteraturaProOpenWidget.routeName,
                                              queryParameters: {
                                                'contenidoID': serializeParam(
                                                  listViewContenidoRecord
                                                      .reference,
                                                  ParamType.DocumentReference,
                                                ),
                                              }.withoutNulls,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                  hasTransition: true,
                                                  transitionType:
                                                      PageTransitionType.fade,
                                                  duration:
                                                      Duration(milliseconds: 0),
                                                ),
                                              },
                                            );
                                          },
                                          child: ListCardWidget(
                                            key: Key(
                                                'Keybf8_${listViewIndex}_of_${_model.listViewPagingController!.itemList!.length}'),
                                            showImage: true,
                                            titulo:
                                                listViewContenidoRecord.titulo,
                                            imagen: listViewContenidoRecord
                                                .imageProfile,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.footerProfessionalsModel,
                  updateCallback: () => safeSetState(() {}),
                  updateOnChange: true,
                  child: FooterProfessionalsWidget(
                    active: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
