import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/tamizajes/shared/tamizajes_constants.dart';
import '/tamizajes/shared/tamizaje_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Fecha del seguimiento ───────────────────────────────────────────────────
//
// Los recordatorios de seguimiento se envían a las 9:00 a. m. hora Colombia
// (UTC-5, sin horario de verano). `due_date` se guarda como ese instante
// para que no dependa de la zona horaria del dispositivo; la Cloud Function
// `enviarRecordatoriosProgramados` (cada hora) los envía al vencer.

/// Instante de envío (9:00 a. m. hora Colombia) del día [dia].
DateTime dueDateSeguimiento(DateTime dia) =>
    DateTime.utc(dia.year, dia.month, dia.day, 14);

/// Día (en Colombia) en que se envía un recordatorio con este [dueDate].
DateTime diaSeguimiento(DateTime dueDate) {
  final col = dueDate.toUtc().subtract(const Duration(hours: 5));
  return DateTime(col.year, col.month, col.day);
}

/// Muestra el diálogo para agendar (o, con [existente], editar) un
/// recordatorio de seguimiento.
///
/// El recordatorio llega al adolescente ([adolescenteRef]) con el mensaje y
/// al profesional que lo creó. Las notas internas no se envían a nadie.
/// Soporta [AlertDialog] (web) y [BottomSheet] (móvil) según
/// [useBottomSheet]. Retorna `true` si se guardó.
Future<bool> showAgendarRecordatorioDialog(
  BuildContext context, {
  DocumentReference? adolescenteRef,
  String tituloDefault = '',
  String? pacienteNombre,
  DocumentReference? encuestaRef,
  RemindersRecord? existente,
  bool useBottomSheet = false,
}) async {
  final destinatario = existente?.user ?? adolescenteRef;
  if (destinatario == null) return false;

  final manana = DateTime.now().add(const Duration(days: 1));
  final primerDia = DateTime(manana.year, manana.month, manana.day);
  var dia = existente?.dueDate != null
      ? diaSeguimiento(existente!.dueDate!)
      : primerDia.add(const Duration(days: 6));
  if (dia.isBefore(primerDia)) dia = primerDia;

  final valores = _ValoresRecordatorio(
    titulo: TextEditingController(text: existente?.title ?? tituloDefault),
    mensaje: TextEditingController(text: existente?.content ?? ''),
    notas: TextEditingController(text: existente?.notasInternas ?? ''),
    dia: dia,
    primerDia: primerDia,
  );
  final tituloDialogo =
      existente == null ? 'Agendar recordatorio' : 'Editar recordatorio';

  final ok = useBottomSheet
      ? await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          builder: (ctx) => Padding(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  _Encabezado(titulo: tituloDialogo),
                  const SizedBox(height: 12.0),
                  _RecordatorioForm(
                      valores: valores, pacienteNombre: pacienteNombre),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.inter(
                                color: const Color(0xFF959595)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: _BotonGuardar(
                          valores: valores,
                          onGuardar: () => Navigator.of(ctx).pop(true),
                          vertical: 14.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      : await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: _Encabezado(titulo: tituloDialogo),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: _RecordatorioForm(
                    valores: valores, pacienteNombre: pacienteNombre),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(color: const Color(0xFF959595)),
                ),
              ),
              _BotonGuardar(
                valores: valores,
                onGuardar: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
        );

  if (ok != true) return false;

  final titulo = valores.titulo.text.trim();
  final mensaje = valores.mensaje.text.trim();
  final notas = valores.notas.text.trim();
  final dueDate = dueDateSeguimiento(valores.dia);
  try {
    if (existente == null) {
      await RemindersRecord.collection.doc().set(
            createRemindersRecordData(
              user: destinatario,
              dueDate: dueDate,
              title: titulo,
              content: mensaje,
              notasInternas: notas,
              creadoPor: currentUserReference,
              encuesta: encuestaRef,
              createdTime: DateTime.now(),
              notified: false,
            ),
          );
    } else {
      // Solo se editan recordatorios pendientes; no se toca `notified`.
      await existente.reference.update({
        'due_date': dueDate,
        'title': titulo,
        'content': mensaje,
        'notas_internas': notas,
      });
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existente == null
                ? 'Recordatorio agendado para el ${formatDate(valores.dia)} a las 9:00 a. m.'
                : 'Recordatorio actualizado',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: kSuccess,
        ),
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el recordatorio: $e')),
      );
    }
    return false;
  }
}

