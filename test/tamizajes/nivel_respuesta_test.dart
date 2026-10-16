import 'package:flutter_test/flutter_test.dart';
import 'package:conecta2/tamizajes/shared/nivel_respuesta.dart';

/// Casos compartidos con la Cloud Function (misma tabla en el test JS):
/// nivel → ¿avisa al acudiente?
const casos = <String, bool>{
  '': false,
  'Sin alerta': false,
  'Sin sintomatología': false,
  'sin sintomatologia': false,
  'Mínima': false,
  'Bajo': false,
  'Media': false,
  'Autoestima Media': false,
  'Elevada': false,
  'Autoestima Elevada': false,
  'Leve': true,
  'Moderado': true,
  'Moderada': true,
  'Severo': true,
  'Grave': true,
  'Alto': true,
  'Baja': true,
  'Autoestima Baja': true,
  'Subescala 1': true,
};

void main() {
  group('nivelConRiesgo', () {
    casos.forEach((nivel, esperado) {
      test('"$nivel" → $esperado', () {
        expect(nivelConRiesgo(nivel), esperado);
      });
    });
  });
}
