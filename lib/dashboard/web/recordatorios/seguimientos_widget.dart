import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/tamizaje_utils.dart';
import '/tamizajes/shared/widgets/agendar_recordatorio_dialog.dart';
import '/tamizajes/shared/widgets/cancelar_seguimiento_dialog.dart';
import '/tamizajes/shared/widgets/tamizaje_empty_state.dart';
import '/tamizajes/shared/widgets/tamizaje_page_header.dart';
import '/tamizajes/shared/widgets/tamizaje_paginador.dart';
import '/tamizajes/shared/widgets/tamizaje_tabla_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum _FiltroEstado { todos, pendientes, enviados }

/// Sección web "Recordatorios": seguimientos programados desde Tamizajes
/// manuales (colección `reminders`).
///
/// - Profesional: solo los que él creó (`creado_por`).
/// - Administrador: todos, con la columna Profesional.
/// Los pendientes se pueden editar y cancelar; los enviados son de lectura.
/// La Cloud Function `enviarRecordatoriosProgramados` los envía a las
/// 9:00 a. m. hora Colombia del día programado.
class SeguimientosWidget extends StatefulWidget {
  const SeguimientosWidget({super.key});

  @override
  State<SeguimientosWidget> createState() => _SeguimientosWidgetState();
}

class _SeguimientosWidgetState extends State<SeguimientosWidget> {
  final _busquedaController = TextEditingController();
  String _busqueda = '';
  _FiltroEstado _filtro = _FiltroEstado.pendientes;
  int _pagina = 0;

  late final bool _esAdmin =
      valueOrDefault(currentUserDocument?.rol, '') == 'Administrador';
  late final Stream<List<RemindersRecord>> _stream = _esAdmin
      ? queryRemindersRecord()
      : queryRemindersRecord(
          queryBuilder: (q) =>
              q.where('creado_por', isEqualTo: currentUserReference),
        );

  /// Cache de perfiles (adolescentes y profesionales); null = no se pudo leer.
  final Map<DocumentReference, UsersRecord?> _usuarios = {};

