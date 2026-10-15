import 'dart:async';

import 'serialization_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


final _handledMessageIds = <String?>{};

class PushNotificationsHandler extends StatefulWidget {
  const PushNotificationsHandler({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  _PushNotificationsHandlerState createState() =>
      _PushNotificationsHandlerState();
}

class _PushNotificationsHandlerState extends State<PushNotificationsHandler> {
  bool _loading = false;

  Future handleOpenedPushNotification() async {
    if (isWeb) {
      return;
    }

    final notification = await FirebaseMessaging.instance.getInitialMessage();
    if (notification != null) {
      await _handlePushNotification(notification);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handlePushNotification);
  }

  Future _handlePushNotification(RemoteMessage message) async {
    if (_handledMessageIds.contains(message.messageId)) {
      return;
    }
    _handledMessageIds.add(message.messageId);

    safeSetState(() => _loading = true);
    try {
      final initialPageName = message.data['initialPageName'] as String;
      final initialParameterData = getInitialParameterData(message.data);
      final parametersBuilder = parametersBuilderMap[initialPageName];
      if (parametersBuilder != null) {
        final parameterData = await parametersBuilder(initialParameterData);
        if (mounted) {
          context.pushNamed(
            initialPageName,
            pathParameters: parameterData.pathParameters,
            extra: parameterData.extra,
          );
        } else {
          appNavigatorKey.currentContext?.pushNamed(
            initialPageName,
            pathParameters: parameterData.pathParameters,
            extra: parameterData.extra,
          );
        }
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      safeSetState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      handleOpenedPushNotification();
    });
  }

  @override
  Widget build(BuildContext context) => _loading
      ? Container(
          color: FlutterFlowTheme.of(context).primary,
          child: Image.asset(
            'assets/images/Group_1.png',
            fit: BoxFit.none,
          ),
        )
      : widget.child;
}

class ParameterData {
  const ParameterData(
      {this.requiredParams = const {}, this.allParams = const {}});
  final Map<String, String?> requiredParams;
  final Map<String, dynamic> allParams;

  Map<String, String> get pathParameters => Map.fromEntries(
        requiredParams.entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
  Map<String, dynamic> get extra => Map.fromEntries(
        allParams.entries.where((e) => e.value != null),
      );

  static Future<ParameterData> Function(Map<String, dynamic>) none() =>
      (data) async => ParameterData();
}

final parametersBuilderMap =
    <String, Future<ParameterData> Function(Map<String, dynamic>)>{
  'registerContinue': ParameterData.none(),
  'success': ParameterData.none(),
  'login': ParameterData.none(),
  'confirmNumber': ParameterData.none(),
  'forgotPW': ParameterData.none(),
  'resetPW': ParameterData.none(),
  'home': ParameterData.none(),
  'previewPost': ParameterData.none(),
  'successPost': ParameterData.none(),
  'book': ParameterData.none(),
  'bookSingle': (data) async => ParameterData(
        allParams: {
          'contenido': await getDocumentParameter<ContenidoRecord>(
              data, 'contenido', ContenidoRecord.fromSnapshot),
        },
      ),
  'EncuestasAndTamizajes': ParameterData.none(),
  'profile': ParameterData.none(),
  'ayuda': ParameterData.none(),
  'Recordatorios': ParameterData.none(),
  'pacientes': ParameterData.none(),
  'homeParents': ParameterData.none(),
  'Calendar': ParameterData.none(),
  'CalendarOpen': (data) async => ParameterData(
        allParams: {
          'emocion': await getDocumentParameter<EmocionesRegistroRecord>(
              data, 'emocion', EmocionesRegistroRecord.fromSnapshot),
        },
      ),
  'EditProfile': ParameterData.none(),
  'AprendizajeParents': ParameterData.none(),
  'AprendizajeParentsOpen': (data) async => ParameterData(
        allParams: {
          'contenido': getParameter<DocumentReference>(data, 'contenido'),
        },
      ),
  'EncuestasParents': ParameterData.none(),
  'EncuestasParentsOpen': (data) async => ParameterData(
        allParams: {
          'encuesta': getParameter<DocumentReference>(data, 'encuesta'),
          'choice': getParameter<String>(data, 'choice'),
          'titulo': getParameter<String>(data, 'titulo'),
          'desc': getParameter<String>(data, 'desc'),
        },
      ),
  'EditProfileParents': ParameterData.none(),
  'pacientesOpen': (data) async => ParameterData(
        allParams: {
          'idPacientes': getParameter<DocumentReference>(data, 'idPacientes'),
        },
      ),
  'RecordatoriosOpen': (data) async => ParameterData(
        allParams: {
          'recordatorID': getParameter<DocumentReference>(data, 'recordatorID'),
        },
      ),
  'RecordatoriosAdd': ParameterData.none(),
  'LiteraturaPro': ParameterData.none(),
  'LiteraturaProOpen': (data) async => ParameterData(
        allParams: {
          'contenidoID': getParameter<DocumentReference>(data, 'contenidoID'),
        },
      ),
  'EncuestasPro': ParameterData.none(),
  'EncuestasOpenPro': (data) async => ParameterData(
        allParams: {
          'encuesta': getParameter<DocumentReference>(data, 'encuesta'),
          'choice': getParameter<String>(data, 'choice'),
          'respuestasEnc': await getDocumentParameter<RespuestasRecord>(
              data, 'respuestasEnc', RespuestasRecord.fromSnapshot),
        },
      ),
  'EditProfileProff': ParameterData.none(),
  'Web': ParameterData.none(),
  'Splash': ParameterData.none(),
  'SplashHome': ParameterData.none(),
  'Splashadmin': ParameterData.none(),
  'CalendarioPage': ParameterData.none(),
  'EncTamRespuesta': (data) async => ParameterData(
        allParams: {
          'encuestaRespuesta': await getDocumentParameter<RespuestasRecord>(
              data, 'encuestaRespuesta', RespuestasRecord.fromSnapshot),
          'choice': getParameter<String>(data, 'choice'),
        },
      ),
  'RespuestaParentsOpen': (data) async => ParameterData(
        allParams: {
          'encuestaRespuesta': await getDocumentParameter<RespuestasRecord>(
              data, 'encuestaRespuesta', RespuestasRecord.fromSnapshot),
          'choice': getParameter<String>(data, 'choice'),
        },
      ),
  'EncuestasOpenRespuesta': (data) async => ParameterData(
        allParams: {
          'encuestaRespuesta': await getDocumentParameter<RespuestasRecord>(
              data, 'encuestaRespuesta', RespuestasRecord.fromSnapshot),
          'choice': getParameter<String>(data, 'choice'),
        },
      ),
  'pacientRespuesta': (data) async => ParameterData(
        allParams: {
          'encuesta': await getDocumentParameter<RespuestasRecord>(
              data, 'encuesta', RespuestasRecord.fromSnapshot),
          'choice': getParameter<String>(data, 'choice'),
        },
      ),
  'EncTamOpenCopy': (data) async => ParameterData(
        allParams: {
          'respuestas': await getDocumentParameter<RespuestasRecord>(
              data, 'respuestas', RespuestasRecord.fromSnapshot),
          'choice': getParameter<String>(data, 'choice'),
          'encuesta': getParameter<DocumentReference>(data, 'encuesta'),
        },
      ),
  'EncuestasAdolescenteOpen': (data) async => ParameterData(
        allParams: {
          'encuesta': getParameter<DocumentReference>(data, 'encuesta'),
          'choice': getParameter<String>(data, 'choice'),
          'text': getParameter<String>(data, 'text'),
          'desc': getParameter<String>(data, 'desc'),
        },
      ),
  'Estadisticas': ParameterData.none(),
  'registerContinue2': ParameterData.none(),
  'SeleccionarBarrio': ParameterData.none(),
  'registerContinue3': ParameterData.none(),
  'EncuestasAdolescenteOpen2': (data) async => ParameterData(
        allParams: {
          'encuesta': getParameter<DocumentReference>(data, 'encuesta'),
          'choice': getParameter<String>(data, 'choice'),
          'text': getParameter<String>(data, 'text'),
          'desc': getParameter<String>(data, 'desc'),
        },
      ),
};

Map<String, dynamic> getInitialParameterData(Map<String, dynamic> data) {
  try {
    final parameterDataStr = data['parameterData'];
    if (parameterDataStr == null ||
        parameterDataStr is! String ||
        parameterDataStr.isEmpty) {
      return {};
    }
    return jsonDecode(parameterDataStr) as Map<String, dynamic>;
  } catch (e) {
    print('Error parsing parameter data: $e');
    return {};
  }
}
