import 'package:flutter_test/flutter_test.dart';
import 'package:conecta2/backend/schema/structs/index.dart';
import 'package:conecta2/custom_code/widgets/tamizaje_data_table/helpers/data_transformers.dart';
import 'package:conecta2/dashboard/web/encuestas/editar/widgets/tamizajes_niveles.dart';
import 'package:conecta2/tamizajes/shared/assist_utils.dart';
import 'package:conecta2/tamizajes/shared/nivel_respuesta.dart';

List<AlertaStruct> _rangos(List<List<Object>> r) => [
      for (final x in r)
        AlertaStruct(nivel: x[0] as String, min: x[1] as int, max: x[2] as int),
    ];

String? _nivel(String categoria, num puntaje, List<List<Object>> r) =>
    nivelPorRangos(categoria: categoria, puntaje: puntaje, alertas: _rangos(r));

void main() {
  group('nivelPorRangos: fuera de todos los rangos → Sin alerta', () {
    const cdiConHueco = [
      ['Sin sintomatología', 0, 1],
      ['Leve', 5, 10],
      ['Severo', 11, 999],
    ];

    test('dentro de un rango toma ese nivel', () {
      expect(_nivel('CDI', 0, cdiConHueco), 'Sin sintomatología');
      expect(_nivel('CDI', 5, cdiConHueco), 'Leve');
      expect(_nivel('CDI', 10, cdiConHueco), 'Leve');
      expect(_nivel('CDI', 500, cdiConHueco), 'Severo');
    });

    test('hueco: Leve 5–10 con 2 puntos → Sin alerta', () {
      expect(_nivel('CDI', 2, cdiConHueco), kSinAlerta);
      expect(_nivel('CDI', 4, cdiConHueco), kSinAlerta);
    });

    test('por debajo y por encima de todos los rangos → Sin alerta', () {
      const staic = [
        ['Sin sintomatología', 18, 26],
        ['Leve', 27, 35],
        ['Moderado', 36, 44],
        ['Severo', 45, 54],
      ];
      expect(_nivel('Escala ansiedad', 10, staic), kSinAlerta);
      expect(_nivel('Escala ansiedad', 60, staic), kSinAlerta);
      expect(_nivel('Escala ansiedad', 38, staic), 'Moderado');
    });

    test('Autoestima sin excepción: debajo de "Baja" → Sin alerta', () {
      // ESCALA DE AUTOESTIMA CHICOS DE 14-15 AÑOS (Firestore, 2026-10-16).
      const chicos1415 = [
        ['Autoestima Baja', 29, 30],
        ['Autoestima Media', 30, 35],
        ['Autoestima Elevada', 36, 40],
      ];
      expect(_nivel('Escala autoestima', 23, chicos1415), kSinAlerta);
      // Rangos cruzados: gana el primero de la lista.
      expect(_nivel('Escala autoestima', 30, chicos1415), 'Baja');
      expect(_nivel('Escala autoestima', 31, chicos1415), 'Media');
      expect(_nivel('Escala autoestima', 38, chicos1415), 'Elevada');
    });

    test('Beck por nombre de nivel, no por posición', () {
      const beck = [
        ['Grave', 29, 63],
        ['Mínima', 0, 13],
        ['Leve', 14, 19],
        ['Moderada', 20, 28],
      ];
      expect(_nivel('Depresión Beck', 30, beck), 'Grave');
      expect(_nivel('Depresión Beck', 15, beck), 'Leve');
    });

    test('sin rangos de la categoría → null (cortes por defecto)', () {
      expect(_nivel('CDI', 12, const []), isNull);
      expect(_nivel('CDI', 12, const [['Subescala 1', 0, 10]]), isNull);
      expect(_nivel('SRQ', 5, const [['Sin alerta', 0, 8]]), isNull);
    });
  });

  group('nivelPorPuntaje', () {
    test('con rangos usa la regla estricta', () {
      expect(
        nivelPorPuntaje(
          categoria: 'CDI',
          puntaje: 2,
          alertas: _rangos(const [
            ['Sin sintomatología', 0, 1],
            ['Leve', 5, 10],
          ]),
        ),
        kSinAlerta,
      );
    });

    test('sin rangos usa los cortes clínicos por defecto', () {
      expect(
        nivelPorPuntaje(categoria: 'CDI', puntaje: 12, alertas: const []),
        'Leve',
      );
    });
  });

  group('nivelConRiesgo / gravedadNivel / esSinAlertaPorRango', () {
    test('Sin alerta no es riesgo ni tiene gravedad', () {
      expect(nivelConRiesgo(kSinAlerta), isFalse);
      expect(gravedadNivel(kSinAlerta), 0);
    });

    test('gravedad de los niveles', () {
      expect(gravedadNivel('Sin sintomatología'), 0);
      expect(gravedadNivel('Mínima'), 0);
      expect(gravedadNivel('Elevada'), 0);
      expect(gravedadNivel('Media'), 0);
      expect(gravedadNivel('Leve'), 1);
      expect(gravedadNivel('Moderada'), 1);
      expect(gravedadNivel('Severo'), 2);
      expect(gravedadNivel('Grave'), 2);
      expect(gravedadNivel('Baja'), 2);
    });

    test('"Sin alerta" es fuera de rango solo en los tamizajes por rangos', () {
      expect(esSinAlertaPorRango('CDI', kSinAlerta), isTrue);
      expect(esSinAlertaPorRango('Consumo de SPA', kSinAlerta), isTrue);
      expect(esSinAlertaPorRango('SRQ', kSinAlerta), isFalse);
      expect(esSinAlertaPorRango('CDI', 'Leve'), isFalse);
    });
  });

  group('ASSIST por sustancia', () {
    final alertas = [
      {'sustancia': 'Tabaco', 'nivel': 'Bajo', 'min': 0, 'max': 3},
      {'sustancia': 'Tabaco', 'nivel': 'Moderado', 'min': 10, 'max': 26},
      {'sustancia': 'Tabaco', 'nivel': 'Alto', 'min': 27, 'max': 0},
      {'sustancia': 'Cannabis', 'nivel': 'Bajo', 'min': 2, 'max': 3},
      {'sustancia': 'Cannabis', 'nivel': 'Moderado', 'min': 4, 'max': 26},
      {'sustancia': 'Cannabis', 'nivel': 'Alto', 'min': 27, 'max': 0},
    ];

    test('dentro de rango y último nivel sin tope', () {
      expect(nivelPorSustancia('Tabaco', 2, alertas).nivel, 'Bajo');
      expect(nivelPorSustancia('Tabaco', 12, alertas).nivel, 'Moderado');
      expect(nivelPorSustancia('Tabaco', 40, alertas).nivel, 'Alto');
    });

    test('hueco o debajo de todo → Sin alerta', () {
      expect(nivelPorSustancia('Tabaco', 6, alertas).nivel, kSinAlerta);
      expect(nivelPorSustancia('Cannabis', 0, alertas).nivel, kSinAlerta);
    });

    test('sin rangos configurados usa los cortes OMS (contiguos)', () {
      expect(nivelPorSustancia('Cocaína', 0, alertas).nivel, 'Bajo');
      expect(nivelPorSustancia('Cocaína', 5, alertas).nivel, 'Moderado');
    });

    test('peorNivel ignora Sin alerta', () {
      expect(peorNivel([kSinAlerta, 'Bajo']), 'Bajo');
      expect(peorNivel([kSinAlerta]), '');
      expect(bucketStats(kSinAlerta), kSinAlerta);
    });
  });

  group('Tabulación General (procesarRespuestasTamizaje)', () {
    Map<String, dynamic> encuesta(List<List<Object>> r) => {
          'categoria': 'Escala autoestima',
          'titulo': 'ESCALA DE AUTOESTIMA CHICOS DE 14-15 AÑOS',
          'Preguntas': const [],
          'alertas': [
            for (final x in r) {'nivel': x[0], 'min': x[1], 'max': x[2]},
          ],
        };
    const rangos = [
      ['Autoestima Baja', 29, 30],
      ['Autoestima Media', 30, 35],
      ['Autoestima Elevada', 36, 40],
    ];

    String nivelFila(int puntajeTotal) {
      final r = procesarRespuestasTamizaje(
          encuesta(rangos), {'puntajeTotal': puntajeTotal, 'test': const []});
      final niveles = r['nivelRiesgoPorSustancia'] as Map<String, String>;
      return niveles.values.single;
    }

    test('usa el puntaje total y la misma regla que el detalle', () {
      expect(nivelFila(23), kSinAlerta);
      expect(nivelFila(30), 'Baja');
      expect(nivelFila(37), 'Elevada');
    });
  });
}
