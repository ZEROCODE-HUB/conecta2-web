import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/app_state.dart';
import '/backend/backend.dart';

import '/auth/base_auth_user_provider.dart';

import '/backend/push_notifications/push_notifications_handler.dart'
    show PushNotificationsHandler;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    if (newUser.loggedIn && FFAppState().EmailAdmin.isEmpty) {
      FirebaseAuth.instance.signOut();
      return;
    }
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) =>
          appStateNotifier.loggedIn ? SplashHomeWidget() : SplashWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) =>
              appStateNotifier.loggedIn ? SplashHomeWidget() : SplashWidget(),
        ),
        FFRoute(
          name: RegisterContinueWidget.routeName,
          path: RegisterContinueWidget.routePath,
          builder: (context, params) => RegisterContinueWidget(),
        ),
        FFRoute(
          name: SuccessWidget.routeName,
          path: SuccessWidget.routePath,
          builder: (context, params) => SuccessWidget(),
        ),
        FFRoute(
          name: LoginWidget.routeName,
          path: LoginWidget.routePath,
          builder: (context, params) => LoginWidget(),
        ),
        FFRoute(
          name: ConfirmNumberWidget.routeName,
          path: ConfirmNumberWidget.routePath,
          builder: (context, params) => ConfirmNumberWidget(),
        ),
        FFRoute(
          name: ForgotPWWidget.routeName,
          path: ForgotPWWidget.routePath,
          builder: (context, params) => ForgotPWWidget(),
        ),
        FFRoute(
          name: ResetPWWidget.routeName,
          path: ResetPWWidget.routePath,
          builder: (context, params) => ResetPWWidget(),
        ),
        FFRoute(
          name: HomeWidget.routeName,
          path: HomeWidget.routePath,
          builder: (context, params) => HomeWidget(),
        ),
        FFRoute(
          name: PreviewPostWidget.routeName,
          path: PreviewPostWidget.routePath,
          builder: (context, params) => PreviewPostWidget(),
        ),
        FFRoute(
          name: SuccessPostWidget.routeName,
          path: SuccessPostWidget.routePath,
          builder: (context, params) => SuccessPostWidget(),
        ),
        FFRoute(
          name: BookWidget.routeName,
          path: BookWidget.routePath,
          builder: (context, params) => BookWidget(),
        ),
        FFRoute(
          name: BookSingleWidget.routeName,
          path: BookSingleWidget.routePath,
          asyncParams: {
            'contenido': getDoc(['Contenido'], ContenidoRecord.fromSnapshot),
          },
          builder: (context, params) => BookSingleWidget(
            contenido: params.getParam(
              'contenido',
              ParamType.Document,
            ),
          ),
        ),
        FFRoute(
          name: EncuestasAndTamizajesWidget.routeName,
          path: EncuestasAndTamizajesWidget.routePath,
          builder: (context, params) => EncuestasAndTamizajesWidget(),
        ),
        FFRoute(
          name: ProfileWidget.routeName,
          path: ProfileWidget.routePath,
          builder: (context, params) => ProfileWidget(),
        ),
        FFRoute(
          name: AyudaWidget.routeName,
          path: AyudaWidget.routePath,
          builder: (context, params) => AyudaWidget(),
        ),
        FFRoute(
          name: RecordatoriosWidget.routeName,
          path: RecordatoriosWidget.routePath,
          builder: (context, params) => RecordatoriosWidget(),
        ),
        FFRoute(
          name: PacientesWidget.routeName,
          path: PacientesWidget.routePath,
          builder: (context, params) => PacientesWidget(),
        ),
        FFRoute(
          name: HomeParentsWidget.routeName,
          path: HomeParentsWidget.routePath,
          builder: (context, params) => HomeParentsWidget(),
        ),
        FFRoute(
          name: CalendarWidget.routeName,
          path: CalendarWidget.routePath,
          builder: (context, params) => CalendarWidget(),
        ),
        FFRoute(
          name: CalendarOpenWidget.routeName,
          path: CalendarOpenWidget.routePath,
          asyncParams: {
            'emocion': getDoc(['users', 'emociones_registro'],
                EmocionesRegistroRecord.fromSnapshot),
          },
          builder: (context, params) => CalendarOpenWidget(
            emocion: params.getParam(
              'emocion',
              ParamType.Document,
            ),
            reminders: params.state.extraMap.containsKey('reminders')
                ? params.state.extraMap['reminders'] as List<RemindersRecord>?
                : null,
          ),
        ),
        FFRoute(
          name: EditProfileWidget.routeName,
          path: EditProfileWidget.routePath,
          builder: (context, params) => EditProfileWidget(),
        ),
        FFRoute(
          name: AprendizajeParentsWidget.routeName,
          path: AprendizajeParentsWidget.routePath,
          builder: (context, params) => AprendizajeParentsWidget(),
        ),
        FFRoute(
          name: AprendizajeParentsOpenWidget.routeName,
          path: AprendizajeParentsOpenWidget.routePath,
          builder: (context, params) => AprendizajeParentsOpenWidget(
            contenido: params.getParam(
              'contenido',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['Contenido'],
            ),
          ),
        ),
        FFRoute(
          name: EncuestasParentsWidget.routeName,
          path: EncuestasParentsWidget.routePath,
          builder: (context, params) => EncuestasParentsWidget(),
        ),
        FFRoute(
          name: EncuestasParentsOpenWidget.routeName,
          path: EncuestasParentsOpenWidget.routePath,
          builder: (context, params) => EncuestasParentsOpenWidget(
            encuesta: params.getParam(
              'encuesta',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['Encuestas'],
            ),
            choice: params.getParam(
              'choice',
              ParamType.String,
            ),
            titulo: params.getParam(
              'titulo',
              ParamType.String,
            ),
            desc: params.getParam(
              'desc',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: EditProfileParentsWidget.routeName,
          path: EditProfileParentsWidget.routePath,
          builder: (context, params) => EditProfileParentsWidget(),
        ),
        FFRoute(
          name: PacientesOpenWidget.routeName,
          path: PacientesOpenWidget.routePath,
          builder: (context, params) => PacientesOpenWidget(
            idPacientes: params.getParam(
              'idPacientes',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['users'],
            ),
          ),
        ),
        FFRoute(
          name: RecordatoriosOpenWidget.routeName,
          path: RecordatoriosOpenWidget.routePath,
          builder: (context, params) => RecordatoriosOpenWidget(
            recordatorID: params.getParam(
              'recordatorID',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['Recordator'],
            ),
          ),
        ),
        FFRoute(
          name: RecordatoriosAddWidget.routeName,
          path: RecordatoriosAddWidget.routePath,
          builder: (context, params) => RecordatoriosAddWidget(),
        ),
        FFRoute(
          name: LiteraturaProWidget.routeName,
          path: LiteraturaProWidget.routePath,
          builder: (context, params) => LiteraturaProWidget(),
        ),
        FFRoute(
          name: LiteraturaProOpenWidget.routeName,
          path: LiteraturaProOpenWidget.routePath,
          builder: (context, params) => LiteraturaProOpenWidget(
            contenidoID: params.getParam(
              'contenidoID',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['Contenido'],
            ),
          ),
        ),
        FFRoute(
          name: EncuestasProWidget.routeName,
          path: EncuestasProWidget.routePath,
          builder: (context, params) => EncuestasProWidget(),
        ),
        FFRoute(
          name: EncuestasOpenProWidget.routeName,
          path: EncuestasOpenProWidget.routePath,
          asyncParams: {
            'respuestasEnc': getDoc(
                ['Encuestas', 'Respuestas'], RespuestasRecord.fromSnapshot),
          },
          builder: (context, params) => EncuestasOpenProWidget(
            encuesta: params.getParam(
              'encuesta',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['Encuestas'],
            ),
            choice: params.getParam(
              'choice',
              ParamType.String,
            ),
            respuestasEnc: params.getParam(
              'respuestasEnc',
              ParamType.Document,
            ),
          ),
        ),
        FFRoute(
          name: EditProfileProffWidget.routeName,
          path: EditProfileProffWidget.routePath,
          builder: (context, params) => EditProfileProffWidget(),
        ),
        FFRoute(
          name: WebWidget.routeName,
          path: WebWidget.routePath,
          requireAuth: true,
          builder: (context, params) => WebWidget(),
          routes: [
            FFRoute(
              name: 'WebUsuarios',
              path: 'usuarios',
              requireAuth: true,
              builder: (context, params) =>
                  WebWidget(section: WebSection.usuarios),
            ),
            FFRoute(
              name: 'WebPacientes',
              path: 'pacientes',
              requireAuth: true,
              builder: (context, params) =>
                  WebWidget(section: WebSection.pacientes),
            ),
            FFRoute(
              name: 'WebEncuestas',
              path: 'encuestas',
              requireAuth: true,
              builder: (context, params) =>
                  WebWidget(section: WebSection.encuestas),
            ),
            FFRoute(
              name: 'WebTamizajes',
              path: 'tamizajes',
              requireAuth: true,
              builder: (context, params) =>
                  WebWidget(section: WebSection.tamizajes),
            ),
            FFRoute(
              name: 'WebTamizajesManuales',
              path: 'tamizajes-manuales',
              requireAuth: true,
              builder: (context, params) =>
                  WebWidget(section: WebSection.tamizajesManuales),
            ),
            FFRoute(
              name: 'WebNotificaciones',
              path: 'notificaciones',
              requireAuth: true,
              builder: (context, params) =>
                  WebWidget(section: WebSection.notificaciones),
            ),
            FFRoute(
              name: 'WebContenido',
              path: 'contenido',
              requireAuth: true,
              builder: (context, params) =>
                  WebWidget(section: WebSection.contenido),
            ),
            FFRoute(
              name: 'WebEstadisticas',
              path: 'estadisticas',
              requireAuth: true,
              builder: (context, params) =>
                  WebWidget(section: WebSection.estadisticas),
            ),
            FFRoute(
              name: 'WebMapa',
              path: 'mapa',
              requireAuth: true,
              builder: (context, params) => WebWidget(section: WebSection.mapa),
            ),
            FFRoute(
              name: 'WebExcel',
              path: 'excel',
              requireAuth: true,
              builder: (context, params) =>
                  WebWidget(section: WebSection.excel),
            ),
            FFRoute(
              name: 'WebInstituciones',
              path: 'instituciones',
              requireAuth: true,
              builder: (context, params) =>
                  WebWidget(section: WebSection.instituciones),
            ),
            FFRoute(
              name: 'WebBarrios',
              path: 'barrios',
              requireAuth: true,
              builder: (context, params) =>
                  WebWidget(section: WebSection.barrios),
            ),
            FFRoute(
              name: 'WebRecordatorios',
              path: 'recordatorios',
              requireAuth: true,
              builder: (context, params) =>
                  WebWidget(section: WebSection.recordatorios),
            ),
            FFRoute(
              name: 'WebPerfil',
              path: 'perfil',
              requireAuth: true,
              builder: (context, params) =>
                  WebWidget(section: WebSection.perfil),
            ),
          ],
        ),
        FFRoute(
          name: SplashWidget.routeName,
          path: SplashWidget.routePath,
          builder: (context, params) => SplashWidget(),
        ),
        FFRoute(
          name: SplashHomeWidget.routeName,
          path: SplashHomeWidget.routePath,
          builder: (context, params) => SplashHomeWidget(),
        ),
        FFRoute(
          name: SplashadminWidget.routeName,
          path: SplashadminWidget.routePath,
          builder: (context, params) => SplashadminWidget(),
        ),
        FFRoute(
          name: CalendarioPageWidget.routeName,
          path: CalendarioPageWidget.routePath,
          builder: (context, params) => CalendarioPageWidget(),
        ),
        FFRoute(
          name: EncTamRespuestaWidget.routeName,
          path: EncTamRespuestaWidget.routePath,
          asyncParams: {
            'encuestaRespuesta': getDoc(
                ['Encuestas', 'Respuestas'], RespuestasRecord.fromSnapshot),
          },
          builder: (context, params) => EncTamRespuestaWidget(
            encuestaRespuesta: params.getParam(
              'encuestaRespuesta',
              ParamType.Document,
            ),
            choice: params.getParam(
              'choice',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: RespuestaParentsOpenWidget.routeName,
          path: RespuestaParentsOpenWidget.routePath,
          asyncParams: {
            'encuestaRespuesta': getDoc(
                ['Encuestas', 'Respuestas'], RespuestasRecord.fromSnapshot),
          },
          builder: (context, params) => RespuestaParentsOpenWidget(
            encuestaRespuesta: params.getParam(
              'encuestaRespuesta',
              ParamType.Document,
            ),
            choice: params.getParam(
              'choice',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: EncuestasOpenRespuestaWidget.routeName,
          path: EncuestasOpenRespuestaWidget.routePath,
          asyncParams: {
            'encuestaRespuesta': getDoc(
                ['Encuestas', 'Respuestas'], RespuestasRecord.fromSnapshot),
          },
          builder: (context, params) => EncuestasOpenRespuestaWidget(
            encuestaRespuesta: params.getParam(
              'encuestaRespuesta',
              ParamType.Document,
            ),
            choice: params.getParam(
              'choice',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: PacientRespuestaWidget.routeName,
          path: PacientRespuestaWidget.routePath,
          asyncParams: {
            'encuesta': getDoc(
                ['Encuestas', 'Respuestas'], RespuestasRecord.fromSnapshot),
          },
          builder: (context, params) => PacientRespuestaWidget(
            encuesta: params.getParam(
              'encuesta',
              ParamType.Document,
            ),
            choice: params.getParam(
              'choice',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: EncTamOpenCopyWidget.routeName,
          path: EncTamOpenCopyWidget.routePath,
          asyncParams: {
            'respuestas': getDoc(
                ['Encuestas', 'Respuestas'], RespuestasRecord.fromSnapshot),
          },
          builder: (context, params) => EncTamOpenCopyWidget(
            respuestas: params.getParam(
              'respuestas',
              ParamType.Document,
            ),
            choice: params.getParam(
              'choice',
              ParamType.String,
            ),
            encuesta: params.getParam(
              'encuesta',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['Encuestas'],
            ),
          ),
        ),
        FFRoute(
          name: EncuestasAdolescenteOpenWidget.routeName,
          path: EncuestasAdolescenteOpenWidget.routePath,
          builder: (context, params) => EncuestasAdolescenteOpenWidget(
            encuesta: params.getParam(
              'encuesta',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['Encuestas'],
            ),
            choice: params.getParam(
              'choice',
              ParamType.String,
            ),
            text: params.getParam(
              'text',
              ParamType.String,
            ),
            desc: params.getParam(
              'desc',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: AaaWidget.routeName,
          path: AaaWidget.routePath,
          builder: (context, params) => AaaWidget(),
        ),
        FFRoute(
          name: EstadisticasWidget.routeName,
          path: EstadisticasWidget.routePath,
          builder: (context, params) => EstadisticasWidget(),
        ),
        FFRoute(
          name: RegisterContinue2Widget.routeName,
          path: RegisterContinue2Widget.routePath,
          builder: (context, params) => RegisterContinue2Widget(),
        ),
        FFRoute(
          name: SeleccionarBarrioWidget.routeName,
          path: SeleccionarBarrioWidget.routePath,
          builder: (context, params) => SeleccionarBarrioWidget(),
        ),
        FFRoute(
          name: RegisterContinue3Widget.routeName,
          path: RegisterContinue3Widget.routePath,
          builder: (context, params) => RegisterContinue3Widget(),
        ),
        FFRoute(
          name: EncuestasAdolescenteOpen2Widget.routeName,
          path: EncuestasAdolescenteOpen2Widget.routePath,
          builder: (context, params) => EncuestasAdolescenteOpen2Widget(
            encuesta: params.getParam(
              'encuesta',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['Encuestas'],
            ),
            choice: params.getParam(
              'choice',
              ParamType.String,
            ),
            text: params.getParam(
              'text',
              ParamType.String,
            ),
            desc: params.getParam(
              'desc',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: TamizajesProWidget.routeName,
          path: TamizajesProWidget.routePath,
          builder: (context, params) => TamizajesProWidget(),
        ),
        FFRoute(
          name: WizardTamizajeProWidget.routeName,
          path: WizardTamizajeProWidget.routePath,
          builder: (context, params) => WizardTamizajeProWidget(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<FFRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.loading) {
            return null;
          }

          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return LoginWidget.routePath;
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Container(
                  color: FlutterFlowTheme.of(context).primary,
                  child: Image.asset(
                    'assets/images/Group_1.png',
                    fit: BoxFit.none,
                  ),
                )
              : PushNotificationsHandler(child: page);

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes.map((r) => r.toRoute(appStateNotifier)).toList(),
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(
        hasTransition: true,
        transitionType: PageTransitionType.fade,
        duration: Duration(milliseconds: 0),
      );
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
