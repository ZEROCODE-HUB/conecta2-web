import 'package:conecta2/custom_code/actions/informe_pdf/helpers/pdf_identificacion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('numeroIdentificacionPdf', () {
    test('usa identidad recortada', () {
      expect(numeroIdentificacionPdf({'identidad': ' 1043123456 '}),
          '1043123456');
    });

    test('vacío, nulo o ausente → No registrado (nunca el UID)', () {
      expect(numeroIdentificacionPdf({'identidad': '   '}), 'No registrado');
      expect(numeroIdentificacionPdf({'identidad': null}), 'No registrado');
      expect(numeroIdentificacionPdf({'uid': '8vr9evXYw9abc'}),
          'No registrado');
      expect(numeroIdentificacionPdf(null), 'No registrado');
    });

    test('número guardado como int', () {
      expect(numeroIdentificacionPdf({'identidad': 1043123456}), '1043123456');
    });
  });
}
