import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/tamizajes/shared/tamizaje_service.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/widgets/tamizaje_empty_state.dart';
import '/tamizajes/shared/widgets/tamizaje_page_header.dart';
import '/tamizajes/shared/widgets/tamizaje_paginador.dart';
import '/tamizajes/shared/widgets/tamizaje_search_bar.dart';
import 'widgets/detalle_encuesta_view.dart';
import 'widgets/encuesta_filtro.dart';
import 'widgets/tabla_encuestas.dart';
import 'listado_encuestas_model.dart';
export 'listado_encuestas_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Roles cuyas respuestas aparecen en el Listado de Encuestas.
///
/// Para incluir acudientes o profesionales basta con añadir su rol aquí
/// (`FFAppConstants.Role`) y, si se quiere distinguirlos, una columna o
/// filtro "Rol" en [TablaEncuestas].
const List<String> kRolesListadoEncuestas = [FFAppConstants.adolescente];

/// Listado de respuestas a encuestas (`Encuestas.tipo == 'Encuestas'`).
///
/// Es el único listado de estas respuestas: no se mezclan con Tamizajes,
/// Tamizajes Manuales, Estadísticas ni los PDF por usuario. Una respuesta
/// pertenece a una encuesta si su documento padre (`Encuestas/{id}`) tiene
/// `tipo == 'Encuestas'`.
class ListadoEncuestasWidget extends StatefulWidget {
  const ListadoEncuestasWidget({super.key, this.onVolver});

  final VoidCallback? onVolver;

  @override
  State<ListadoEncuestasWidget> createState() =>
      _ListadoEncuestasWidgetState();
}

class _ListadoEncuestasWidgetState extends State<ListadoEncuestasWidget> {
  late ListadoEncuestasModel _model;

  RespuestasRecord? _detalleRespuesta;

  /// id de encuesta → encuesta, solo `tipo == 'Encuestas'`.
  Map<String, EncuestasRecord>? _encuestasPorId;

  /// Cache de usuarios que respondieron (null = no se pudo leer).
  final Map<DocumentReference, UsersRecord?> _usuariosCache = {};

