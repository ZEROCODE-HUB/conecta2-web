import 'package:flutter_test/flutter_test.dart';
import 'package:conecta2/components/admin_estadsticas/helpers/classification.dart';

void main() {
  group('tipoKeyFromTitulo', () {
    test('identifies CDI by acronym and by full name', () {
      expect(tipoKeyFromTitulo('CDI'), 'cdi');
      expect(tipoKeyFromTitulo('Inventario de Depresión Infantil'), 'cdi');
      expect(tipoKeyFromTitulo('cdi - versión 2024'), 'cdi');
    });

    test('identifies Rosenberg autoestima', () {
      expect(tipoKeyFromTitulo('Autoestima Rosenberg'), 'autoestima');
      expect(tipoKeyFromTitulo('Escala Rosemberg'), 'autoestima');
      expect(tipoKeyFromTitulo('Test de autoestima'), 'autoestima');
    });

    test('identifies Beck / BDI', () {
      expect(tipoKeyFromTitulo('Beck Depression Inventory'), 'bdi');
      expect(tipoKeyFromTitulo('BDI-II'), 'bdi');
    });

    test('identifies SRQ / RQC family', () {
      expect(tipoKeyFromTitulo('SRQ-20'), 'srq');
      expect(tipoKeyFromTitulo('RQC Niños'), 'srq');
    });

    test('identifies sustancias / ASSIST', () {
      expect(tipoKeyFromTitulo('ASSIST Sustancias'), 'sustancias');
      expect(tipoKeyFromTitulo('Consumo de SPA'), 'sustancias');
    });

    test('returns otros when no keyword matches', () {
      expect(tipoKeyFromTitulo('Encuesta de satisfacción'), 'otros');
      expect(tipoKeyFromTitulo(''), 'otros');
    });
  });

  group('normalizeGenero', () {
    test('canonicalizes masculine variants', () {
      expect(normalizeGenero('Masculino'), 'Masculino');
      expect(normalizeGenero('M'), 'Masculino');
      expect(normalizeGenero('masc'), 'Masculino');
      expect(normalizeGenero('Hombre'), 'Masculino');
      expect(normalizeGenero('H'), 'Masculino');
    });

    test('canonicalizes feminine variants', () {
      expect(normalizeGenero('Femenino'), 'Femenino');
      expect(normalizeGenero('F'), 'Femenino');
      expect(normalizeGenero('Mujer'), 'Femenino');
    });

    test('falls back to Otro for unknown / null / empty', () {
      expect(normalizeGenero(null), 'Otro');
      expect(normalizeGenero(''), 'Otro');
      expect(normalizeGenero('No binario'), 'Otro');
      expect(normalizeGenero('   '), 'Otro');
    });
  });

  group('rangoEdadFromEdad', () {
    test('maps ages inside the standard buckets', () {
      expect(rangoEdadFromEdad(10), '10-12');
      expect(rangoEdadFromEdad(12), '10-12');
      expect(rangoEdadFromEdad(13), '13-15');
      expect(rangoEdadFromEdad(15), '13-15');
      expect(rangoEdadFromEdad(16), '16-18');
      expect(rangoEdadFromEdad(18), '16-18');
    });

    test('falls back for ages outside the expected range', () {
      expect(rangoEdadFromEdad(null), kRangoEdadFallback);
      expect(rangoEdadFromEdad(9), kRangoEdadFallback);
      expect(rangoEdadFromEdad(19), kRangoEdadFallback);
      expect(rangoEdadFromEdad(50), kRangoEdadFallback);
    });
  });

  group('numericValue', () {
    test('uses TrueAndFalse when present and positive', () {
      expect(numericValue({'TrueAndFalse': 3}), 3);
      expect(numericValue({'TrueAndFalse': 0, 'Respuesta': '2'}), 2,
          reason: '0 is ignored, falls through to Respuesta');
    });

    test('parses numeric string answers', () {
      expect(numericValue({'Respuesta': '4'}), 4);
      expect(numericValue({'respuesta': '1'}), 1);
    });

    test('maps Spanish frequency labels to expected scores', () {
      expect(numericValue({'Respuesta': 'Nunca'}), 0);
      expect(numericValue({'Respuesta': 'Pocas veces'}), 1);
      expect(numericValue({'Respuesta': 'A veces'}), 2);
      expect(numericValue({'Respuesta': 'Frecuentemente'}), 3);
      expect(numericValue({'Respuesta': 'Siempre'}), 4);
    });

    test('maps yes/no answers', () {
      expect(numericValue({'Respuesta': 'Sí'}), 1);
      expect(numericValue({'Respuesta': 'Si'}), 1);
      expect(numericValue({'Respuesta': 'No'}), 0);
    });

    test('falls back to 0 on unknown or empty answers', () {
      expect(numericValue({}), 0);
      expect(numericValue({'Respuesta': ''}), 0);
      expect(numericValue({'Respuesta': 'algo raro'}), 0);
    });
  });

  group('classifyNivel (clinical thresholds)', () {
    test('autoestima (Rosenberg): cutpoints 30 / 26', () {
      expect(
          classifyNivel('Autoestima', const [], puntajeTotal: 31), 'Elevada');
      expect(
          classifyNivel('Autoestima', const [], puntajeTotal: 30), 'Elevada');
      expect(classifyNivel('Autoestima', const [], puntajeTotal: 29), 'Media');
      expect(classifyNivel('Autoestima', const [], puntajeTotal: 26), 'Media');
      expect(classifyNivel('Autoestima', const [], puntajeTotal: 25), 'Baja');
      expect(classifyNivel('Autoestima', const [], puntajeTotal: 10), 'Baja');
    });

    test('CDI: cutpoints 20 / 7', () {
      expect(classifyNivel('CDI', const [], puntajeTotal: 25), 'Severo');
      expect(classifyNivel('CDI', const [], puntajeTotal: 20), 'Severo');
      expect(classifyNivel('CDI', const [], puntajeTotal: 19), 'Leve');
      expect(classifyNivel('CDI', const [], puntajeTotal: 7), 'Leve');
      expect(classifyNivel('CDI', const [], puntajeTotal: 6),
          'Sin sintomatología');
      expect(classifyNivel('CDI', const [], puntajeTotal: 0),
          'Sin sintomatología');
    });

    test('Beck (BDI): cutpoints 29 / 20 / 14', () {
      expect(classifyNivel('Beck', const [], puntajeTotal: 30), 'Grave');
      expect(classifyNivel('Beck', const [], puntajeTotal: 29), 'Grave');
      expect(classifyNivel('Beck', const [], puntajeTotal: 28), 'Moderada');
      expect(classifyNivel('Beck', const [], puntajeTotal: 20), 'Moderada');
      expect(classifyNivel('Beck', const [], puntajeTotal: 19), 'Leve');
      expect(classifyNivel('Beck', const [], puntajeTotal: 14), 'Leve');
      expect(classifyNivel('Beck', const [], puntajeTotal: 13), 'Mínima');
    });

    test('SRQ/RQC: cutpoints 11 / 4', () {
      expect(classifyNivel('SRQ-20', const [], puntajeTotal: 12), 'Severo');
      expect(classifyNivel('SRQ', const [], puntajeTotal: 11), 'Severo');
      expect(classifyNivel('SRQ', const [], puntajeTotal: 10), 'Moderada');
      expect(classifyNivel('SRQ', const [], puntajeTotal: 4), 'Moderada');
      expect(classifyNivel('SRQ', const [], puntajeTotal: 3), 'Sin alerta');
    });

    test('Sustancias (ASSIST): cutpoints 27 / 4', () {
      expect(classifyNivel('ASSIST', const [], puntajeTotal: 30), 'Severo');
      expect(classifyNivel('Consumo de sustancias', const [], puntajeTotal: 10),
          'Moderada');
      expect(
          classifyNivel('Sustancias', const [], puntajeTotal: 2), 'Sin alerta');
    });

    test('default / otros: 20/10/4 thresholds', () {
      expect(classifyNivel('Encuesta general', const [], puntajeTotal: 25),
          'Grave');
      expect(classifyNivel('Encuesta general', const [], puntajeTotal: 15),
          'Severo');
      expect(classifyNivel('Encuesta general', const [], puntajeTotal: 5),
          'Moderada');
      expect(classifyNivel('Encuesta general', const [], puntajeTotal: 1),
          'Sin alerta');
    });

    test('when puntajeTotal is missing, it sums item values', () {
      final items = [
        {'Respuesta': '5'},
        {'Respuesta': '3'},
        {'Respuesta': '2'},
      ];
      // CDI with sum=10 → Leve
      expect(classifyNivel('CDI', items), 'Leve');
    });

    test('when puntajeTotal is 0, it still sums items', () {
      final items = [
        {'Respuesta': 'Siempre'}, // 4
        {'Respuesta': 'Siempre'}, // 4
      ];
      // Default tipo with sum=8 → Moderada
      expect(classifyNivel('Otra cosa', items, puntajeTotal: 0), 'Moderada');
    });
  });

  group('mapNivelToBucket', () {
    const genericBuckets = ['Sin alerta', 'Moderada', 'Severo', 'Grave'];

    test('returns the nivel unchanged when already in buckets', () {
      expect(mapNivelToBucket('Severo', genericBuckets), 'Severo');
      expect(mapNivelToBucket('Sin alerta', genericBuckets), 'Sin alerta');
    });

    test('collapses Leve and Mínima into moderate/healthy buckets', () {
      // CDI 'Leve' into generic buckets → Moderada (closest moderate).
      expect(mapNivelToBucket('Leve', genericBuckets), 'Moderada');
      // Beck 'Mínima' → healthy bucket.
      expect(mapNivelToBucket('Mínima', genericBuckets), 'Sin alerta');
    });

    test('autoestima Baja maps to the severo bucket', () {
      // Baja autoestima es clínicamente un nivel de alerta. Cuando hay un
      // bucket 'Severo' disponible, se prefiere sobre 'Grave' (reservado
      // para niveles catastróficos como Beck grave).
      expect(mapNivelToBucket('Baja', genericBuckets), 'Severo');
    });

    test('autoestima Elevada maps to healthy bucket', () {
      expect(mapNivelToBucket('Elevada', genericBuckets), 'Sin alerta');
    });

    test('Grave stays in the last/critical bucket', () {
      expect(mapNivelToBucket('Grave', genericBuckets), 'Grave');
    });

    test('Sin sintomatología collapses to Sin alerta', () {
      expect(
          mapNivelToBucket('Sin sintomatología', genericBuckets), 'Sin alerta');
    });

    test('respects buckets that do not include the usual labels', () {
      const autoestimaBuckets = ['Baja', 'Media', 'Elevada'];
      // When mapping a moderate-ish label ('Leve') into autoestima buckets,
      // it should pick a middle-of-the-list fallback.
      expect(
          autoestimaBuckets
              .contains(mapNivelToBucket('Leve', autoestimaBuckets)),
          isTrue);
    });
  });
}
