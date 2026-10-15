import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/tamizaje_utils.dart';
import '/tamizajes/shared/widgets/agendar_recordatorio_dialog.dart';
import '/tamizajes/shared/widgets/cancelar_seguimiento_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum _Filtro { pendientes, enviados, todos }

/// Lista móvil de los recordatorios de seguimiento que programó el
/// profesional actual (`reminders.creado_por`), en tarjetas.
///
/// - Sin [adolescenteRef]: todos los del profesional (pantalla
///   "Recordatorios" del menú).
/// - Con [adolescenteRef]: solo los de ese paciente (ficha del paciente),
///   con el botón "Programar seguimiento".
/// Los pendientes se pueden editar y cancelar; los enviados son de lectura.
class SeguimientosListaMovil extends StatefulWidget {
  const SeguimientosListaMovil({
    super.key,
    this.adolescenteRef,
    this.pacienteNombre,
  });

  final DocumentReference? adolescenteRef;
  final String? pacienteNombre;

  @override
  State<SeguimientosListaMovil> createState() => _SeguimientosListaMovilState();
}

class _SeguimientosListaMovilState extends State<SeguimientosListaMovil> {
  _Filtro _filtro = _Filtro.pendientes;

  // Solo `creado_por` en la consulta (sin índice compuesto); el paciente se
  // filtra en el cliente.
  late final Stream<List<RemindersRecord>> _stream = queryRemindersRecord(
    queryBuilder: (q) => q.where('creado_por', isEqualTo: currentUserReference),
  );

  final Map<DocumentReference, String> _nombres = {};
  final Set<DocumentReference> _pedidos = {};

  Future<void> _cargarNombres(Iterable<DocumentReference> refs) async {
    final faltantes =
        refs.where((r) => !_nombres.containsKey(r) && _pedidos.add(r)).toSet();
    if (faltantes.isEmpty) return;
    final entries = await Future.wait(faltantes.map((ref) async {
      try {
        final u = await UsersRecord.getDocumentOnce(ref);
        return MapEntry(ref, u.displayName);
      } catch (_) {
        return MapEntry(ref, '');
      }
    }));
    _nombres.addAll(Map.fromEntries(entries));
  }

  String _nombre(DocumentReference? ref) {
    if (ref == null) return '—';
    final n = _nombres[ref] ?? '';
    return n.isEmpty ? '—' : n;
  }

