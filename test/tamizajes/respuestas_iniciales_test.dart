import 'package:flutter_test/flutter_test.dart';
import 'package:conecta2/backend/schema/structs/index.dart';
import 'package:conecta2/tamizajes/shared/tamizaje_utils.dart';

void main() {
  group('respuestasIniciales', () {
    final preguntas = [
      PreguntasEncuestaStruct(
        pregunta: '¿Qué sustancias has consumido?',
        tipo: 'Condicionante',
      ),
      PreguntasEncuestaStruct(
        pregunta: 'Me siento triste',
        tipo: 'Tamizaje CDI',
      ),
      PreguntasEncuestaStruct(
        pregunta: 'Elige una',
        tipo: 'Selección única',
        respuestaSelection: ['a', 'b'],
        respuestasSeleccionUnica: ['Sí', 'No'],
      ),
    ];

    test('una entrada por pregunta, en el mismo orden', () {
      final r = respuestasIniciales(preguntas, null);
      expect(r, hasLength(preguntas.length));
      for (var i = 0; i < preguntas.length; i++) {
        expect(r[i].pregunta, preguntas[i].pregunta);
        expect(r[i].tipo, preguntas[i].tipo);
        expect(r[i].nPregunta, i + 1);
      }
    });

    test('copia las opciones y deja las respuestas vacías', () {
      final r = respuestasIniciales(preguntas, null)[2];
      expect(r.respuestaSelection, ['a', 'b']);
      expect(r.rSeleccionUnica, ['Sí', 'No']);
      expect(r.respuesta, isEmpty);
      expect(r.respuestaSeleccionUnica, isEmpty);
      expect(r.respuestasSeleccionadas, isEmpty);
      expect(r.respuestaTamizaje, isEmpty);
    });

    test('sin la entrada falsa "Hola" al volver a empezar', () {
      final r = respuestasIniciales(preguntas, null);
      expect(r.map((e) => e.pregunta), isNot(contains('Hola')));
    });

    test('sin preguntas, lista vacía', () {
      expect(respuestasIniciales(const [], null), isEmpty);
    });
  });
}
