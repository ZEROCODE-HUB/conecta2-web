import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "rol" field.
  String? _rol;
  String get rol => _rol ?? '';
  bool hasRol() => _rol != null;

  // "Acudiente" field.
  AcudienteStruct? _acudiente;
  AcudienteStruct get acudiente => _acudiente ?? AcudienteStruct();
  bool hasAcudiente() => _acudiente != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "Profesionales" field.
  ProfesionalesStruct? _profesionales;
  ProfesionalesStruct get profesionales =>
      _profesionales ?? ProfesionalesStruct();
  bool hasProfesionales() => _profesionales != null;

  // "Lastconnectedday" field.
  DateTime? _lastconnectedday;
  DateTime? get lastconnectedday => _lastconnectedday;
  bool hasLastconnectedday() => _lastconnectedday != null;

  // "status" field.
  int? _status;
  int get status => _status ?? 0;
  bool hasStatus() => _status != null;

  // "identidad" field.
  String? _identidad;
  String get identidad => _identidad ?? '';
  bool hasIdentidad() => _identidad != null;

  // "page" field.
  int? _page;
  int get page => _page ?? 0;
  bool hasPage() => _page != null;

  // "fecha_nacimiento" field.
  DateTime? _fechaNacimiento;
  DateTime? get fechaNacimiento => _fechaNacimiento;
  bool hasFechaNacimiento() => _fechaNacimiento != null;

  // "genero" field.
  String? _genero;
  String get genero => _genero ?? '';
  bool hasGenero() => _genero != null;

  // "municipio" field.
  String? _municipio;
  String get municipio => _municipio ?? '';
  bool hasMunicipio() => _municipio != null;

  // "barrio" field.
  String? _barrio;
  String get barrio => _barrio ?? '';
  bool hasBarrio() => _barrio != null;

  // "edad" field.
  String? _edad;
  String get edad => _edad ?? '';
  bool hasEdad() => _edad != null;

  // "colegio" field.
  String? _colegio;
  String get colegio => _colegio ?? '';
  bool hasColegio() => _colegio != null;

  // "eps" field.
  String? _eps;
  String get eps => _eps ?? '';
  bool hasEps() => _eps != null;

  // "grado" field.
  String? _grado;
  String get grado => _grado ?? '';
  bool hasGrado() => _grado != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _rol = snapshotData['rol'] as String?;
    _acudiente = snapshotData['Acudiente'] is AcudienteStruct
        ? snapshotData['Acudiente']
        : AcudienteStruct.maybeFromMap(snapshotData['Acudiente']);
    _address = snapshotData['address'] as String?;
    _profesionales = snapshotData['Profesionales'] is ProfesionalesStruct
        ? snapshotData['Profesionales']
        : ProfesionalesStruct.maybeFromMap(snapshotData['Profesionales']);
    _lastconnectedday = snapshotData['Lastconnectedday'] as DateTime?;
    _status = castToType<int>(snapshotData['status']);
    _identidad = snapshotData['identidad'] as String?;
    _page = castToType<int>(snapshotData['page']);
    _fechaNacimiento = snapshotData['fecha_nacimiento'] as DateTime?;
    _genero = snapshotData['genero'] as String?;
    _edad = snapshotData['edad'] as String?;
    _municipio = snapshotData['municipio'] as String?;
    _barrio = snapshotData['barrio'] as String?;
    _colegio = snapshotData['colegio'] as String?;
    _eps = snapshotData['eps'] as String?;
    _grado = snapshotData['grado'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? rol,
  AcudienteStruct? acudiente,
  String? address,
  ProfesionalesStruct? profesionales,
  DateTime? lastconnectedday,
  int? status,
  String? identidad,
  int? page,
  DateTime? fechaNacimiento,
  String? genero,
  String? edad,
  String? municipio,
  String? barrio,
  String? colegio,
  String? eps,
  String? grado,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'rol': rol,
      'Acudiente': AcudienteStruct().toMap(),
      'address': address,
      'Profesionales': ProfesionalesStruct().toMap(),
      'Lastconnectedday': lastconnectedday,
      'status': status,
      'identidad': identidad,
      'page': page,
      'fecha_nacimiento': fechaNacimiento,
      'genero': genero,
      'edad': edad,
      'municipio': municipio,
      'barrio': barrio,
      'colegio': colegio,
      'eps': eps,
      'grado': grado,
    }.withoutNulls,
  );

  // Handle nested data for "Acudiente" field.
  addAcudienteStructData(firestoreData, acudiente, 'Acudiente');

  // Handle nested data for "Profesionales" field.
  addProfesionalesStructData(firestoreData, profesionales, 'Profesionales');

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.rol == e2?.rol &&
        e1?.acudiente == e2?.acudiente &&
        e1?.address == e2?.address &&
        e1?.profesionales == e2?.profesionales &&
        e1?.lastconnectedday == e2?.lastconnectedday &&
        e1?.status == e2?.status &&
        e1?.identidad == e2?.identidad &&
        e1?.page == e2?.page &&
        e1?.fechaNacimiento == e2?.fechaNacimiento &&
        e1?.genero == e2?.genero &&
        e1?.edad == e2?.edad &&
        e1?.municipio == e2?.municipio &&
        e1?.barrio == e2?.barrio &&
        e1?.colegio == e2?.colegio &&
        e1?.eps == e2?.eps &&
        e1?.grado == e2?.grado;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.rol,
        e?.acudiente,
        e?.address,
        e?.profesionales,
        e?.lastconnectedday,
        e?.status,
        e?.identidad,
        e?.page,
        e?.fechaNacimiento,
        e?.genero,
        e?.edad,
        e?.municipio,
        e?.barrio,
        e?.colegio,
        e?.eps,
        e?.grado
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
