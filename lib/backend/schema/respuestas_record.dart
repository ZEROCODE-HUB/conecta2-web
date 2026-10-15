import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RespuestasRecord extends FirestoreRecord {
  RespuestasRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "User_respuesta" field.
  DocumentReference? _userRespuesta;
  DocumentReference? get userRespuesta => _userRespuesta;
  bool hasUserRespuesta() => _userRespuesta != null;

  // "Fecha" field.
  DateTime? _fecha;
  DateTime? get fecha => _fecha;
  bool hasFecha() => _fecha != null;

  // "Numero_pregunta" field.
  int? _numeroPregunta;
  int get numeroPregunta => _numeroPregunta ?? 0;
  bool hasNumeroPregunta() => _numeroPregunta != null;

  // "Titlo" field.
  String? _titlo;
  String get titlo => _titlo ?? '';
  bool hasTitlo() => _titlo != null;

  // "Desc" field.
  String? _desc;
  String get desc => _desc ?? '';
  bool hasDesc() => _desc != null;

  // "Respusta" field.
  List<RespuestaEncuestaStruct>? _respusta;
  List<RespuestaEncuestaStruct> get respusta => _respusta ?? const [];
  bool hasRespusta() => _respusta != null;

  // "test" field.
  List<RespuestaTestStruct>? _test;
  List<RespuestaTestStruct> get test => _test ?? const [];
  bool hasTest() => _test != null;

  // "notasProfesional" field.
  String? _notasProfesional;
  String get notasProfesional => _notasProfesional ?? '';
  bool hasNotasProfesional() => _notasProfesional != null;

  // "invalidado" field.
  bool? _invalidado;
  bool get invalidado => _invalidado ?? false;
  bool hasInvalidado() => _invalidado != null;

  // "fechaInvalidacion" field.
  DateTime? _fechaInvalidacion;
  DateTime? get fechaInvalidacion => _fechaInvalidacion;
  bool hasFechaInvalidacion() => _fechaInvalidacion != null;

  // "puntajeTotal" field.
  int? _puntajeTotal;
  int get puntajeTotal => _puntajeTotal ?? 0;
  bool hasPuntajeTotal() => _puntajeTotal != null;

  // "alertasEspeciales" field.
  List<String>? _alertasEspeciales;
  List<String> get alertasEspeciales => _alertasEspeciales ?? const [];
  bool hasAlertasEspeciales() => _alertasEspeciales != null;

  // "realizadoPor" field. (Profesional que realizó el tamizaje manual)
  DocumentReference? _realizadoPor;
  DocumentReference? get realizadoPor => _realizadoPor;
  bool hasRealizadoPor() => _realizadoPor != null;

  // "tipoTamizaje" field. ('manual' | 'app')
  String? _tipoTamizaje;
  String get tipoTamizaje => _tipoTamizaje ?? 'app';
  bool hasTipoTamizaje() => _tipoTamizaje != null;

  // "nivelAlerta" field: nivel calculado al guardar (calcularNivelRespuesta).
  // Lo lee la Cloud Function de alertas a acudientes.
  String? _nivelAlerta;
  String get nivelAlerta => _nivelAlerta ?? '';
  bool hasNivelAlerta() => _nivelAlerta != null;

  // "motivoInvalidacion" field.
  String? _motivoInvalidacion;
  String get motivoInvalidacion => _motivoInvalidacion ?? '';
  bool hasMotivoInvalidacion() => _motivoInvalidacion != null;

  // "invalidadoPor" field.
  DocumentReference? _invalidadoPor;
  DocumentReference? get invalidadoPor => _invalidadoPor;
  bool hasInvalidadoPor() => _invalidadoPor != null;

  // "bloqueadoHasta" field.
  DateTime? _bloqueadoHasta;
  DateTime? get bloqueadoHasta => _bloqueadoHasta;
  bool hasBloqueadoHasta() => _bloqueadoHasta != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userRespuesta = snapshotData['User_respuesta'] as DocumentReference?;
    _fecha = snapshotData['Fecha'] as DateTime?;
    _numeroPregunta = castToType<int>(snapshotData['Numero_pregunta']);
    _titlo = snapshotData['Titlo'] as String?;
    _desc = snapshotData['Desc'] as String?;
    _respusta = getStructList(
      snapshotData['Respusta'],
      RespuestaEncuestaStruct.fromMap,
    );
    _test = getStructList(
      snapshotData['test'],
      RespuestaTestStruct.fromMap,
    );
    _notasProfesional = snapshotData['notasProfesional'] as String?;
    _invalidado = snapshotData['invalidado'] as bool?;
    _fechaInvalidacion = snapshotData['fechaInvalidacion'] as DateTime?;
    _puntajeTotal = castToType<int>(snapshotData['puntajeTotal']);
    _alertasEspeciales = getDataList(snapshotData['alertasEspeciales']);
    _realizadoPor = snapshotData['realizadoPor'] as DocumentReference?;
    _tipoTamizaje = snapshotData['tipoTamizaje'] as String?;
    _nivelAlerta = snapshotData['nivelAlerta'] as String?;
    _motivoInvalidacion =
        snapshotData['motivoInvalidacion'] as String?;
    _invalidadoPor =
        snapshotData['invalidadoPor'] as DocumentReference?;
    _bloqueadoHasta = snapshotData['bloqueadoHasta'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('Respuestas')
          : FirebaseFirestore.instance.collectionGroup('Respuestas');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('Respuestas').doc(id);

  static Stream<RespuestasRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RespuestasRecord.fromSnapshot(s));

  static Future<RespuestasRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RespuestasRecord.fromSnapshot(s));

  static RespuestasRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RespuestasRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RespuestasRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RespuestasRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RespuestasRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RespuestasRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRespuestasRecordData({
  DocumentReference? userRespuesta,
  DateTime? fecha,
  int? numeroPregunta,
  String? titlo,
  String? desc,
  String? notasProfesional,
  bool? invalidado,
  DateTime? fechaInvalidacion,
  int? puntajeTotal,
  List<String>? alertasEspeciales,
  DocumentReference? realizadoPor,
  String? tipoTamizaje,
  String? motivoInvalidacion,
  DocumentReference? invalidadoPor,
  DateTime? bloqueadoHasta,
  String? nivelAlerta,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'User_respuesta': userRespuesta,
      'Fecha': fecha,
      'Numero_pregunta': numeroPregunta,
      'Titlo': titlo,
      'Desc': desc,
      'notasProfesional': notasProfesional,
      'invalidado': invalidado,
      'fechaInvalidacion': fechaInvalidacion,
      'puntajeTotal': puntajeTotal,
      'alertasEspeciales': alertasEspeciales,
      'realizadoPor': realizadoPor,
      'tipoTamizaje': tipoTamizaje,
      'motivoInvalidacion': motivoInvalidacion,
      'invalidadoPor': invalidadoPor,
      'bloqueadoHasta': bloqueadoHasta,
      'nivelAlerta': nivelAlerta,
    }.withoutNulls,
  );

  return firestoreData;
}