  Future<Map<DocumentReference, UsersRecord?>> _cargarUsuarios(
      Iterable<DocumentReference> refs) async {
    final faltantes = refs.where((r) => !_usuarios.containsKey(r)).toSet();
    if (faltantes.isNotEmpty) {
      final entries = await Future.wait(faltantes.map((ref) async {
        try {
          return MapEntry(ref, await UsersRecord.getDocumentOnce(ref));
        } catch (_) {
          return MapEntry<DocumentReference, UsersRecord?>(ref, null);
        }
      }));
      _usuarios.addAll(Map.fromEntries(entries));
    }
    return _usuarios;
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  String _nombre(DocumentReference? ref) {
    if (ref == null) return '—';
    final n = _usuarios[ref]?.displayName ?? '';
    return n.isEmpty ? '—' : n;
  }

  Future<void> _editar(RemindersRecord r) async {
    await showAgendarRecordatorioDialog(
      context,
      existente: r,
      pacienteNombre: _nombre(r.user),
    );
  }

  Future<void> _cancelar(RemindersRecord r) => confirmarCancelarSeguimiento(
        context,
        recordatorio: r,
        pacienteNombre: _nombre(r.user),
      );

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.primaryBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TamizajePageHeader(
            titulo: 'Recordatorios de seguimiento',
            icon: Icons.alarm,
          ),
          _buildFiltros(),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: StreamBuilder<List<RemindersRecord>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const TamizajeEmptyState(
                    icon: Icons.error_outline,
                    mensaje: 'No se pudieron cargar los recordatorios',
                  );
                }
                if (!snapshot.hasData) return _cargando();
                final todos = snapshot.data!;
                final refs = <DocumentReference>{
                  for (final r in todos) ...[
                    if (r.user != null) r.user!,
                    if (r.creadoPor != null) r.creadoPor!,
                  ],
                };
                return FutureBuilder<Map<DocumentReference, UsersRecord?>>(
                  future: _cargarUsuarios(refs),
                  builder: (context, usersSnap) {
                    if (!usersSnap.hasData) return _cargando();
                    return _buildTabla(todos);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cargando() => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kNavy),
        ),
      );

  Widget _buildFiltros() {
    Widget chip(String label, _FiltroEstado valor) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(label, style: GoogleFonts.inter(fontSize: 13.0)),
            selected: _filtro == valor,
            onSelected: (_) => setState(() {
              _filtro = valor;
              _pagina = 0;
            }),
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 16.0),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 12.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 360,
            child: TextField(
              controller: _busquedaController,
              onChanged: (v) => setState(() {
                _busqueda = v;
                _pagina = 0;
              }),
              decoration: InputDecoration(
                hintText: 'Buscar por adolescente o título…',
                hintStyle: GoogleFonts.inter(fontSize: 14.0),
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              chip('Pendientes', _FiltroEstado.pendientes),
              chip('Enviados', _FiltroEstado.enviados),
              chip('Todos', _FiltroEstado.todos),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabla(List<RemindersRecord> todos) {
    final q = _busqueda.trim().toLowerCase();
    final filtrados = todos.where((r) {
      if (_filtro == _FiltroEstado.pendientes && r.notified) return false;
      if (_filtro == _FiltroEstado.enviados && !r.notified) return false;
      if (q.isEmpty) return true;
      return r.title.toLowerCase().contains(q) ||
          _nombre(r.user).toLowerCase().contains(q);
    }).toList()
      // Pendientes: el más próximo primero; enviados/todos: el más reciente.
      ..sort((a, b) {
        final da = a.dueDate ?? DateTime(0);
        final db = b.dueDate ?? DateTime(0);
        return _filtro == _FiltroEstado.pendientes
            ? da.compareTo(db)
            : db.compareTo(da);
      });

    if (filtrados.isEmpty) {
      return TamizajeEmptyState(
        icon: Icons.alarm_off,
        mensaje: _filtro == _FiltroEstado.pendientes
            ? 'No hay recordatorios pendientes'
            : 'No hay recordatorios que coincidan con los filtros',
        submensaje:
            'Se programan desde Tamizajes manuales → Resultados o el menú de cada tamizaje.',
      );
    }

    final totalPaginas = (filtrados.length / kPageSize).ceil();
    final pagina = _pagina.clamp(0, totalPaginas - 1);
    final visibles =
        filtrados.skip(pagina * kPageSize).take(kPageSize).toList();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: TamizajeTablaWrapper(
              headerColumns: [
                const TamizajeColumna('Envío', flex: 2),
                const TamizajeColumna('Adolescente', flex: 3),
                const TamizajeColumna('Título', flex: 3),
                const TamizajeColumna('Mensaje', flex: 4),
                const TamizajeColumna('Notas internas', flex: 3),
                const TamizajeColumna('Estado', flex: 2),
                if (_esAdmin) const TamizajeColumna('Profesional', flex: 3),
                const TamizajeColumna('Acciones', flex: 2),
              ],
              rowCount: visibles.length,
              rowBuilder: (context, i) => _fila(visibles[i], i.isOdd),
            ),
          ),
        ),
        TamizajePaginador(
          paginaActual: pagina,
          totalPaginas: totalPaginas,
          onCambiarPagina: (p) => setState(() => _pagina = p),
          totalRegistros: filtrados.length,
          style: PaginadorStyle.web,
        ),
      ],
    );
  }

  Widget _fila(RemindersRecord r, bool zebra) {
    final texto = GoogleFonts.inter(fontSize: 13.0);
    Widget celda(int flex, Widget child) => Expanded(
          flex: flex,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: child,
          ),
        );
    Widget txt(String s, {int maxLines = 2}) => Text(
          s.isEmpty ? '—' : s,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: texto,
        );

    final envio = r.dueDate == null
        ? '—'
        : '${formatDate(diaSeguimiento(r.dueDate!))} 9:00';
    final enviado = r.notified;

    return Container(
      color: zebra ? const Color(0xFFFAFBFC) : Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          celda(2, txt(envio, maxLines: 1)),
          celda(3, txt(_nombre(r.user))),
          celda(3, txt(r.title)),
          celda(4, Tooltip(message: r.content, child: txt(r.content))),
          celda(3,
              Tooltip(message: r.notasInternas, child: txt(r.notasInternas))),
          celda(
            2,
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: enviado
                      ? kSuccess.withValues(alpha: 0.12)
                      : kNavy.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  enviado ? 'Enviado' : 'Pendiente',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: enviado ? kSuccess : kNavy,
                  ),
                ),
              ),
            ),
          ),
          if (_esAdmin) celda(3, txt(_nombre(r.creadoPor))),
          celda(
            2,
            enviado
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        icon: const Icon(Icons.edit_outlined,
                            size: 20, color: kNavy),
                        onPressed: () => _editar(r),
                      ),
                      IconButton(
                        tooltip: 'Cancelar recordatorio',
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: kDanger),
                        onPressed: () => _cancelar(r),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
