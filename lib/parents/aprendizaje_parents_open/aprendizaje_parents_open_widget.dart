import '/backend/backend.dart';
import '/components/header_prof_back/header_prof_back_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/contenido_html_view.dart';
import 'package:flutter/material.dart';
import 'aprendizaje_parents_open_model.dart';
export 'aprendizaje_parents_open_model.dart';

class AprendizajeParentsOpenWidget extends StatefulWidget {
  const AprendizajeParentsOpenWidget({
    super.key,
    this.contenido,
  });

  final DocumentReference? contenido;

  static String routeName = 'AprendizajeParentsOpen';
  static String routePath = '/aprendizajeParentsOpen';

  @override
  State<AprendizajeParentsOpenWidget> createState() =>
      _AprendizajeParentsOpenWidgetState();
}

class _AprendizajeParentsOpenWidgetState
    extends State<AprendizajeParentsOpenWidget> {
  late AprendizajeParentsOpenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AprendizajeParentsOpenModel());

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
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  wrapWithModel(
                    model: _model.headerProfBackModel,
                    updateCallback: () => safeSetState(() {}),
                    child: HeaderProfBackWidget(),
                  ),
                  StreamBuilder<ContenidoRecord>(
                    stream: ContenidoRecord.getDocument(widget.contenido!),
                    builder: (context, snapshot) {
                      // Customize what your widget looks like when it's loading.
                      if (!snapshot.hasData) {
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

                      final containerContenidoRecord = snapshot.data!;

                      return Container(
                        decoration: BoxDecoration(),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(7.0),
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1580377968103-84cadc052dc7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHw2fHxwYXJlbnRzfGVufDB8fHx8MTcxNDc2MTY0MXww&ixlib=rb-4.0.3&q=80&w=1080',
                                  width: double.infinity,
                                  height: 150.0,
                                  fit: BoxFit.fitWidth,
                                  alignment: Alignment(0.0, -1.0),
                                ),
                              ),
                              if (containerContenidoRecord.html != '')
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 20.0, 0.0, 0.0),
                                  // Altura del artículo (antes 2500 px
                                  // fijos con scroll propio: vacío al final).
                                  child: ContenidoHtmlView(
                                    html: containerContenidoRecord.html,
                                  ),
                                ),
                            ].divide(SizedBox(height: 20.0)),
                          ),
                        ),
                      );
                    },
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
