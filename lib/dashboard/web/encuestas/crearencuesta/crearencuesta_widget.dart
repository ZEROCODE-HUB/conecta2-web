import '/tamizajes/shared/assist_utils.dart' show limpiarAlertasAssist;
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'crearencuesta_model.dart';
import 'components/datos_principales_widget.dart';
import 'components/nueva_pregunta_widget.dart';
import 'components/panel_preguntas_widget.dart';
import 'components/sidebar_acciones_widget.dart';

export 'crearencuesta_model.dart';

class CrearencuestaWidget extends StatefulWidget {
  const CrearencuestaWidget({
    super.key,
    required this.encuestaID,
    required this.tipo,
  });

  final DocumentReference? encuestaID;
  final String? tipo;

  @override
  State<CrearencuestaWidget> createState() => _CrearencuestaWidgetState();
}

class _CrearencuestaWidgetState extends State<CrearencuestaWidget> {
  late CrearencuestaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CrearencuestaModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Plantilla de alertas por sustancia sin entradas basura ("Hello World").
      FFAppState().listaAlertasEnvio = limpiarAlertasAssist(
          FFAppState().listaAlertas.toList().cast<AlertaStruct>());
      safeSetState(() {});
    });

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.preguntaTextController1 ??= TextEditingController();
    _model.preguntaFocusNode1 ??= FocusNode();

    _model.preguntaTextController2 ??= TextEditingController();
    _model.preguntaFocusNode2 ??= FocusNode();

    _model.abiertaTextController ??= TextEditingController();
    _model.abiertaFocusNode ??= FocusNode();

    _model.selection1TextController1 ??= TextEditingController();
    _model.selection1FocusNode1 ??= FocusNode();

    _model.selection1TextController2 ??= TextEditingController();
    _model.selection1FocusNode2 ??= FocusNode();

    _model.selection1TextController3 ??= TextEditingController();
    _model.selection1FocusNode3 ??= FocusNode();

    _model.valor1TextController ??= TextEditingController();
    _model.valor1FocusNode ??= FocusNode();

    _model.selectionunica1TextController ??= TextEditingController();
    _model.selectionunica1FocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header avec profil
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(40.0, 20.0, 40.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      onTap: () async {
                        FFAppState().selectUser = "";
                        _model.updatePage(() {});
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          "assets/images/Down.png",
                          width: 26.0,
                          height: 26.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                      child: Container(
                        width: 30.0,
                        height: 30.0,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: CachedNetworkImage(
                          imageUrl: valueOrDefault<String>(
                            currentUserPhoto,
                            "https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/9yllj3p8hz5o/User.png",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                      child: AuthUserStreamWidget(
                        builder: (context) => Text(
                          currentUserDisplayName,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Inter',
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(40.0, 45.0, 40.0, 40.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Form Panel
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 50.0,
                              color: Color(0x26000000),
                              offset: Offset(20.0, 20.0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DatosPrincipalesWidget(
                                model: _model,
                                onUpdate: () => safeSetState(() {}),
                              ),
                              NuevaPreguntaWidget(
                                model: _model,
                                onUpdate: () => safeSetState(() {}),
                              ),
                              PanelPreguntasWidget(
                                model: _model,
                                onUpdate: () => safeSetState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    // Sidebar
                    SidebarAccionesWidget(
                      model: _model,
                      tipo: widget.tipo,
                      onUpdate: () => safeSetState(() {}),
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
