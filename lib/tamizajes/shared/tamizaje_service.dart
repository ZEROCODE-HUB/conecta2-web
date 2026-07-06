import '/backend/backend.dart';
import 'tamizaje_utils.dart';
import 'tamizajes_constants.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Servicio de datos para Tamizajes
// ═══════════════════════════════════════════════════════════════════════════════

/// Capa de servicio que encapsula las queries de Firestore y la lógica de
/// filtrado, ordenamiento y paginación de tamizajes.
class TamizajeService {
  const TamizajeService._();

  /// Stream de adolescentes asignados a un profesional.
  static Stream<List<UsersRecord>> adolescentesAsignados(
    DocumentReference profesionalRef,
  ) {
    return queryUsersRecord(
      queryBuilder: (q) =>
          q.where('Profesionales.Ref', isEqualTo: profesionalRef),
    );
  }

  /// Stream de todos los adolescentes (para administradores).
  static Stream<List<UsersRecord>> todosLosAdolescentes() {
    return queryUsersRecord(
      queryBuilder: (q) => q.where('rol', isEqualTo: 'Adolescente'),
    );
  }


  /// Stream de todas las respuestas (collectionGroup).
  static Stream<List<RespuestasRecord>> todasLasRespuestas() {
    return queryRespuestasRecord(
      queryBuilder: (q) => q,
    );
  }

  /// Filtra respuestas para quedarse solo con tamizajes (test no vacío) cuyos
  /// adolescentes están asignados al profesional.
  static List<RespuestasRecord> filtrarPorAsignados(
    List<RespuestasRecord> respuestas,
    Map<DocumentReference, UsersRecord> asignadosByRef,
  ) {
    return respuestas.where((r) {
      if (!r.hasTest() || r.test.isEmpty) return false;
      final ref = adolescenteRef(r);
      return ref != null && asignadosByRef.containsKey(ref);
    }).toList();
  }

  /// Aplica filtro de búsqueda por nombre del adolescente o título del tamizaje.
  static List<RespuestasRecord> filtrarPorBusqueda(
    List<RespuestasRecord> tamizajes,
    String busqueda,
    Map<DocumentReference, UsersRecord> asignadosByRef,
  ) {
    final q = busqueda.trim().toLowerCase();
    if (q.isEmpty) return tamizajes;
    return tamizajes.where((r) {
      final adolescente = asignadosByRef[adolescenteRef(r)];
      final nombre = (adolescente?.displayName ?? '').toLowerCase();
      final titulo = r.titlo.toLowerCase();
      return nombre.contains(q) || titulo.contains(q);
    }).toList();
  }

  /// Aplica filtros de categoría y estado (para la vista admin/dashboard).
  static List<RespuestasRecord> filtrarPorCategoriaYEstado(
    List<RespuestasRecord> tamizajes, {
    required String filtroCategoria,
    required String filtroEstado,
  }) {
    return tamizajes.where((r) {
      if (filtroCategoria != 'Todas') {
        final titulo = r.titlo.toUpperCase();
        final cat = filtroCategoria.toUpperCase();
        if (!titulo.contains(cat)) return false;
      }
      if (filtroEstado == 'Completados' && r.invalidado) return false;
      if (filtroEstado == 'Invalidados' && !r.invalidado) return false;
      return true;
    }).toList();
  }

  /// Ordena tamizajes por fecha.
  static void ordenarPorFecha(
    List<RespuestasRecord> tamizajes, {
    required bool descendente,
  }) {
    tamizajes.sort((a, b) {
      final fa = a.fecha ?? DateTime.fromMillisecondsSinceEpoch(0);
      final fb = b.fecha ?? DateTime.fromMillisecondsSinceEpoch(0);
      return descendente ? fb.compareTo(fa) : fa.compareTo(fb);
    });
  }

  /// Pagina una lista y retorna `(página, totalPáginas)`.
  static ({List<RespuestasRecord> pagina, int totalPaginas}) paginar(
    List<RespuestasRecord> items,
    int paginaActual, {
    int pageSize = kPageSize,
  }) {
    if (items.isEmpty) {
      return (pagina: <RespuestasRecord>[], totalPaginas: 0);
    }
    final totalPaginas = (items.length / pageSize).ceil();
    final paginaSegura = paginaActual.clamp(0, totalPaginas - 1);
    final inicio = paginaSegura * pageSize;
    final fin =
        (inicio + pageSize) > items.length ? items.length : inicio + pageSize;
    return (pagina: items.sublist(inicio, fin), totalPaginas: totalPaginas);
  }

  /// Construye un mapa de referencia → UsersRecord para acceso rápido.
  static Map<DocumentReference, UsersRecord> buildAsignadosMap(
    List<UsersRecord> asignados,
  ) {
    return {for (final u in asignados) u.reference: u};
  }
}
