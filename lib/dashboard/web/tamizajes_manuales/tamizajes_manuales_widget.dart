import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/tamizajes/shared/widgets/detalle_tamizaje_view.dart';
import '/tamizajes/shared/widgets/tamizaje_search_bar.dart';
import 'widgets/tamizajes_manuales_header.dart';
import 'widgets/tamizajes_manuales_list_stream.dart';
import 'wizard_tamizaje_manual.dart';
import 'tamizajes_manuales_model.dart';
export 'tamizajes_manuales_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Pantalla principal "Tamizajes Manuales" para el perfil Profesional.
///
/// Maneja 3 vistas: listado, wizard de creación, y detalle de un tamizaje.
class TamizajesManualesWidget extends StatefulWidget {
  const TamizajesManualesWidget({super.key});

  @override
  State<TamizajesManualesWidget> createState() =>
      _TamizajesManualesWidgetState();
}

enum _Vista { list, wizard, detalle }

class _TamizajesManualesWidgetState extends State<TamizajesManualesWidget> {
  late TamizajesManualesModel _model;
  _Vista _vista = _Vista.list;

  RespuestasRecord? _detalleRespuesta;
  UsersRecord? _detalleAdolescente;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TamizajesManualesModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  void _abrirWizard() => setState(() => _vista = _Vista.wizard);
  void _cerrarWizard() => setState(() => _vista = _Vista.list);

  void _abrirDetalle(RespuestasRecord respuesta, UsersRecord? adolescente) {
    setState(() {
      _vista = _Vista.detalle;
      _detalleRespuesta = respuesta;
      _detalleAdolescente = adolescente;
    });
  }

  void _cerrarDetalle() {
    setState(() {
      _vista = _Vista.list;
      _detalleRespuesta = null;
      _detalleAdolescente = null;
    });
  }

  /// Maneja el botón atrás del navegador.
  bool _onPopInvoked() {
    if (_vista == _Vista.detalle) {
      _cerrarDetalle();
      return false; // no dejar que el navegador haga pop
    }
    if (_vista == _Vista.wizard) {
      _cerrarWizard();
      return false;
    }
    return true; // en list, dejar que fluya normal
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);
    final profesionalRef = currentUserReference;

    final bool canPop = _vista == _Vista.list;

    Widget content;

    if (_vista == _Vista.wizard) {
      content = WizardTamizajeManualWidget(onClose: _cerrarWizard);
    } else if (_vista == _Vista.detalle && _detalleRespuesta != null) {
      content = DetalleTamizajeView(
        respuesta: _detalleRespuesta!,
        adolescente: _detalleAdolescente,
        onVolver: _cerrarDetalle,
      );
    } else {
      content = _buildListado(theme, profesionalRef);
    }

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onPopInvoked();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(_vista),
          child: content,
        ),
      ),
    );
  }

  Widget _buildListado(FlutterFlowTheme theme, DocumentReference? profesionalRef) {
    final isAdmin = valueOrDefault(currentUserDocument?.rol, '') == 'Administrador';

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.primaryBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TamizajesManualesHeader(onNuevo: _abrirWizard),
          TamizajeSearchBar(
            controller: _model.searchController,
            focusNode: _model.searchFocusNode,
            ordenDescendente: _model.ordenDescendente,
            onChangedSearch: (v) {
               setState(() {
                 _model.busqueda = v;
                 _model.paginaActual = 0;
               });
            },
            onToggleOrden: () {
               setState(() {
                 _model.ordenDescendente = !_model.ordenDescendente;
                 _model.paginaActual = 0;
               });
            },
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: profesionalRef == null
                ? Center(
                    child:
                        Text('No hay sesión activa', style: theme.bodyMedium))
                : TamizajesManualesListStream(
                    profesionalRef: profesionalRef,
                    busqueda: _model.busqueda,
                    ordenDescendente: _model.ordenDescendente,
                    paginaActual: _model.paginaActual,
                    onCambiarPagina: (p) =>
                        setState(() => _model.paginaActual = p),
                    onVerDetalle: _abrirDetalle,
                    isAdmin: isAdmin,
                  ),
          ),
        ],
      ),
    );
  }
}