  Future<void> _cargarEncuestas() async {
    try {
      final encuestas = await queryEncuestasRecordOnce(
        queryBuilder: (q) => q.where('tipo', isEqualTo: 'Encuestas'),
      );
      if (!mounted) return;
      setState(() {
        _encuestasPorId = {for (final e in encuestas) e.reference.id: e};
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _encuestasPorId = {});
    }
  }

  Future<Map<DocumentReference, UsersRecord?>> _cargarUsuarios(
      Iterable<DocumentReference> refs) async {
    final faltantes =
        refs.where((r) => !_usuariosCache.containsKey(r)).toSet();
    if (faltantes.isNotEmpty) {
      final entries = await Future.wait(faltantes.map((ref) async {
        try {
          return MapEntry(ref, await UsersRecord.getDocumentOnce(ref));
        } catch (_) {
          return MapEntry<DocumentReference, UsersRecord?>(ref, null);
        }
      }));
      _usuariosCache.addAll(Map.fromEntries(entries));
    }
    return _usuariosCache;
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ListadoEncuestasModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
    _cargarEncuestas();
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  void _volver() {
    if (widget.onVolver != null) {
      widget.onVolver!();
    } else {
      FFAppState().update(() {
        FFAppState().selectUser = '';
      });
    }
  }

  void _cerrarDetalle() => setState(() => _detalleRespuesta = null);

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);
    final detalle = _detalleRespuesta;

    final Widget content = detalle != null
        ? DetalleEncuestaView(
            key: const ValueKey('detalle'),
            respuesta: detalle,
            usuario: _usuariosCache[detalle.userRespuesta],
            onVolver: _cerrarDetalle,
          )
        : _buildListado(theme);

    return PopScope(
      canPop: detalle == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && detalle != null) _cerrarDetalle();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: content,
      ),
    );
  }

  Widget _cargando() => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kNavy),
        ),
      );

  Widget _buildListado(FlutterFlowTheme theme) {
    final encuestas = _encuestasPorId;
    final opcionesEncuesta = (encuestas?.values.toList() ?? [])
      ..sort((a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));

    return Container(
      key: const ValueKey('listado'),
      width: double.infinity,
      height: double.infinity,
      color: theme.primaryBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TamizajePageHeader(
            titulo: 'Listado de Encuestas Completadas',
            breadcrumb: 'Volver a Encuestas',
            onVolver: _volver,
            icon: Icons.list_alt_rounded,
          ),
          TamizajeSearchBar(
            controller: _model.searchController,
            focusNode: _model.searchFocusNode,
            ordenDescendente: _model.ordenDescendente,
            hintText: 'Buscar por nombre del adolescente o encuesta…',
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
          EncuestaFiltro(
            encuestas: opcionesEncuesta,
            encuestaId: _model.filtroEncuestaId,
            onChanged: (id) {
              setState(() {
                _model.filtroEncuestaId = id;
                _model.paginaActual = 0;
              });
            },
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: encuestas == null
                ? _cargando()
                : StreamBuilder<List<RespuestasRecord>>(
                    stream: queryRespuestasRecord(queryBuilder: (q) => q),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return _cargando();

                      // Solo respuestas cuyo padre es una encuesta.
                      final respuestas = snapshot.data!.where((r) {
                        final padre = r.reference.parent.parent;
                        if (padre == null ||
                            padre.parent.id != 'Encuestas' ||
                            !encuestas.containsKey(padre.id)) {
                          return false;
                        }
                        return _model.filtroEncuestaId == null ||
                            padre.id == _model.filtroEncuestaId;
                      }).toList();

                      final refs = respuestas
                          .map((r) => r.userRespuesta)
                          .whereType<DocumentReference>();

                      return FutureBuilder<
                          Map<DocumentReference, UsersRecord?>>(
                        future: _cargarUsuarios(refs),
                        builder: (context, usersSnap) {
                          if (!usersSnap.hasData) return _cargando();
                          final usuarios = usersSnap.data!;
                          return _buildTabla(respuestas, usuarios);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabla(
    List<RespuestasRecord> respuestas,
    Map<DocumentReference, UsersRecord?> usuarios,
  ) {
    final q = _model.busqueda.trim().toLowerCase();
    // Un profesional solo ve las respuestas de sus adolescentes asignados.
    final esProfesional = valueOrDefault(currentUserDocument?.rol, '') ==
        FFAppConstants.Profesional;
    final filtradas = respuestas.where((r) {
      final usuario = usuarios[r.userRespuesta];
      if (usuario == null || !kRolesListadoEncuestas.contains(usuario.rol)) {
        return false;
      }
      if (esProfesional &&
          usuario.profesionales.ref != currentUserReference) {
        return false;
      }
      if (q.isEmpty) return true;
      return r.titlo.toLowerCase().contains(q) ||
          usuario.displayName.toLowerCase().contains(q);
    }).toList();

    TamizajeService.ordenarPorFecha(filtradas,
        descendente: _model.ordenDescendente);

    if (filtradas.isEmpty) {
      return const TamizajeEmptyState(
        icon: Icons.inbox_outlined,
        mensaje: 'No hay encuestas respondidas que coincidan con los filtros',
      );
    }

    final result = TamizajeService.paginar(filtradas, _model.paginaActual);
    return Column(
      children: [
        Expanded(
          child: TablaEncuestas(
            respuestas: result.pagina,
            usuarios: usuarios,
            onVerDetalle: (r) => setState(() => _detalleRespuesta = r),
          ),
        ),
        TamizajePaginador(
          paginaActual: _model.paginaActual,
          totalPaginas: result.totalPaginas,
          onCambiarPagina: (p) => setState(() => _model.paginaActual = p),
          totalRegistros: filtradas.length,
          style: PaginadorStyle.web,
        ),
      ],
    );
  }
}
