import '/backend/backend.dart';
import '/components/header_prof_back/header_prof_back_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/contenido_html_view.dart';
import 'package:flutter/material.dart';
import 'literatura_pro_open_model.dart';
export 'literatura_pro_open_model.dart';

class LiteraturaProOpenWidget extends StatefulWidget {
  const LiteraturaProOpenWidget({
    super.key,
    required this.contenidoID,
  });

  final DocumentReference? contenidoID;

  static String routeName = 'LiteraturaProOpen';
  static String routePath = '/literaturaProOpen';

  @override
  State<LiteraturaProOpenWidget> createState() =>
      _LiteraturaProOpenWidgetState();
}

class _LiteraturaProOpenWidgetState extends State<LiteraturaProOpenWidget> {
  late LiteraturaProOpenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LiteraturaProOpenModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ContenidoRecord>(
      stream: ContenidoRecord.getDocument(widget.contenidoID!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        final literaturaProOpenContenidoRecord = snapshot.data!;

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
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
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
                      Container(
                        decoration: BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (literaturaProOpenContenidoRecord.imageProfile !=
                                    '')
                              ClipRRect(
                                borderRadius: BorderRadius.circular(7.0),
                                child: Image.network(
                                  literaturaProOpenContenidoRecord.imageProfile,
                                  width: double.infinity,
                                  height: 150.0,
                                  fit: BoxFit.fitWidth,
                                  alignment: Alignment(0.0, -1.0),
                                ),
                              ),
                          ].divide(SizedBox(height: 20.0)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 20.0, 0.0, 40.0),
                        // Altura del artículo (antes 2500 px fijos con
                        // scroll propio).
                        child: ContenidoHtmlView(
                          html: literaturaProOpenContenidoRecord.html,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
