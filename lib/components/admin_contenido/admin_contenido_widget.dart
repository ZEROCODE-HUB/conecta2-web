import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/dashboard/web/contenido/model/crearcontenido/crearcontenido_widget.dart';
import '/dashboard/web/contenido/model/editar_contenido/editar_contenido_widget.dart';
import '/dashboard/web/contenido/model/vistaprevia_contenido/vistaprevia_contenido_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

import 'admin_contenido_model.dart';
import 'widgets/contenido_filters.dart';
import 'widgets/contenido_list.dart';

export 'admin_contenido_model.dart';

/// Admin "Contenido" widget: lists, filters and creates/edits Contenido items.
///
/// Hosts three inner flows depending on [FFAppState().selectUser]:
///   * `CrearContenido`   → [CrearcontenidoWidget]
///   * `Contenidoprevia`  → [VistapreviaContenidoWidget]
///   * `EditarContenido`  → [EditarContenidoWidget]
///   * anything else      → the list (filters + [ContenidoList]).
class AdminContenido2Widget extends StatefulWidget {
  const AdminContenido2Widget({super.key});

  @override
  State<AdminContenido2Widget> createState() => _AdminContenido2WidgetState();
}

class _AdminContenido2WidgetState extends State<AdminContenido2Widget> {
  late AdminContenido2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminContenido2Model());
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  void _openEdit(ContenidoRecord item) {
    // Formulario limpio y texto del contenido abierto (no el del anterior).
    _model.editarContenidoModel.reiniciar();
    FFAppState().HTML = item.html;
    _model.documentID = item.reference;
    FFAppState().selectUser = 'EditarContenido';
    safeSetState(() {});
  }

  void _openPreview(ContenidoRecord item) {
    _model.origenPrevia = '';
    FFAppState().selectUser = 'Contenidoprevia';
    _model.documentID = item.reference;
    safeSetState(() {});
  }

  /// Reserva el id del contenido nuevo; el documento se crea al guardar
  /// como borrador o publicar (antes se creaba al instante con título
  /// "Vacío" y quedaba vacío si se salía sin guardar).
  void _crearContenido() {
    _model.crearcontenidoModel.reiniciar();
    FFAppState().HTML = '';
    _model.documentID = ContenidoRecord.collection.doc();
    FFAppState().selectUser = 'CrearContenido';
    safeSetState(() {});
  }

  /// Contenido sin guardar que muestra la vista previa abierta desde Crear o
  /// Editar. `null` desde el listado (se lee de Firestore).
  ContenidoRecord? get _contenidoPrevia {
    switch (_model.origenPrevia) {
      case 'EditarContenido':
        return _model.editarContenidoModel.previa;
      case 'CrearContenido':
        return _model.crearcontenidoModel.previa;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final selected = FFAppState().selectUser;
    // La vista previa vuelve a la vista desde la que se abrió.
    if (selected != 'Contenidoprevia') {
      _model.origenPrevia =
          selected == 'CrearContenido' || selected == 'EditarContenido'
              ? selected
              : '';
    }

    if (selected == 'CrearContenido') {
      return wrapWithModel(
        model: _model.crearcontenidoModel,
        updateCallback: () => safeSetState(() {}),
        updateOnChange: true,
        child: CrearcontenidoWidget(contenidoID: _model.documentID!),
      );
    } else if (selected == 'Contenidoprevia') {
      return wrapWithModel(
        model: _model.vistapreviaContenidoModel,
        updateCallback: () => safeSetState(() {}),
        updateOnChange: true,
        child: VistapreviaContenidoWidget(
          continidoID: _model.documentID!,
          contenido: _contenidoPrevia,
          onVolver: () {
            FFAppState().selectUser = _model.origenPrevia;
            safeSetState(() {});
          },
        ),
      );
    } else if (selected == 'EditarContenido') {
      return wrapWithModel(
        model: _model.editarContenidoModel,
        updateCallback: () => safeSetState(() {}),
        updateOnChange: true,
        child: EditarContenidoWidget(contenidoID: _model.documentID!),
      );
    }

    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return StreamBuilder<List<ContenidoRecord>>(
      stream: queryContenidoRecord(
        queryBuilder: (q) => q.orderBy('CreateAt', descending: true),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
              ),
            ),
          );
        }
        final records = snapshot.data!;

        return Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(color: theme.primaryBackground),
          child: Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(50.0, 0.0, 50.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderRow(context, theme),
                ContenidoFilters(
                  model: _model,
                  onChanged: () => safeSetState(() {}),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    primary: false,
                    child: ContenidoList(
                      allRecords: records,
                      simpleSearchResults: _model.simpleSearchResults,
                      isShowFullList: _model.isShowFullList,
                      publishedFilter: _model.dropDownValue1,
                      rolesFilter: _model.dropDownValue2,
                      onPreview: _openPreview,
                      onEdit: _openEdit,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              'Contenido',
              style: theme.titleLarge.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontStyle: theme.titleLarge.fontStyle,
                ),
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
                fontStyle: theme.titleLarge.fontStyle,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              FFButtonWidget(
                onPressed: _crearContenido,
                text: 'Crear Contenido',
                options: FFButtonOptions(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      60.0, 20.0, 60.0, 20.0),
                  iconPadding: EdgeInsetsDirectional.zero,
                  color: theme.secondary,
                  textStyle: theme.bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle: theme.bodyMedium.fontStyle,
                    ),
                    color: const Color(0xFF265294),
                    fontSize: 18.0,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                    fontStyle: theme.bodyMedium.fontStyle,
                  ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              const SizedBox(width: 25.0),
              _buildUserPill(context, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserPill(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
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
                  errorWidget: (context, url, error) => Container(
                    width: 30.0,
                    height: 30.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 20.0,
                      color: Color(0xFF265294),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            AuthUserStreamWidget(
              builder: (context) => Text(
                currentUserDisplayName,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontStyle: theme.bodyMedium.fontStyle,
                  ),
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: theme.bodyMedium.fontStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
