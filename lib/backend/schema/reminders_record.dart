import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RemindersRecord extends FirestoreRecord {
  RemindersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user" field.
  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  // "due_date" field.
  DateTime? _dueDate;
  DateTime? get dueDate => _dueDate;
  bool hasDueDate() => _dueDate != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  bool hasContent() => _content != null;

  // "notified" field.
  bool? _notified;
  bool get notified => _notified ?? false;
  bool hasNotified() => _notified != null;

  // "creado_por" field: profesional que programó el seguimiento.
  DocumentReference? _creadoPor;
  DocumentReference? get creadoPor => _creadoPor;
  bool hasCreadoPor() => _creadoPor != null;

  // "notas_internas" field: solo para el profesional (no va en el push).
  String? _notasInternas;
  String get notasInternas => _notasInternas ?? '';
  bool hasNotasInternas() => _notasInternas != null;

  // "encuesta" field: tamizaje del que surge el seguimiento.
  DocumentReference? _encuesta;
  DocumentReference? get encuesta => _encuesta;
  bool hasEncuesta() => _encuesta != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _user = snapshotData['user'] as DocumentReference?;
    _dueDate = snapshotData['due_date'] as DateTime?;
    _title = snapshotData['title'] as String?;
    _content = snapshotData['content'] as String?;
    _notified = snapshotData['notified'] as bool?;
    _creadoPor = snapshotData['creado_por'] as DocumentReference?;
    _notasInternas = snapshotData['notas_internas'] as String?;
    _encuesta = snapshotData['encuesta'] as DocumentReference?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('reminders');

  static Stream<RemindersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RemindersRecord.fromSnapshot(s));

  static Future<RemindersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RemindersRecord.fromSnapshot(s));

  static RemindersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RemindersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RemindersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RemindersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RemindersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RemindersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRemindersRecordData({
  DocumentReference? user,
  DateTime? dueDate,
  String? title,
  String? content,
  bool? notified,
  DocumentReference? creadoPor,
  String? notasInternas,
  DocumentReference? encuesta,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user': user,
      'due_date': dueDate,
      'title': title,
      'content': content,
      'notified': notified ?? false,
      'creado_por': creadoPor,
      'notas_internas': notasInternas,
      'encuesta': encuesta,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class RemindersRecordDocumentEquality implements Equality<RemindersRecord> {
  const RemindersRecordDocumentEquality();

  @override
  bool equals(RemindersRecord? e1, RemindersRecord? e2) {
    return e1?.user == e2?.user &&
        e1?.dueDate == e2?.dueDate &&
        e1?.title == e2?.title &&
        e1?.content == e2?.content;
  }

  @override
  int hash(RemindersRecord? e) =>
      const ListEquality().hash([e?.user, e?.dueDate, e?.title, e?.content]);

  @override
  bool isValidKey(Object? o) => o is RemindersRecord;
}
