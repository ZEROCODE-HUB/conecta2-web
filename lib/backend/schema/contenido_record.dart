import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ContenidoRecord extends FirestoreRecord {
  ContenidoRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "titulo" field.
  String? _titulo;
  String get titulo => _titulo ?? '';
  bool hasTitulo() => _titulo != null;

  // "Roles" field.
  List<String>? _roles;
  List<String> get roles => _roles ?? const [];
  bool hasRoles() => _roles != null;

  // "Publicado" field.
  bool? _publicado;
  bool get publicado => _publicado ?? false;
  bool hasPublicado() => _publicado != null;

  // "CreateAt" field.
  DateTime? _createAt;
  DateTime? get createAt => _createAt;
  bool hasCreateAt() => _createAt != null;

  // "userRef" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "ImageProfile" field.
  String? _imageProfile;
  String get imageProfile => _imageProfile ?? '';
  bool hasImageProfile() => _imageProfile != null;

  // "html" field.
  String? _html;
  String get html => _html ?? '';
  bool hasHtml() => _html != null;

  // "ImagePortada" field.
  String? _imagePortada;
  String get imagePortada => _imagePortada ?? '';
  bool hasImagePortada() => _imagePortada != null;

  void _initializeFields() {
    _titulo = snapshotData['titulo'] as String?;
    _roles = getDataList(snapshotData['Roles']);
    _publicado = snapshotData['Publicado'] as bool?;
    _createAt = snapshotData['CreateAt'] as DateTime?;
    _userRef = snapshotData['userRef'] as DocumentReference?;
    _imageProfile = (snapshotData['ImageProfile'] ?? snapshotData['imageProfile']) as String?;
    _html = snapshotData['html'] as String?;
    _imagePortada = (snapshotData['ImagePortada'] ?? snapshotData['imagePortada']) as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Contenido');

  static Stream<ContenidoRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ContenidoRecord.fromSnapshot(s));

  static Future<ContenidoRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ContenidoRecord.fromSnapshot(s));

  static ContenidoRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ContenidoRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ContenidoRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ContenidoRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ContenidoRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ContenidoRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createContenidoRecordData({
  String? titulo,
  bool? publicado,
  DateTime? createAt,
  DocumentReference? userRef,
  String? imageProfile,
  String? html,
  String? imagePortada,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'titulo': titulo,
      'Publicado': publicado,
      'CreateAt': createAt,
      'userRef': userRef,
      'ImageProfile': imageProfile,
      'html': html,
      'ImagePortada': imagePortada,
    }.withoutNulls,
  );

  return firestoreData;
}

class ContenidoRecordDocumentEquality implements Equality<ContenidoRecord> {
  const ContenidoRecordDocumentEquality();

  @override
  bool equals(ContenidoRecord? e1, ContenidoRecord? e2) {
    const listEquality = ListEquality();
    return e1?.titulo == e2?.titulo &&
        listEquality.equals(e1?.roles, e2?.roles) &&
        e1?.publicado == e2?.publicado &&
        e1?.createAt == e2?.createAt &&
        e1?.userRef == e2?.userRef &&
        e1?.imageProfile == e2?.imageProfile &&
        e1?.html == e2?.html &&
        e1?.imagePortada == e2?.imagePortada;
  }

  @override
  int hash(ContenidoRecord? e) => const ListEquality().hash([
        e?.titulo,
        e?.roles,
        e?.publicado,
        e?.createAt,
        e?.userRef,
        e?.imageProfile,
        e?.html,
        e?.imagePortada
      ]);

  @override
  bool isValidKey(Object? o) => o is ContenidoRecord;
}
