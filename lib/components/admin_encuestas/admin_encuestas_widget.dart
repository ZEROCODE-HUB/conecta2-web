import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/dashboard/web/encuestas/crearencuesta/crearencuesta_widget.dart';
import '/dashboard/web/encuestas/model/editarencuesta2/editarencuesta2_widget.dart';
import '/dashboard/web/encuestas/resultados/resultados_widget.dart';
import '/dashboard/web/tamizajes/resultados_tami/resultados_tami_v2_widget.dart';
import '/dashboard/web/tamizajes/listado_tamizajes/listado_tamizajes_widget.dart';
import '/dashboard/web/encuestas/model/vista_previa_copy/vista_previa_copy_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'admin_encuestas_model.dart';
import 'widgets/encuestas_filters.dart';
import 'widgets/encuestas_list.dart';
export 'admin_encuestas_model.dart';

/// Administration widget for encuestas and tamizajes.
///
/// The [tipo] parameter selects between `'Encuestas'` and `'Tamizajes'`
/// and is used both for querying and for rendering labels.
class AdminEncuestasWidget extends StatefulWidget {
  const AdminEncuestasWidget({
    super.key,
    this.tipo,
  });

  final String? tipo;

  @override
  State<AdminEncuestasWidget> createState() => _AdminEncuestasWidgetState();
}

class _AdminEncuestasWidgetState extends State<AdminEncuestasWidget> {
  late AdminEncuestasModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminEncuestasModel());

    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  void _onStateChanged() => safeSetState(() {});

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    // Sub-routes handled via FFAppState().selectUser.
    final selectUser = FFAppState().selectUser;
    if (selectUser == 'Crearencuesta') {
      if (widget.tipo != null) {
        return wrapWithModel(
          model: _model.crearencuestaModel,
          updateCallback: _onStateChanged,
          updateOnChange: true,
          child: CrearencuestaWidget(
            encuestaID: _model.documentID,
            tipo: widget.tipo!,
          ),
        );
      }
    } else if (selectUser == 'Resultados') {
      if (_model.documentID != null) {
        return wrapWithModel(
          model: _model.resultadosModel,
          updateCallback: _onStateChanged,
          updateOnChange: true,
          child: ResultadosWidget(documentID: _model.documentID!),
        );
      }
    } else if (selectUser == 'ResultadosTamizaje') {
      if (_model.documentID != null) {
        return ResultadosTamiV2Widget(
          encuestaID: _model.documentID!,
          onClose: () {
            FFAppState().selectUser = '';
            safeSetState(() {});
          },
        );
      }
    } else if (selectUser == 'ListadoTamizajes') {
      return ListadoTamizajesWidget(
        onVolver: () {
          FFAppState().selectUser = '';
          safeSetState(() {});
        },
      );
    } else if (selectUser == 'VistaPrevia') {
      // Si venimos de creación el doc se acaba de persistir en el sub-model;
      // tomamos esa ref cuando `_model.documentID` es null.
      final previewRef =
          _model.documentID ?? _model.crearencuestaModel.encuestaPersistedRef;
      if (previewRef == null) return const SizedBox.shrink();
      return wrapWithModel(
        model: _model.vistaPreviaCopyModel,
        updateCallback: _onStateChanged,
        child: VistaPreviaCopyWidget(encuestaID: previewRef),
      );
    } else if (selectUser == 'Editar Encuesta') {
      if (_model.documentID != null &&
          _model.doc != null &&
          widget.tipo != null) {
        return wrapWithModel(
          model: _model.editarencuesta2Model,
          updateCallback: _onStateChanged,
          child: Editarencuesta2Widget(
            encuestaID: _model.documentID!,
            docencuestas2: _model.doc!,
            tipo: widget.tipo!,
          ),
        );
      }
    }

    return StreamBuilder<List<EncuestasRecord>>(
      stream: queryEncuestasRecord(
        queryBuilder: (encuestasRecord) => encuestasRecord
            .where('tipo', isEqualTo: widget.tipo)
            .orderBy('CreateAt', descending: true),
      ),
      builder: (context, snapshot) {
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
        final records = snapshot.data!;
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(50.0, 0.0, 50.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopBar(context),
                EncuestasFilters(
                  model: _model,
                  onStateChanged: _onStateChanged,
                ),
                const SizedBox(height: 20),
                EncuestasList(
                  model: _model,
                  tipo: widget.tipo ?? 'Encuestas',
                  allEncuestas: records,
                  onStateChanged: _onStateChanged,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              valueOrDefault<String>(widget.tipo, 'Encuestas'),
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCrearNuevoButton(context),
                const SizedBox(width: 25),
                if (widget.tipo == 'Tamizajes') ...[
                  _buildListadoTamizajesButton(context),
                  const SizedBox(width: 25),
                ],
                _buildUserBadge(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrearNuevoButton(BuildContext context) {
    return FFButtonWidget(
      onPressed: () async {
        // No creamos doc en Firestore hasta que el usuario presione Vista
        // Previa / Guardar como borrador / Publicar. Solo limpiamos estado.
        final cm = _model.crearencuestaModel;
        cm.encuestaPersistedRef = null;
        cm.preguntasBuffer.clear();
        cm.alertasEspeciales.clear();
        cm.roleValue = null;
        cm.roleValueController?.value = null;
        cm.categoriaValue = null;
        cm.categoriaValueController?.value = null;
        cm.tipoValue = null;
        cm.tipoValueController?.value = null;
        cm.textController1?.clear();
        cm.textController2?.clear();
        _model.documentID = null;
        _model.encuestaID = null;
        FFAppState().selectUser = 'Crearencuesta';
        safeSetState(() {});
      },
      text: 'Crear nuevo',
      options: FFButtonOptions(
        padding: const EdgeInsetsDirectional.fromSTEB(60.0, 20.0, 60.0, 20.0),
        iconPadding: EdgeInsetsDirectional.zero,
        color: FlutterFlowTheme.of(context).secondary,
        textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              color: const Color(0xFF265294),
              fontSize: 18.0,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w600,
            ),
        elevation: 0.0,
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }

  Widget _buildListadoTamizajesButton(BuildContext context) {
    return FFButtonWidget(
      onPressed: () {
        FFAppState().selectUser = 'ListadoTamizajes';
        safeSetState(() {});
      },
      text: 'Listado de Tamizajes',
      icon: const Icon(
        Icons.assignment_outlined,
        size: 18.0,
        color: Color(0xFF265294),
      ),
      options: FFButtonOptions(
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
        iconPadding: EdgeInsetsDirectional.zero,
        color: FlutterFlowTheme.of(context).secondary,
        textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              color: const Color(0xFF265294),
              fontSize: 14.0,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
        elevation: 0.0,
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }

  Widget _buildUserBadge(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AuthUserStreamWidget(
              builder: (context) => ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: CachedNetworkImage(
                  fadeInDuration: const Duration(milliseconds: 500),
                  fadeOutDuration: const Duration(milliseconds: 500),
                  imageUrl: valueOrDefault<String>(
                    currentUserPhoto,
                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/9yllj3p8hz5o/User.png',
                  ),
                  width: 30.0,
                  height: 30.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: AuthUserStreamWidget(
                builder: (context) => Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 28.0, 0.0),
                  child: Text(
                    currentUserDisplayName,
                    overflow: TextOverflow.ellipsis,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
