import 'package:conecta2/custom_code/widgets/mapa_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseCoordenada', () {
    double? lat(dynamic v) => parseCoordenada(v, esLatitud: true);
    double? lng(dynamic v) => parseCoordenada(v, esLatitud: false);

    test('decimal normal y número', () {
      expect(lat('10.39339'), 10.39339);
      expect(lng('-75.4832'), -75.4832);
      expect(lat(10.5), 10.5);
    });

    test('coma decimal', () {
      expect(lat('10,3932'), 10.3932);
      expect(lng('-75,4832'), -75.4832);
    });

    test('puntos de miles de la carga inicial (casos reales)', () {
      expect(lat('1.038.489.798.216.250'), closeTo(10.384897982, 1e-9));
      expect(lng('-7.545.956.605.142.270'), closeTo(-75.459566051, 1e-9));
      expect(lat('1.037.116'), closeTo(10.37116, 1e-9));
      expect(lng('-7.547.447'), closeTo(-75.47447, 1e-9));
      expect(lat('10.421.933'), closeTo(10.421933, 1e-9));
      expect(lng('-75.460.603'), closeTo(-75.460603, 1e-9));
    });

    test('un solo dígito entero si dos no caen en Colombia', () {
      expect(lat('7.119.300'), closeTo(7.1193, 1e-9));
    });

    test('valores inválidos', () {
      expect(lat(null), isNull);
      expect(lat(''), isNull);
      expect(lat('abc'), isNull);
      // Longitud copiada de la latitud ("Mis Estimulaciones").
      expect(lng('10.393391039339'), isNull);
      expect(lat('48.8566'), isNull);
    });
  });

  test('normalizarTexto y enFormatoTitulo', () {
    expect(normalizarTexto('  INST. COLOMBO  HOLANDÉS '),
        'inst. colombo holandes');
    expect(normalizarTexto('Montería'), normalizarTexto('MONTERIA'));
    expect(enFormatoTitulo('CARTAGENA'), 'Cartagena');
    expect(enFormatoTitulo('san  juan'), 'San Juan');
  });

  group('agregados', () {
    final respuestas = [
      RespuestaMapa(
          usuario: 'users/a',
          colegio: 'biffi',
          tamizaje: 'CDI',
          fecha: DateTime(2025, 3, 1)),
      RespuestaMapa(
          usuario: 'users/a',
          colegio: 'biffi',
          tamizaje: 'CDI',
          fecha: DateTime(2026, 3, 1)),
      RespuestaMapa(
          usuario: 'users/b',
          colegio: 'biffi',
          tamizaje: 'CDI',
          fecha: DateTime(2026, 5, 1)),
      RespuestaMapa(
          usuario: 'users/b',
          colegio: 'biffi',
          tamizaje: 'ASSIST',
          fecha: DateTime(2026, 5, 1)),
      RespuestaMapa(
          usuario: 'users/c',
          colegio: 'aspaen',
          tamizaje: 'CDI',
          fecha: DateTime(2024, 1, 1)),
    ];

    test('colegios intervenidos por año', () {
      expect(colegiosIntervenidos(respuestas, null), {'biffi', 'aspaen'});
      expect(colegiosIntervenidos(respuestas, 2026), {'biffi'});
      expect(colegiosIntervenidos(respuestas, 2023), isEmpty);
    });

    test('años disponibles, del más reciente', () {
      expect(anosConRespuestas(respuestas), [2026, 2025, 2024]);
    });

    test('estudiantes distintos por tamizaje', () {
      final todos = estudiantesPorTamizaje(respuestas, 'biffi', null);
      expect(todos.map((e) => '${e.key}:${e.value}'), ['CDI:2', 'ASSIST:1']);
      final de2025 = estudiantesPorTamizaje(respuestas, 'biffi', 2025);
      expect(de2025.map((e) => '${e.key}:${e.value}'), ['CDI:1']);
    });
  });
}
