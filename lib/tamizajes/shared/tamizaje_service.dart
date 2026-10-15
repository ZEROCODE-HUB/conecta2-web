import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
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

  /// Usuarios cuyas respuestas puede ver el usuario actual, o null si no hay
  /// que filtrar (cualquier rol distinto de Profesional). Para un profesional:
  /// sus adolescentes asignados (`Profesionales.Ref`) y él mismo.
  static Future<Set<DocumentReference>?> refsVisiblesParaProfesional() async {
    final rol = valueOrDefault(currentUserDocument?.rol, '');
    final yo = currentUserReference;
    if (rol != FFAppConstants.Profesional || yo == null) return null;
    final asignados = await queryUsersRecordOnce(
      queryBuilder: (q) => q.where('Profesionales.Ref', isEqualTo: yo),
    );
    return {
      yo,
      for (final u in asignados)
        if (u.rol == FFAppConstants.adolescente) u.reference,
    };
  }


  /// Ids de las Encuestas con `tipo == 'Tamizajes'`, o null si no se pudo
  /// leer el catálogo.
  static Future<Set<String>?> idsEncuestasTamizaje() async {
    try {
      final encuestas = await queryEncuestasRecordOnce(
        queryBuilder: (q) => q.where('tipo', isEqualTo: 'Tamizajes'),
      );
      return {for (final e in encuestas) e.reference.id};
    } catch (_) {
      return null;
    }
  }

  /// true si la respuesta cuelga de una Encuesta de tipo Tamizajes.
  /// Con [idsTamizaje] null (catálogo no disponible) no descarta nada.
  static bool esRespuestaDeTamizaje(
    RespuestasRecord r,
    Set<String>? idsTamizaje,
  ) {
    if (idsTamizaje == null) return true;
    final padre = r.reference.parent.parent;
    return padre != null &&
        padre.parent.id == 'Encuestas' &&
        idsTamizaje.contains(padre.id);
  }

  /// Stream de las respuestas a tamizajes (collectionGroup). Excluye las
  /// respuestas a encuestas (`tipo == 'Encuestas'`), que tienen su propio
  /// Listado de Encuestas.
  static Stream<List<RespuestasRecord>> todasLasRespuestas() async* {
    final idsTamizaje = await idsEncuestasTamizaje();
    yield* queryRespuestasRecord(
      queryBuilder: (q) => q,
    ).map((respuestas) => respuestas
        .where((r) => esRespuestaDeTamizaje(r, idsTamizaje))
        .toList());
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
  /// Categorías de encuesta (`Encuesta.categoria`) que corresponden a cada
  /// opción del filtro del listado.
  static const Map<String, List<String>> _categoriasPorFiltro = {
    'CDI': ['CDI'],
    'Beck': ['Depresión Beck'],
    'RQC': ['RQC', 'CRQ', 'RQC / SRQ', 'CRQ / SRQ'],
    'SRQ': ['SRQ', 'RQC / SRQ', 'CRQ / SRQ'],
    'Autoestima': ['Escala autoestima'],
    'Ansiedad': ['Escala ansiedad'],
    'Consumo de SPA': ['Consumo de SPA'],
  };

  /// Filtra por categoría y estado. La categoría se compara con el título
  /// (comportamiento histórico) **o**, si se pasa [categoriaPorEncuesta]
  /// (id de encuesta → `categoria`), con la categoría de la encuesta padre;
  /// así un tamizaje titulado p. ej. "ASSIST colegio X" aparece al filtrar
  /// por "Consumo de SPA".
  static List<RespuestasRecord> filtrarPorCategoriaYEstado(
    List<RespuestasRecord> tamizajes, {
    required String filtroCategoria,
    required String filtroEstado,
    Map<String, String>? categoriaPorEncuesta,
  }) {
    return tamizajes.where((r) {
      if (filtroCategoria != 'Todas') {
        final titulo = r.titlo.toUpperCase();
        final cat = filtroCategoria.toUpperCase();

        // Match both 'RQC' and 'CRQ' when 'RQC' is selected to support legacy surveys
        final coincideTitulo = cat == 'RQC'
            ? (titulo.contains('RQC') || titulo.contains('CRQ'))
            : titulo.contains(cat);
        final categoriaEncuesta = (categoriaPorEncuesta != null &&
                r.parentReference.parent.id == 'Encuestas')
            ? categoriaPorEncuesta[r.parentReference.id]
            : null;
        final coincideCategoria = categoriaEncuesta != null &&
            (_categoriasPorFiltro[filtroCategoria] ?? const [])
                .contains(categoriaEncuesta);
        if (!coincideTitulo && !coincideCategoria) return false;
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
