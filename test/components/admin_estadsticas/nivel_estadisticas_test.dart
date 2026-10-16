import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conecta2/backend/schema/encuestas_record.dart';
import 'package:conecta2/components/admin_estadsticas/helpers/stats_calculator.dart';
import 'package:conecta2/tamizajes/shared/nivel_respuesta.dart';

/// Referencia mínima para construir un [EncuestasRecord] sin Firebase.
class _FakeRef implements DocumentReference<Map<String, dynamic>> {
  _FakeRef(this.path);

  @override
  final String path;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

EncuestasRecord _encuesta(
  String categoria,
  String titulo,
  List<List<Object>> rangos,
) =>
    EncuestasRecord.getDocumentFromData({
      'categoria': categoria,
      'titulo': titulo,
      'alertas': [
        for (final r in rangos) {'nivel': r[0], 'min': r[1], 'max': r[2]},
      ],
    }, _FakeRef('Encuestas/$titulo'));

String _nivel(EncuestasRecord? e, int puntaje, {String titulo = ''}) =>
    nivelParaEstadisticas(
      encuesta: e,
      respuesta: {'puntajeTotal': puntaje},
      titulo: titulo.isNotEmpty ? titulo : (e?.titulo ?? ''),
      items: const [],
    );

/// Nivel tal como lo cuenta la gráfica del tipo.
String _barra(EncuestasRecord e, int puntaje, TamizajeTipo tipo) =>
    mapNivelToBucket(_nivel(e, puntaje), tipo.niveles);

void main() {
  // Rangos configurados hoy en Firestore (datos de prueba, 2026-10-16).
  final cdi = _encuesta('CDI', 'CDI', [
    ['Sin sintomatología', 0, 18],
    ['Leve', 19, 26],
    ['Severo', 27, 54],
  ]);
  final staic = _encuesta('Escala ansiedad', 'Inventario de Ansiedad (STAIC)', [
    ['Sin sintomatología', 18, 26],
    ['Leve', 27, 35],
    ['Moderado', 36, 44],
    ['Severo', 45, 54],
  ]);
  final beck = _encuesta('Depresión Beck', 'Inventario de Depresión de Beck', [
    ['Mínima', 0, 13],
    ['Leve', 14, 19],
    ['Moderada', 20, 28],
    ['Grave', 29, 999],
  ]);
  final autoestima =
      _encuesta('Escala autoestima', 'ESCALA DE AUTOESTIMA CHICOS 12-13', [
    ['Autoestima Baja', 0, 30],
    ['Autoestima Media', 31, 35],
    ['Autoestima Elevada', 36, 999],
  ]);
  final srq = _encuesta('SRQ', 'SRQ The Self Reporting Questionnaire', [
    ['Sin alerta', 0, 8],
    ['Subescala 1', 9, 11],
    ['Subescala 2', 12, 30],
  ]);
  final rqc = _encuesta('RQC', 'CUESTIONARIO DE SÍNTOMAS RQC', [
    ['Sin alerta', 0, 0],
    ['Subescala 1', 1, 3],
    ['Subescala 2', 4, 10],
  ]);

  group('nivelParaEstadisticas usa los rangos del tamizaje', () {
    test('CDI 0–18 / 19–26 / 27–54', () {
      expect(_nivel(cdi, 17), 'Sin sintomatología');
      expect(_nivel(cdi, 18), 'Sin sintomatología');
      expect(_nivel(cdi, 19), 'Leve');
      expect(_nivel(cdi, 26), 'Leve');
      expect(_nivel(cdi, 27), 'Severo');
      expect(_nivel(cdi, 33), 'Severo');
    });

    test('Ansiedad (STAIC): 38 → Moderado', () {
      expect(_nivel(staic, 38), 'Moderado');
      expect(_nivel(staic, 20), 'Sin sintomatología');
      expect(_nivel(staic, 50), 'Severo');
    });

    test('Beck: 28 → Moderada, 30 → Grave', () {
      expect(_nivel(beck, 13), 'Mínima');
      expect(_nivel(beck, 28), 'Moderada');
      expect(_nivel(beck, 30), 'Grave');
    });

    test('Autoestima con rangos propios: 27 → Baja', () {
      expect(_nivel(autoestima, 27), 'Baja');
      expect(_nivel(autoestima, 33), 'Media');
      expect(_nivel(autoestima, 38), 'Elevada');
    });

    test('SRQ: 7 → Sin alerta, 14 → Subescala 2', () {
      expect(_nivel(srq, 7), 'Sin alerta');
      expect(_nivel(srq, 10), 'Subescala 1');
      expect(_nivel(srq, 14), 'Subescala 2');
    });

    test('RQC: 0 → Sin alerta, 5 → Subescala 2', () {
      expect(_nivel(rqc, 0), 'Sin alerta');
      expect(_nivel(rqc, 2), 'Subescala 1');
      expect(_nivel(rqc, 5), 'Subescala 2');
    });

    test('sin encuesta usa los cortes por defecto de classifyNivel', () {
      expect(_nivel(null, 17, titulo: 'CDI'),
          classifyNivel('CDI', const [], puntajeTotal: 17));
    });

    test('encuesta sin categoría usa los cortes por defecto', () {
      final sinCategoria = _encuesta('', 'Inventario de Beck', const []);
      expect(_nivel(sinCategoria, 30), 'Grave');
    });
  });

  group('cada nivel cae en su barra de la gráfica', () {
    test('CDI: 17/26/27/33 → Sin sintomatología, Leve, Severo, Severo', () {
      expect(
        [17, 26, 27, 33].map((p) => _barra(cdi, p, TamizajeTipo.cdi)),
        ['Sin sintomatología', 'Leve', 'Severo', 'Severo'],
      );
    });

    test('Autoestima, Ansiedad, Beck, SRQ y RQC', () {
      expect(_barra(autoestima, 27, TamizajeTipo.autoestima), 'Baja');
      expect(_barra(staic, 38, TamizajeTipo.ansiedad), 'Moderado');
      expect(_barra(beck, 28, TamizajeTipo.beck), 'Moderada');
      expect(_barra(srq, 7, TamizajeTipo.srq), 'Sin alerta');
      expect(_barra(rqc, 5, TamizajeTipo.rqc), 'Subescala 2');
    });
  });

  group('mapNivelToBucket con etiquetas de cada tamizaje', () {
    const todas = ['Sin alerta', 'Moderada', 'Severo', 'Grave'];
    const ejeAutoestima = ['Baja', 'Media', 'Elevada'];

    test('"Autoestima Baja/Media/Elevada" van a Baja/Media/Elevada', () {
      expect(mapNivelToBucket('Autoestima Baja', ejeAutoestima), 'Baja');
      expect(mapNivelToBucket('Autoestima Media', ejeAutoestima), 'Media');
      expect(mapNivelToBucket('Autoestima Elevada', ejeAutoestima), 'Elevada');
    });

    test('vista Todas: subescalas en su tramo', () {
      expect(mapNivelToBucket('Subescala 1', todas), 'Moderada');
      expect(mapNivelToBucket('Subescala 2', todas), 'Severo');
      expect(mapNivelToBucket('Autoestima Baja', todas), 'Severo');
    });
  });

  group('tipoKeyDe decide por la categoría', () {
    test('categoría manda sobre el título', () {
      expect(
          tipoKeyDe(categoria: 'Escala ansiedad', titulo: 'Tamizaje prueba'),
          'ansiedad');
      expect(tipoKeyDe(categoria: 'Depresión Beck', titulo: 'BDI-2'), 'bdi');
      expect(tipoKeyDe(categoria: 'CRQ / SRQ', titulo: 'x'), 'srq');
    });

    test('sin categoría usa el título', () {
      expect(tipoKeyDe(categoria: '', titulo: 'CDI'), 'cdi');
      expect(tipoKeyDe(titulo: 'Escala de autoestima'), 'autoestima');
    });
  });
}
