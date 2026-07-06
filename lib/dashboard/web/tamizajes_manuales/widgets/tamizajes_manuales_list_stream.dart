import '/backend/backend.dart';
import '/tamizajes/shared/tamizaje_service.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/widgets/tamizaje_empty_state.dart';
import '/tamizajes/shared/widgets/tamizaje_paginador.dart';
import 'tamizajes_manuales_tabla.dart';
import 'package:flutter/material.dart';

/// Widget que consume streams de Firestore y muestra la lista filtrada,
/// ordenada y paginada de tamizajes para el profesional en el dashboard web.
class TamizajesManualesListStream extends StatefulWidget {
  const TamizajesManualesListStream({
    super.key,
    required this.profesionalRef,
    required this.busqueda,
    required this.ordenDescendente,
    required this.paginaActual,
    required this.onCambiarPagina,
    this.onVerDetalle,
    this.isAdmin = false,
  });

  final DocumentReference profesionalRef;
  final String busqueda;
  final bool ordenDescendente;
  final int paginaActual;
  final ValueChanged<int> onCambiarPagina;
  final void Function(RespuestasRecord respuesta, UsersRecord? adolescente)?
      onVerDetalle;
  final bool isAdmin;

  @override
  State<TamizajesManualesListStream> createState() =>
      _TamizajesManualesListStreamState();
}

class _TamizajesManualesListStreamState
    extends State<TamizajesManualesListStream> {
  late final Stream<List<UsersRecord>> _adolescentesStream;
  late final Stream<List<RespuestasRecord>> _respuestasStream;

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      _adolescentesStream = TamizajeService.todosLosAdolescentes();
    } else {
      _adolescentesStream =
          TamizajeService.adolescentesAsignados(widget.profesionalRef);
    }
    _respuestasStream = TamizajeService.todasLasRespuestas();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UsersRecord>>(
      stream: _adolescentesStream,
      builder: (context, asignSnap) {
        if (asignSnap.hasError) {
          return const TamizajeEmptyState(
            icon: Icons.error_outline,
            mensaje: 'Error al cargar adolescentes asignados',
          );
        }
        if (asignSnap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kNavy),
            ),
          );
        }

        final asignados = asignSnap.data ?? [];
        if (asignados.isEmpty) {
          return const TamizajeEmptyState(
            icon: Icons.group_off_outlined,
            mensaje: 'No tiene adolescentes asignados',
          );
        }

        final asignadosByRef = TamizajeService.buildAsignadosMap(asignados);

        return StreamBuilder<List<RespuestasRecord>>(
          stream: _respuestasStream,
          builder: (context, snap) {
            if (snap.hasError) {
              return const TamizajeEmptyState(
                icon: Icons.error_outline,
                mensaje: 'Error al cargar tamizajes',
              );
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kNavy),
                ),
              );
            }

            // Filtrar, buscar, ordenar
            var tamizajes = TamizajeService.filtrarPorAsignados(
                snap.data ?? [], asignadosByRef);
            tamizajes = TamizajeService.filtrarPorBusqueda(
                tamizajes, widget.busqueda, asignadosByRef);
            TamizajeService.ordenarPorFecha(tamizajes,
                descendente: widget.ordenDescendente);

            if (tamizajes.isEmpty) {
              return const TamizajeEmptyState(
                icon: Icons.inbox_outlined,
                mensaje: 'No hay tamizajes que coincidan con la búsqueda',
              );
            }

            // Paginar
            final result =
                TamizajeService.paginar(tamizajes, widget.paginaActual);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: TamizajesManualesTabla(
                      respuestas: result.pagina,
                      asignadosByRef: asignadosByRef,
                      onVerDetalle: widget.onVerDetalle,
                    ),
                  ),
                ),
                TamizajePaginador(
                  paginaActual: widget.paginaActual,
                  totalPaginas: result.totalPaginas,
                  onCambiarPagina: widget.onCambiarPagina,
                  totalRegistros: tamizajes.length,
                  style: PaginadorStyle.web,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
