import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/tamizajes/shared/tamizaje_service.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/widgets/detalle_tamizaje_view.dart';
import '/tamizajes/shared/widgets/tamizaje_empty_state.dart';
import '/tamizajes/shared/widgets/tamizaje_page_header.dart';
import '/tamizajes/shared/widgets/tamizaje_paginador.dart';
import '/tamizajes/shared/widgets/tamizaje_search_bar.dart';
import 'widgets/tamizaje_filters.dart';
import 'widgets/tabla_tamizajes.dart';
import 'listado_tamizajes_model.dart';
export 'listado_tamizajes_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListadoTamizajesWidget extends StatefulWidget {
  const ListadoTamizajesWidget({super.key, this.onVolver});

  final VoidCallback? onVolver;

  @override
  State<ListadoTamizajesWidget> createState() =>
      _ListadoTamizajesWidgetState();
}

class _ListadoTamizajesWidgetState extends State<ListadoTamizajesWidget> {
  late ListadoTamizajesModel _model;

  RespuestasRecord? _detalleRespuesta;

  /// id de encuesta → categoría, para filtrar por la categoría real de la
  /// encuesta y no solo por palabras del título.
  Map<String, String>? _categoriaPorEncuesta;

  Future<void> _cargarCategorias() async {
    try {
      final encuestas = await queryEncuestasRecordOnce(
        queryBuilder: (q) => q.where('tipo', isEqualTo: 'Tamizajes'),
      );
      if (!mounted) return;
      setState(() {
        _categoriaPorEncuesta = {
          for (final e in encuestas) e.reference.id: e.categoria,
        };
      });
    } catch (_) {
      // Sin el mapa se mantiene el filtro por título.
    }
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ListadoTamizajesModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
    _cargarCategorias();
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
    final enDetalle = _detalleRespuesta != null;

    Widget content;
    if (enDetalle) {
      content = DetalleTamizajeView(
        key: const ValueKey('detalle'),
        respuesta: _detalleRespuesta!,
        onVolver: _cerrarDetalle,
      );
    } else {
      content = _buildListado(theme);
    }

    return PopScope(
      canPop: !enDetalle,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && enDetalle) _cerrarDetalle();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: content,
      ),
    );
  }

  /// Cache de nombres de usuarios para búsqueda.
  final Map<DocumentReference, String> _nombresCache = {};

  Future<Map<DocumentReference, String>> _cargarNombresUsuarios(
      List<DocumentReference> refs) async {
    final faltantes =
        refs.where((r) => !_nombresCache.containsKey(r)).toList();
    if (faltantes.isNotEmpty) {
      final futures = faltantes.map((ref) async {
        try {
          final user = await UsersRecord.getDocumentOnce(ref);
          return MapEntry(ref, user.displayName);
        } catch (_) {
          return MapEntry(ref, '');
        }
      });
      final entries = await Future.wait(futures);
      _nombresCache.addAll(Map.fromEntries(entries));
    }
    return _nombresCache;
  }

  Widget _buildTablaConPaginacion(List<RespuestasRecord> tamizajes) {
    if (tamizajes.isEmpty) {
      return const TamizajeEmptyState(
        icon: Icons.inbox_outlined,
        mensaje: 'No hay tamizajes que coincidan con los filtros',
      );
    }

    final result = TamizajeService.paginar(tamizajes, _model.paginaActual);

    return Column(
      children: [
        Expanded(
          child: TablaTamizajes(
            respuestas: result.pagina,
            onVerDetalle: (respuesta) =>
                setState(() => _detalleRespuesta = respuesta),
          ),
        ),
        TamizajePaginador(
          paginaActual: _model.paginaActual,
          totalPaginas: result.totalPaginas,
          onCambiarPagina: (p) =>
              setState(() => _model.paginaActual = p),
          totalRegistros: tamizajes.length,
          style: PaginadorStyle.web,
        ),
      ],
    );
  }

  Widget _buildListado(FlutterFlowTheme theme) {
    return Container(
      key: const ValueKey('listado'),
      width: double.infinity,
      height: double.infinity,
      color: theme.primaryBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────
          TamizajePageHeader(
            titulo: 'Listado de Tamizajes Completados',
            breadcrumb: 'Volver a Tamizajes',
            onVolver: _volver,
            icon: Icons.list_alt_rounded,
          ),

          // ── Búsqueda + Orden ───────────────────────────────────────────
          TamizajeSearchBar(
            controller: _model.searchController,
            focusNode: _model.searchFocusNode,
            ordenDescendente: _model.ordenDescendente,
            hintText: 'Buscar por nombre de paciente o tamizaje…',
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

          // ── Filtros ────────────────────────────────────────────────────
          TamizajeFilters(
            filtroCategoria: _model.filtroCategoria,
            filtroEstado: _model.filtroEstado,
            onCategoriaChanged: (v) {
              setState(() {
                _model.filtroCategoria = v;
                _model.paginaActual = 0;
              });
            },
            onEstadoChanged: (v) {
              setState(() {
                _model.filtroEstado = v;
                _model.paginaActual = 0;
              });
            },
          ),

          const Divider(height: 1, thickness: 1),

          // ── Tabla + Paginación ─────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<RespuestasRecord>>(
              stream: queryRespuestasRecord(
                queryBuilder: (q) => q,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kNavy),
                    ),
                  );
                }

                // Solo tamizajes con test
                var tamizajes = snapshot.data!
                    .where((r) => r.hasTest() && r.test.isNotEmpty)
                    .toList();

                // Filtros categoría + estado
                tamizajes = TamizajeService.filtrarPorCategoriaYEstado(
                  tamizajes,
                  filtroCategoria: _model.filtroCategoria,
                  filtroEstado: _model.filtroEstado,
                  categoriaPorEncuesta: _categoriaPorEncuesta,
                );

                // Ordenar
                TamizajeService.ordenarPorFecha(tamizajes,
                    descendente: _model.ordenDescendente);

                // Para búsqueda por nombre, necesitamos cargar users
                // Usamos FutureBuilder para pre-cargar los nombres
                final q = _model.busqueda.trim().toLowerCase();
                if (q.isEmpty) {
                  return _buildTablaConPaginacion(tamizajes);
                }

                // Extraer refs de usuarios únicos
                final userRefs = tamizajes
                    .where((r) => r.userRespuesta != null)
                    .map((r) => r.userRespuesta!)
                    .toSet()
                    .toList();

                return FutureBuilder<Map<DocumentReference, String>>(
                  future: _cargarNombresUsuarios(userRefs),
                  builder: (context, namesSnap) {
                    final nombres = namesSnap.data ?? {};

                    // Filtrar por búsqueda (título + nombre paciente)
                    final filtrados = tamizajes.where((r) {
                      final titulo = r.titlo.toLowerCase();
                      final nombre = (nombres[r.userRespuesta] ?? '')
                          .toLowerCase();
                      return titulo.contains(q) || nombre.contains(q);
                    }).toList();

                    return _buildTablaConPaginacion(filtrados);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
