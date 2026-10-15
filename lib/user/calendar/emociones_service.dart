import '/app_state.dart';
import '/backend/backend.dart';

/// Lógica compartida del registro de emociones (`users/{uid}/emociones_registro`).
///
/// La fuente de verdad es Firestore: el estado local (`FFAppState().emocionDay`,
/// `dateEmocion`, `CalenderEmotion`) solo refleja lo que hay guardado, para
/// que "ya registré hoy" y el contador de días no dependan del dispositivo.

/// Valor centinela de `dateEmocion` cuando no hay emoción de hoy (el mismo
/// que usan los formularios de registro).
final DateTime kSinFechaEmocion =
    DateTime.fromMillisecondsSinceEpoch(1719194940000);

DateTime inicioDelDia(DateTime d) => DateTime(d.year, d.month, d.day);

/// Registros de un día. `fecha` se guarda como medianoche local; se consulta
/// por rango para no depender de la hora exacta guardada.
Future<List<EmocionesRegistroRecord>> emocionesDelDia(
  DocumentReference userRef,
  DateTime dia,
) {
  final inicio = inicioDelDia(dia);
  final fin = DateTime(inicio.year, inicio.month, inicio.day + 1);
  return queryEmocionesRegistroRecordOnce(
    parent: userRef,
    queryBuilder: (q) => q
        .where('fecha', isGreaterThanOrEqualTo: inicio)
        .where('fecha', isLessThan: fin),
  );
}

/// Registro que representa al día cuando hay más de uno (datos antiguos):
/// el de menor valor, que es el que pinta el calendario.
EmocionesRegistroRecord? registroDelDia(List<EmocionesRegistroRecord> registros) {
  EmocionesRegistroRecord? elegido;
  for (final r in registros) {
    if (r.emocion < 1 || r.emocion > 5) continue;
    if (elegido == null || r.emocion < elegido.emocion) elegido = r;
  }
  return elegido;
}

/// Emoción registrada hoy por el usuario, o null.
Future<EmocionesRegistroRecord?> emocionDeHoy(DocumentReference userRef) async =>
    registroDelDia(await emocionesDelDia(userRef, DateTime.now()));

/// Recalcula el estado local desde Firestore:
/// - `CalenderEmotion`: un elemento por día con registro (alimenta el
///   contador "N días");
/// - `emocionDay` / `dateEmocion`: la emoción de hoy, o 0 si no hay.
Future<void> sincronizarEmociones(DocumentReference? userRef) async {
  if (userRef == null) return;
  final registros = await queryEmocionesRegistroRecordOnce(parent: userRef);
  final porDia = <DateTime, EmocionesRegistroRecord>{};
  for (final r in registros) {
    final fecha = r.fecha;
    if (fecha == null || r.emocion < 1 || r.emocion > 5) continue;
    final dia = inicioDelDia(fecha);
    final actual = porDia[dia];
    if (actual == null || r.emocion < actual.emocion) porDia[dia] = r;
  }
  final dias = porDia.keys.toList()..sort();
  final app = FFAppState();
  app.CalenderEmotion = [
    for (final d in dias)
      CalenderEmocionesStruct(date: d, emocion: porDia[d]!.emocion.toString()),
  ];
  final hoy = porDia[inicioDelDia(DateTime.now())];
  if (hoy != null) {
    app.emocionDay = hoy.emocion;
    app.dateEmocion = inicioDelDia(DateTime.now());
  } else {
    app.emocionDay = 0;
    app.dateEmocion = kSinFechaEmocion;
  }
  app.update(() {});
}

/// Borra el estado de emociones del dispositivo (al cerrar sesión), para que
/// otro usuario no herede la cara, la tarjeta del home ni el contador.
void limpiarEstadoEmociones() {
  final app = FFAppState();
  app.emocionDay = 0;
  app.dateEmocion = kSinFechaEmocion;
  app.CalenderEmotion = [];
  app.emocion = 0;
  app.description = '';
}

/// Texto para el detalle de un día: "Hoy" o "El 14 de octubre" (con año si
/// no es el actual).
String cuandoEmocion(DateTime? dia) {
  final ahora = DateTime.now();
  if (dia == null || inicioDelDia(dia) == inicioDelDia(ahora)) return 'Hoy';
  const meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
    'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  final anio = dia.year == ahora.year ? '' : ' de ${dia.year}';
  return 'El ${dia.day} de ${meses[dia.month - 1]}$anio';
}