class RespuestasRecordDocumentEquality implements Equality<RespuestasRecord> {
  const RespuestasRecordDocumentEquality();

  @override
  bool equals(RespuestasRecord? e1, RespuestasRecord? e2) {
    const listEquality = ListEquality();
    return e1?.userRespuesta == e2?.userRespuesta &&
        e1?.fecha == e2?.fecha &&
        e1?.numeroPregunta == e2?.numeroPregunta &&
        e1?.titlo == e2?.titlo &&
        e1?.desc == e2?.desc &&
        listEquality.equals(e1?.respusta, e2?.respusta) &&
        listEquality.equals(e1?.test, e2?.test) &&
        e1?.notasProfesional == e2?.notasProfesional &&
        e1?.invalidado == e2?.invalidado &&
        e1?.fechaInvalidacion == e2?.fechaInvalidacion &&
        e1?.puntajeTotal == e2?.puntajeTotal &&
        listEquality.equals(e1?.alertasEspeciales, e2?.alertasEspeciales);
  }

  @override
  int hash(RespuestasRecord? e) => const ListEquality().hash([
        e?.userRespuesta,
        e?.fecha,
        e?.numeroPregunta,
        e?.titlo,
        e?.desc,
        e?.respusta,
        e?.test,
        e?.notasProfesional,
        e?.invalidado,
        e?.fechaInvalidacion,
        e?.puntajeTotal,
        e?.alertasEspeciales,
      ]);

  @override
  bool isValidKey(Object? o) => o is RespuestasRecord;
}

// Helper para actualizar notas del profesional
Future<void> updateNotasProfesional(DocumentReference ref, String notas) =>
    ref.update({'notasProfesional': notas});

// Helper para invalidar tamizaje
Future<void> invalidarTamizaje(DocumentReference ref) => ref.update({
      'invalidado': true,
      'fechaInvalidacion': DateTime.now(),
    });