  bool get _enFicha => widget.adolescenteRef != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_enFicha)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ElevatedButton.icon(
              onPressed: () => showAgendarRecordatorioDialog(
                context,
                adolescenteRef: widget.adolescenteRef,
                tituloDefault: 'Seguimiento',
                pacienteNombre: widget.pacienteNombre,
                useBottomSheet: true,
              ),
              icon: const Icon(Icons.add_alarm, size: 18.0),
              label: Text('Programar seguimiento',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip('Pendientes', _Filtro.pendientes),
              _chip('Enviados', _Filtro.enviados),
              _chip('Todos', _Filtro.todos),
            ],
          ),
        ),
        const SizedBox(height: 12.0),
        StreamBuilder<List<RemindersRecord>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _vacio(Icons.error_outline,
                  'No se pudieron cargar los recordatorios');
            }
            if (!snapshot.hasData) return _cargando();
            final todos = snapshot.data!
                .where((r) =>
                    !_enFicha || r.user?.path == widget.adolescenteRef!.path)
                .toList();
            // Los nombres se cargan una vez en segundo plano (sin parpadeo
            // al cambiar de filtro).
            final faltan = todos
                .map((r) => r.user)
                .whereType<DocumentReference>()
                .where((ref) => !_nombres.containsKey(ref))
                .toSet();
            if (faltan.isNotEmpty) {
              _cargarNombres(faltan).then((_) {
                if (mounted) setState(() {});
              });
            }
            return _lista(todos);
          },
        ),
      ],
    );
  }

  Widget _chip(String label, _Filtro valor) => Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ChoiceChip(
          label: Text(label, style: GoogleFonts.inter(fontSize: 13.0)),
          selected: _filtro == valor,
          onSelected: (_) => setState(() => _filtro = valor),
        ),
      );

  Widget _cargando() => const Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kNavy),
          ),
        ),
      );

  Widget _vacio(IconData icono, String mensaje, [String? sub]) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icono, size: 40.0, color: const Color(0xFFB0B7C3)),
            const SizedBox(height: 10.0),
            Text(mensaje,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280))),
            if (sub != null) ...[
              const SizedBox(height: 6.0),
              Text(sub,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 12.5, color: const Color(0xFF9CA3AF))),
            ],
          ],
        ),
      );

  Widget _lista(List<RemindersRecord> todos) {
    final filtrados = todos.where((r) {
      if (_filtro == _Filtro.pendientes) return !r.notified;
      if (_filtro == _Filtro.enviados) return r.notified;
      return true;
    }).toList()
      // Pendientes: el más próximo primero; enviados/todos: el más reciente.
      ..sort((a, b) {
        final da = a.dueDate ?? DateTime(0);
        final db = b.dueDate ?? DateTime(0);
        return _filtro == _Filtro.pendientes
            ? da.compareTo(db)
            : db.compareTo(da);
      });

    if (filtrados.isEmpty) {
      return _vacio(
        Icons.alarm_off,
        _filtro == _Filtro.pendientes
            ? 'No hay recordatorios pendientes'
            : 'No hay recordatorios',
        _enFicha
            ? 'Usa "Programar seguimiento" o el menú ⋮ de un tamizaje.'
            : 'Se programan desde Tamizajes manuales (Resultados o menú ⋮) '
                'o desde la ficha del paciente.',
      );
    }
    return Column(children: [for (final r in filtrados) _tarjeta(r)]);
  }

  Widget _tarjeta(RemindersRecord r) {
    final enviado = r.notified;
    final fecha = r.dueDate == null
        ? '—'
        : '${formatDate(diaSeguimiento(r.dueDate!))} · 9:00 a. m.';
    TextStyle etiqueta() => GoogleFonts.inter(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF6B7280));
    TextStyle valor() =>
        GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF1F2937));

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 0.0),
            child: Row(
              children: [
                const Icon(Icons.alarm, size: 18.0, color: kNavy),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(fecha,
                      style: GoogleFonts.inter(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: kNavy)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: enviado
                        ? kSuccess.withValues(alpha: 0.12)
                        : kNavy.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    enviado ? 'Enviado' : 'Pendiente',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: enviado ? kSuccess : kNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.title.isEmpty ? 'Recordatorio' : r.title,
                  style: GoogleFonts.inter(
                      fontSize: 15.0, fontWeight: FontWeight.w700),
                ),
                if (!_enFicha) ...[
                  const SizedBox(height: 2.0),
                  Text(_nombre(r.user),
                      style: GoogleFonts.inter(
                          fontSize: 13.0, color: const Color(0xFF4B5563))),
                ],
                const SizedBox(height: 10.0),
                Text('Mensaje para el adolescente', style: etiqueta()),
                const SizedBox(height: 2.0),
                Text(r.content.isEmpty ? '—' : r.content, style: valor()),
                if (r.notasInternas.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  Text('Notas internas', style: etiqueta()),
                  const SizedBox(height: 2.0),
                  Text(r.notasInternas, style: valor()),
                ],
              ],
            ),
          ),
          if (!enviado)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => showAgendarRecordatorioDialog(
                        context,
                        existente: r,
                        pacienteNombre: _nombre(r.user),
                        useBottomSheet: true,
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18.0),
                      label: const Text('Editar'),
                      style: TextButton.styleFrom(foregroundColor: kNavy),
                    ),
                  ),
                  Container(width: 1.0, height: 28.0, color: const Color(0xFFF0F0F0)),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => confirmarCancelarSeguimiento(
                        context,
                        recordatorio: r,
                        pacienteNombre: _nombre(r.user),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18.0),
                      label: const Text('Cancelar'),
                      style: TextButton.styleFrom(foregroundColor: kDanger),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