// ─── Estado del formulario ───────────────────────────────────────────────────

class _ValoresRecordatorio {
  _ValoresRecordatorio({
    required this.titulo,
    required this.mensaje,
    required this.notas,
    required this.dia,
    required this.primerDia,
  });

  final TextEditingController titulo;
  final TextEditingController mensaje;
  final TextEditingController notas;
  DateTime dia;
  final DateTime primerDia;
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.titulo});
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.alarm, color: kNavy, size: 22.0),
        const SizedBox(width: 8.0),
        Text(
          titulo,
          style: GoogleFonts.inter(
            fontSize: 17.0,
            fontWeight: FontWeight.w700,
            color: kNavy,
          ),
        ),
      ],
    );
  }
}

/// Guardar solo con título y mensaje (el mensaje es lo que recibe el
/// adolescente).
class _BotonGuardar extends StatelessWidget {
  const _BotonGuardar({
    required this.valores,
    required this.onGuardar,
    this.vertical,
  });

  final _ValoresRecordatorio valores;
  final VoidCallback onGuardar;
  final double? vertical;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (valores.titulo.text.trim().isEmpty ||
            valores.mensaje.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Escribe el título y el mensaje para el adolescente.'),
            ),
          );
          return;
        }
        onGuardar();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: kNavy,
        foregroundColor: Colors.white,
        padding: vertical == null
            ? null
            : EdgeInsets.symmetric(vertical: vertical!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        'Guardar',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── Formulario (diálogo web y BottomSheet móvil) ────────────────────────────

class _RecordatorioForm extends StatefulWidget {
  const _RecordatorioForm({required this.valores, this.pacienteNombre});

  final _ValoresRecordatorio valores;
  final String? pacienteNombre;

  @override
  State<_RecordatorioForm> createState() => _RecordatorioFormState();
}

class _RecordatorioFormState extends State<_RecordatorioForm> {
  InputDecoration _decoracion(String label, {String? ayuda}) =>
      InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(),
        helperText: ayuda,
        helperMaxLines: 2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final v = widget.valores;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.pacienteNombre != null && widget.pacienteNombre!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Paciente: ${widget.pacienteNombre}',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ),
        TextField(
          controller: v.titulo,
          decoration: _decoracion('Título'),
          style: GoogleFonts.inter(fontSize: 14.0),
        ),
        const SizedBox(height: 12.0),
        TextField(
          controller: v.mensaje,
          maxLines: 3,
          decoration: _decoracion(
            'Mensaje para el adolescente',
            ayuda: 'Lo recibe el adolescente en su celular.',
          ),
          style: GoogleFonts.inter(fontSize: 14.0),
        ),
        const SizedBox(height: 12.0),
        TextField(
          controller: v.notas,
          maxLines: 3,
          decoration: _decoracion(
            'Notas internas (opcional)',
            ayuda: 'Solo las ve el profesional; no se envían.',
          ),
          style: GoogleFonts.inter(fontSize: 14.0),
        ),
        const SizedBox(height: 16.0),
        _FechaSelector(
          fecha: v.dia,
          primerDia: v.primerDia,
          onChanged: (d) => setState(() => v.dia = d),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Se enviará ese día a las 9:00 a. m. al adolescente y a ti.',
          style: GoogleFonts.inter(
            fontSize: 12.0,
            color: const Color(0xFF757575),
          ),
        ),
      ],
    );
  }
}

// ─── Selector de fecha ───────────────────────────────────────────────────────

class _FechaSelector extends StatelessWidget {
  const _FechaSelector({
    required this.fecha,
    required this.primerDia,
    required this.onChanged,
  });
  final DateTime fecha;
  final DateTime primerDia;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 18.0, color: kNavy),
          const SizedBox(width: 10.0),
          Text(
            '${formatDate(fecha)} · 9:00 a. m.',
            style: GoogleFonts.inter(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: fecha,
                firstDate: primerDia,
                lastDate: primerDia.add(const Duration(days: 365 * 2)),
              );
              if (picked != null) onChanged(picked);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: kNavy,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Cambiar',
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
