import 'package:conecta2/tamizajes/shared/tamizaje_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('esRutaRespuestaDeEncuesta', () {
    test('respuesta bajo una encuesta', () {
      expect(
          TamizajeService.esRutaRespuestaDeEncuesta(
              'Encuestas/abc/Respuestas/xyz'),
          isTrue);
    });

    test('respuesta bajo el perfil del usuario', () {
      expect(
          TamizajeService.esRutaRespuestaDeEncuesta('users/u1/Respuestas/r1'),
          isFalse);
    });

    test('ruta incompleta o más profunda', () {
      expect(TamizajeService.esRutaRespuestaDeEncuesta('Encuestas/abc'),
          isFalse);
      expect(
          TamizajeService.esRutaRespuestaDeEncuesta(
              'Encuestas/a/Respuestas/b/Otra/c'),
          isFalse);
    });
  });

  test('compararFechaDesc: más reciente primero y sin fecha al final', () {
    final fechas = <DateTime?>[
      DateTime(2026, 1, 1),
      null,
      DateTime(2026, 10, 16),
      DateTime(2026, 5, 3),
    ]..sort(TamizajeService.compararFechaDesc);
    expect(fechas, [
      DateTime(2026, 10, 16),
      DateTime(2026, 5, 3),
      DateTime(2026, 1, 1),
      null,
    ]);
  });
}
