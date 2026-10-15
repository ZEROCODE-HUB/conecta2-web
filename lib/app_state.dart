import 'package:flutter/material.dart';
import 'flutter_flow/request_manager.dart';
import '/backend/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _RespuestaEnc = prefs
              .getStringList('ff_RespuestaEnc')
              ?.map((x) {
                try {
                  return RespuestaTestStruct.fromSerializableMap(jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _RespuestaEnc;
    });
    _safeInit(() {
      _RespuestaTam = prefs
              .getStringList('ff_RespuestaTam')
              ?.map((x) {
                try {
                  return RespustaTamizajeStruct.fromSerializableMap(
                      jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _RespuestaTam;
    });
    _safeInit(() {
      _encuesta = prefs.getString('ff_encuesta') ?? _encuesta;
    });
    _safeInit(() {
      _showEncuesta = prefs.getBool('ff_showEncuesta') ?? _showEncuesta;
    });
    _safeInit(() {
      _createEncuesta = prefs.getBool('ff_createEncuesta') ?? _createEncuesta;
    });
    _safeInit(() {
      _isShowFullList = prefs.getBool('ff_isShowFullList') ?? _isShowFullList;
    });
    _safeInit(() {
      _EmailAdmin = prefs.getString('ff_EmailAdmin') ?? _EmailAdmin;
    });
    // La contraseña ya no se guarda en el dispositivo (2026-10-15). Se
    // borra la que hubiera quedado de versiones anteriores.
    _safeInit(() {
      prefs.remove('ff_PasswordAdmin');
    });
    _safeInit(() {
      _dateEmocion = prefs.containsKey('ff_dateEmocion')
          ? DateTime.fromMillisecondsSinceEpoch(prefs.getInt('ff_dateEmocion')!)
          : _dateEmocion;
    });
    _safeInit(() {
      _emocionDay = prefs.getInt('ff_emocionDay') ?? _emocionDay;
    });
    _safeInit(() {
      _CalenderEmotion = prefs
              .getStringList('ff_CalenderEmotion')
              ?.map((x) {
                try {
                  return CalenderEmocionesStruct.fromSerializableMap(
                      jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _CalenderEmotion;
    });
    _safeInit(() {
      _EncuestaRespuesta = prefs
              .getStringList('ff_EncuestaRespuesta')
              ?.map((x) {
                try {
                  return RespuestaEncuestaStruct.fromSerializableMap(
                      jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _EncuestaRespuesta;
    });
    _safeInit(() {
      _isCacheOverride =
          prefs.getBool('ff_isCacheOverride') ?? _isCacheOverride;
    });
    _safeInit(() {
      _updateText = prefs.getString('ff_updateText') ?? _updateText;
    });
    _safeInit(() {
      _select = prefs
              .getStringList('ff_select')
              ?.map((x) {
                try {
                  return SelectStruct.fromSerializableMap(jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _select;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  List<RespuestaTestStruct> _RespuestaEnc = [
    RespuestaTestStruct.fromSerializableMap(jsonDecode(
        '{\"Pregunta\":\"Hello World\",\"Tipo\":\"Hello World\",\"NPregunta\":\"0\",\"Respuesta\":\"Hello World\",\"user_ref\":\"/users/example\",\"TrueAndFalse\":\"0\",\"RespuestaSelection\":\"[\\\"Hello World\\\"]\",\"Select\":\"[\\\"0\\\"]\",\"Select2\":\"Hello World\"}'))
  ];
  List<RespuestaTestStruct> get RespuestaEnc => _RespuestaEnc;
  set RespuestaEnc(List<RespuestaTestStruct> value) {
    _RespuestaEnc = value;
    prefs.setStringList(
        'ff_RespuestaEnc', value.map((x) => x.serialize()).toList());
  }

  void addToRespuestaEnc(RespuestaTestStruct value) {
    RespuestaEnc.add(value);
    prefs.setStringList(
        'ff_RespuestaEnc', _RespuestaEnc.map((x) => x.serialize()).toList());
  }

  void removeFromRespuestaEnc(RespuestaTestStruct value) {
    RespuestaEnc.remove(value);
    prefs.setStringList(
        'ff_RespuestaEnc', _RespuestaEnc.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromRespuestaEnc(int index) {
    RespuestaEnc.removeAt(index);
    prefs.setStringList(
        'ff_RespuestaEnc', _RespuestaEnc.map((x) => x.serialize()).toList());
  }

  void updateRespuestaEncAtIndex(
    int index,
    RespuestaTestStruct Function(RespuestaTestStruct) updateFn,
  ) {
    RespuestaEnc[index] = updateFn(_RespuestaEnc[index]);
    prefs.setStringList(
        'ff_RespuestaEnc', _RespuestaEnc.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInRespuestaEnc(int index, RespuestaTestStruct value) {
    RespuestaEnc.insert(index, value);
    prefs.setStringList(
        'ff_RespuestaEnc', _RespuestaEnc.map((x) => x.serialize()).toList());
  }

  List<RespustaTamizajeStruct> _RespuestaTam = [];
  List<RespustaTamizajeStruct> get RespuestaTam => _RespuestaTam;
  set RespuestaTam(List<RespustaTamizajeStruct> value) {
    _RespuestaTam = value;
    prefs.setStringList(
        'ff_RespuestaTam', value.map((x) => x.serialize()).toList());
  }

  void addToRespuestaTam(RespustaTamizajeStruct value) {
    RespuestaTam.add(value);
    prefs.setStringList(
        'ff_RespuestaTam', _RespuestaTam.map((x) => x.serialize()).toList());
  }

  void removeFromRespuestaTam(RespustaTamizajeStruct value) {
    RespuestaTam.remove(value);
    prefs.setStringList(
        'ff_RespuestaTam', _RespuestaTam.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromRespuestaTam(int index) {
    RespuestaTam.removeAt(index);
    prefs.setStringList(
        'ff_RespuestaTam', _RespuestaTam.map((x) => x.serialize()).toList());
  }

  void updateRespuestaTamAtIndex(
    int index,
    RespustaTamizajeStruct Function(RespustaTamizajeStruct) updateFn,
  ) {
    RespuestaTam[index] = updateFn(_RespuestaTam[index]);
    prefs.setStringList(
        'ff_RespuestaTam', _RespuestaTam.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInRespuestaTam(int index, RespustaTamizajeStruct value) {
    RespuestaTam.insert(index, value);
    prefs.setStringList(
        'ff_RespuestaTam', _RespuestaTam.map((x) => x.serialize()).toList());
  }

  bool _isOptionsExpanded = false;
  bool get isOptionsExpanded => _isOptionsExpanded;
  set isOptionsExpanded(bool value) {
    _isOptionsExpanded = value;
  }

  String _encuesta = '';
  String get encuesta => _encuesta;
  set encuesta(String value) {
    _encuesta = value;
    prefs.setString('ff_encuesta', value);
  }

  String _selectUser = '';
  String get selectUser => _selectUser;
  set selectUser(String value) {
    _selectUser = value;
  }

  bool _showEncuesta = false;
  bool get showEncuesta => _showEncuesta;
  set showEncuesta(bool value) {
    _showEncuesta = value;
    prefs.setBool('ff_showEncuesta', value);
  }

  String _description = '';
  String get description => _description;
  set description(String value) {
    _description = value;
  }

  int _emocion = 0;
  int get emocion => _emocion;
  set emocion(int value) {
    _emocion = value;
  }

  bool _createEncuesta = false;
  bool get createEncuesta => _createEncuesta;
  set createEncuesta(bool value) {
    _createEncuesta = value;
    prefs.setBool('ff_createEncuesta', value);
  }

  bool _isShowFullList = true;
  bool get isShowFullList => _isShowFullList;
  set isShowFullList(bool value) {
    _isShowFullList = value;
    prefs.setBool('ff_isShowFullList', value);
  }

  String _EmailAdmin = '';
  String get EmailAdmin => _EmailAdmin;
  set EmailAdmin(String value) {
    _EmailAdmin = value;
    prefs.setString('ff_EmailAdmin', value);
  }

  String _PasswordAdmin = '';
  String get PasswordAdmin => _PasswordAdmin;
  // Solo en memoria: nunca se escribe en SharedPreferences.
  set PasswordAdmin(String value) {
    _PasswordAdmin = value;
  }

  DateTime? _dateEmocion = DateTime.fromMillisecondsSinceEpoch(1719194940000);
  DateTime? get dateEmocion => _dateEmocion;
  set dateEmocion(DateTime? value) {
    _dateEmocion = value;
    value != null
        ? prefs.setInt('ff_dateEmocion', value.millisecondsSinceEpoch)
        : prefs.remove('ff_dateEmocion');
  }

  int _emocionDay = 0;
  int get emocionDay => _emocionDay;
  set emocionDay(int value) {
    _emocionDay = value;
    prefs.setInt('ff_emocionDay', value);
  }

  List<CalenderEmocionesStruct> _CalenderEmotion = [];
  List<CalenderEmocionesStruct> get CalenderEmotion => _CalenderEmotion;
  set CalenderEmotion(List<CalenderEmocionesStruct> value) {
    _CalenderEmotion = value;
    prefs.setStringList(
        'ff_CalenderEmotion', value.map((x) => x.serialize()).toList());
  }

  void addToCalenderEmotion(CalenderEmocionesStruct value) {
    CalenderEmotion.add(value);
    prefs.setStringList('ff_CalenderEmotion',
        _CalenderEmotion.map((x) => x.serialize()).toList());
  }

  void removeFromCalenderEmotion(CalenderEmocionesStruct value) {
    CalenderEmotion.remove(value);
    prefs.setStringList('ff_CalenderEmotion',
        _CalenderEmotion.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromCalenderEmotion(int index) {
    CalenderEmotion.removeAt(index);
    prefs.setStringList('ff_CalenderEmotion',
        _CalenderEmotion.map((x) => x.serialize()).toList());
  }

  void updateCalenderEmotionAtIndex(
    int index,
    CalenderEmocionesStruct Function(CalenderEmocionesStruct) updateFn,
  ) {
    CalenderEmotion[index] = updateFn(_CalenderEmotion[index]);
    prefs.setStringList('ff_CalenderEmotion',
        _CalenderEmotion.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInCalenderEmotion(
      int index, CalenderEmocionesStruct value) {
    CalenderEmotion.insert(index, value);
    prefs.setStringList('ff_CalenderEmotion',
        _CalenderEmotion.map((x) => x.serialize()).toList());
  }

  List<RespuestaEncuestaStruct> _EncuestaRespuesta = [];
  List<RespuestaEncuestaStruct> get EncuestaRespuesta => _EncuestaRespuesta;
  set EncuestaRespuesta(List<RespuestaEncuestaStruct> value) {
    _EncuestaRespuesta = value;
    prefs.setStringList(
        'ff_EncuestaRespuesta', value.map((x) => x.serialize()).toList());
  }

  void addToEncuestaRespuesta(RespuestaEncuestaStruct value) {
    EncuestaRespuesta.add(value);
    prefs.setStringList('ff_EncuestaRespuesta',
        _EncuestaRespuesta.map((x) => x.serialize()).toList());
  }

  void removeFromEncuestaRespuesta(RespuestaEncuestaStruct value) {
    EncuestaRespuesta.remove(value);
    prefs.setStringList('ff_EncuestaRespuesta',
        _EncuestaRespuesta.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromEncuestaRespuesta(int index) {
    EncuestaRespuesta.removeAt(index);
    prefs.setStringList('ff_EncuestaRespuesta',
        _EncuestaRespuesta.map((x) => x.serialize()).toList());
  }

  void updateEncuestaRespuestaAtIndex(
    int index,
    RespuestaEncuestaStruct Function(RespuestaEncuestaStruct) updateFn,
  ) {
    EncuestaRespuesta[index] = updateFn(_EncuestaRespuesta[index]);
    prefs.setStringList('ff_EncuestaRespuesta',
        _EncuestaRespuesta.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInEncuestaRespuesta(
      int index, RespuestaEncuestaStruct value) {
    EncuestaRespuesta.insert(index, value);
    prefs.setStringList('ff_EncuestaRespuesta',
        _EncuestaRespuesta.map((x) => x.serialize()).toList());
  }

  bool _isCacheOverride = true;
  bool get isCacheOverride => _isCacheOverride;
  set isCacheOverride(bool value) {
    _isCacheOverride = value;
    prefs.setBool('ff_isCacheOverride', value);
  }

  DateTime? _lastCacheTime = DateTime.fromMillisecondsSinceEpoch(1720508040000);
  DateTime? get lastCacheTime => _lastCacheTime;
  set lastCacheTime(DateTime? value) {
    _lastCacheTime = value;
  }

  String _updateText = '';
  String get updateText => _updateText;
  set updateText(String value) {
    _updateText = value;
    prefs.setString('ff_updateText', value);
  }

  List<SelectStruct> _select = [];
  List<SelectStruct> get select => _select;
  set select(List<SelectStruct> value) {
    _select = value;
    prefs.setStringList('ff_select', value.map((x) => x.serialize()).toList());
  }

  void addToSelect(SelectStruct value) {
    select.add(value);
    prefs.setStringList(
        'ff_select', _select.map((x) => x.serialize()).toList());
  }

  void removeFromSelect(SelectStruct value) {
    select.remove(value);
    prefs.setStringList(
        'ff_select', _select.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromSelect(int index) {
    select.removeAt(index);
    prefs.setStringList(
        'ff_select', _select.map((x) => x.serialize()).toList());
  }

  void updateSelectAtIndex(
    int index,
    SelectStruct Function(SelectStruct) updateFn,
  ) {
    select[index] = updateFn(_select[index]);
    prefs.setStringList(
        'ff_select', _select.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInSelect(int index, SelectStruct value) {
    select.insert(index, value);
    prefs.setStringList(
        'ff_select', _select.map((x) => x.serialize()).toList());
  }

  String _HTML = '';
  String get HTML => _HTML;
  set HTML(String value) {
    _HTML = value;
  }

  RegistroUsuarioTempStruct _detalleUsuarioTemp = RegistroUsuarioTempStruct();
  RegistroUsuarioTempStruct get detalleUsuarioTemp => _detalleUsuarioTemp;
  set detalleUsuarioTemp(RegistroUsuarioTempStruct value) {
    _detalleUsuarioTemp = value;
  }

  void updateDetalleUsuarioTempStruct(
      Function(RegistroUsuarioTempStruct) updateFn) {
    updateFn(_detalleUsuarioTemp);
  }

  List<AlertaStruct> _listaAlertas = [
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Tabaco\",\"nivel\":\"Bajo\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Tabaco\",\"nivel\":\"Moderado\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Tabaco\",\"nivel\":\"Alto\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Bebidas alcohólicas\",\"nivel\":\"Bajo\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Bebidas alcohólicas\",\"nivel\":\"Moderado\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Bebidas alcohólicas\",\"nivel\":\"Alto\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Cannabis\",\"nivel\":\"Bajo\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Cannabis\",\"nivel\":\"Moderado\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Cannabis\",\"nivel\":\"Alto\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Anfetaminas\",\"nivel\":\"Bajo\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Anfetaminas\",\"nivel\":\"Moderado\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Anfetaminas\",\"nivel\":\"Alto\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Inhalantes\",\"nivel\":\"Bajo\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Inhalantes\",\"nivel\":\"Moderado\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Hello World\",\"nivel\":\"Hello World\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Inhalantes\",\"nivel\":\"Alto\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Tranquilizantes\",\"nivel\":\"Bajo\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Tranquilizantes\",\"nivel\":\"Moderado\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Tranquilizantes\",\"nivel\":\"Alto\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Alucinógenos\",\"nivel\":\"Bajo\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Alucinógenos\",\"nivel\":\"Moderado\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Alucinógenos\",\"nivel\":\"Alto\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Opiáceos\",\"nivel\":\"Bajo\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Opiáceos\",\"nivel\":\"Moderado\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Opiáceos\",\"nivel\":\"Alto\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Cocaina\",\"nivel\":\"Bajo\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Cocaina\",\"nivel\":\"Moderado\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Cocaina\",\"nivel\":\"Alto\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Otros\",\"nivel\":\"Bajo\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Otros\",\"nivel\":\"Moderado\"}')),
    AlertaStruct.fromSerializableMap(jsonDecode(
        '{\"min\":\"0\",\"max\":\"0\",\"sustancia\":\"Otros\",\"nivel\":\"Alto\"}'))
  ];
  List<AlertaStruct> get listaAlertas => _listaAlertas;
  set listaAlertas(List<AlertaStruct> value) {
    _listaAlertas = value;
  }

  void addToListaAlertas(AlertaStruct value) {
    listaAlertas.add(value);
  }

  void removeFromListaAlertas(AlertaStruct value) {
    listaAlertas.remove(value);
  }

  void removeAtIndexFromListaAlertas(int index) {
    listaAlertas.removeAt(index);
  }

  void updateListaAlertasAtIndex(
    int index,
    AlertaStruct Function(AlertaStruct) updateFn,
  ) {
    listaAlertas[index] = updateFn(_listaAlertas[index]);
  }

  void insertAtIndexInListaAlertas(int index, AlertaStruct value) {
    listaAlertas.insert(index, value);
  }

  List<AlertaStruct> _listaAlertasEnvio = [];
  List<AlertaStruct> get listaAlertasEnvio => _listaAlertasEnvio;
  set listaAlertasEnvio(List<AlertaStruct> value) {
    _listaAlertasEnvio = value;
  }

  void addToListaAlertasEnvio(AlertaStruct value) {
    listaAlertasEnvio.add(value);
  }

  void removeFromListaAlertasEnvio(AlertaStruct value) {
    listaAlertasEnvio.remove(value);
  }

  void removeAtIndexFromListaAlertasEnvio(int index) {
    listaAlertasEnvio.removeAt(index);
  }

  void updateListaAlertasEnvioAtIndex(
    int index,
    AlertaStruct Function(AlertaStruct) updateFn,
  ) {
    listaAlertasEnvio[index] = updateFn(_listaAlertasEnvio[index]);
  }

  void insertAtIndexInListaAlertasEnvio(int index, AlertaStruct value) {
    listaAlertasEnvio.insert(index, value);
  }

  List<String> _TamizajeSustanciaPermitidas = [];
  List<String> get TamizajeSustanciaPermitidas => _TamizajeSustanciaPermitidas;
  set TamizajeSustanciaPermitidas(List<String> value) {
    _TamizajeSustanciaPermitidas = value;
  }

  void addToTamizajeSustanciaPermitidas(String value) {
    TamizajeSustanciaPermitidas.add(value);
  }

  void removeFromTamizajeSustanciaPermitidas(String value) {
    TamizajeSustanciaPermitidas.remove(value);
  }

  void removeAtIndexFromTamizajeSustanciaPermitidas(int index) {
    TamizajeSustanciaPermitidas.removeAt(index);
  }

  void updateTamizajeSustanciaPermitidasAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    TamizajeSustanciaPermitidas[index] =
        updateFn(_TamizajeSustanciaPermitidas[index]);
  }

  void insertAtIndexInTamizajeSustanciaPermitidas(int index, String value) {
    TamizajeSustanciaPermitidas.insert(index, value);
  }

  final _queryManager = StreamRequestManager<EncuestasRecord>();
  Stream<EncuestasRecord> query({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Stream<EncuestasRecord> Function() requestFn,
  }) =>
      _queryManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearQueryCache() => _queryManager.clear();
  void clearQueryCacheKey(String? uniqueKey) =>
      _queryManager.clearRequest(uniqueKey);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}