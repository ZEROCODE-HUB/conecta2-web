import 'package:conecta2/auth/correo_registrado.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizarCorreo', () {
    test('quita espacios y pasa a minúsculas', () {
      expect(normalizarCorreo('  MLopez@GuidoUlloa.com '),
          'mlopez@guidoulloa.com');
    });

    test('vacío sigue vacío', () {
      expect(normalizarCorreo('   '), '');
    });
  });

  group('mensajeCorreoRegistradoPor', () {
    test('incluye correo, nombre y rol', () {
      expect(
        mensajeCorreoRegistradoPor(
            'mlopez@guidoulloa.com', 'Mauricio Lopez', 'Adolescente'),
        'El correo mlopez@guidoulloa.com ya pertenece al usuario '
        '"Mauricio Lopez" (Adolescente).',
      );
    });

    test('sin nombre ni rol', () {
      expect(
        mensajeCorreoRegistradoPor('a@b.co', ' ', ''),
        'El correo a@b.co ya pertenece al usuario "otro usuario".',
      );
    });
  });
}
