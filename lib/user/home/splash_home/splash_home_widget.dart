import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import '/user/registration/sesion_app.dart';
import 'splash_home_model.dart';
export 'splash_home_model.dart';

class SplashHomeWidget extends StatefulWidget {
  const SplashHomeWidget({super.key});

  static String routeName = 'SplashHome';
  static String routePath = '/splashHome';

  @override
  State<SplashHomeWidget> createState() => _SplashHomeWidgetState();
}

class _SplashHomeWidgetState extends State<SplashHomeWidget> {
  late SplashHomeModel _model;
  StreamSubscription? _authSub;
  Timer? _timeoutTimer;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SplashHomeModel());
    _startAuthListener();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  /// Mensaje de error visible bajo el logo; null mientras carga.
  String? _error;

  /// Si el error permite reintentar (red/lectura) o solo cerrar sesión.
  bool _puedeReintentar = true;

  /// Evita navegar dos veces si Firebase emite el mismo usuario de nuevo.
  bool _redirigido = false;

  Future<void> _signOutAndRedirect() async {
    _timeoutTimer?.cancel();
    _authSub?.cancel();
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    limpiarSesionApp();
    if (mounted) {
      context.goNamed(SplashWidget.routeName);
    }
  }

  void _mostrarError(String mensaje, {bool puedeReintentar = true}) {
    _timeoutTimer?.cancel();
    if (!mounted || _redirigido) return;
    safeSetState(() {
      _error = mensaje;
      _puedeReintentar = puedeReintentar;
    });
  }

  /// Espera la sesión de Firebase y carga el perfil (`users/{uid}`).
  /// Solo cierra sesión si el perfil no existe; ante errores de red o una
  /// carga lenta muestra "Reintentar" en vez de expulsar al usuario.
  void _startAuthListener() {
    _authSub?.cancel();
    _timeoutTimer?.cancel();
    if (_error != null) safeSetState(() => _error = null);

    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      _mostrarError(
          'No pudimos cargar tu perfil. Revisa tu conexión e inténtalo de nuevo.');
    });

    _authSub = FirebaseAuth.instance.authStateChanges().listen(
      (user) {
        if (user == null) {
          // Sin sesión: al splash/login.
          _timeoutTimer?.cancel();
          _authSub?.cancel();
          if (mounted && !_redirigido) {
            _redirigido = true;
            context.goNamed(SplashWidget.routeName);
          }
          return;
        }
        _cargarPerfil(user.uid);
      },
      onError: (_) => _mostrarError(
          'No pudimos verificar tu sesión. Revisa tu conexión e inténtalo de nuevo.'),
    );
  }

  Future<void> _cargarPerfil(String uid) async {
    try {
      final snap = await UsersRecord.collection.doc(uid).get();
      if (!mounted || _redirigido) return;
      if (!snap.exists) {
        // Cuenta de acceso sin perfil: no hay a dónde llevarla.
        await _signOutAndRedirect();
        return;
      }
      _timeoutTimer?.cancel();
      _authSub?.cancel();
      _redirectBasedOnRole(UsersRecord.fromSnapshot(snap));
    } catch (_) {
      _mostrarError(
          'No pudimos cargar tu perfil. Revisa tu conexión e inténtalo de nuevo.');
    }
  }

  void _redirectBasedOnRole(UsersRecord userDoc) async {
    if (!mounted || _redirigido) return;
    final rol = userDoc.rol;
    // Roles válidos; con otro rol se ofrece cerrar sesión en vez de saltar
    // en silencio al login con la sesión abierta.
    const rolesConocidos = [
      'Adolescente',
      'Acudiente',
      'Padre',
      'Profesional',
      'Administrador',
    ];
    if (!rolesConocidos.contains(rol)) {
      _mostrarError('Tu cuenta no tiene un rol válido. Contacta al equipo.',
          puedeReintentar: false);
      return;
    }
    _redirigido = true;
    // Solo "Crear usuario" (web, admin/profesional) usa la contraseña
    // guardada; para los demás roles no se conserva en el dispositivo.
    if (rol == 'Adolescente' || rol == 'Acudiente' || rol == 'Padre') {
      FFAppState().PasswordAdmin = '';
    }

    if (rol ==
        valueOrDefault<String>(
          FFAppConstants.adolescente,
          'Adolescente',
        )) {
      context.goNamed(
        HomeWidget.routeName,
        extra: <String, dynamic>{
          '__transition_info__': TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
            duration: Duration(milliseconds: 0),
          ),
        },
      );
    } else if (rol ==
            valueOrDefault<String>(
              FFAppConstants.acudiente,
              'Acudiente',
            ) ||
        rol == 'Padre') {
      context.goNamed(
        HomeParentsWidget.routeName,
        extra: <String, dynamic>{
          '__transition_info__': TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
            duration: Duration(milliseconds: 0),
          ),
        },
      );
    } else if ((rol ==
            valueOrDefault<String>(
              FFAppConstants.Profesional,
              'Profesional',
            )) &&
        (MediaQuery.sizeOf(context).width < kBreakpointLarge || !isWeb)) {
      context.goNamed(
        PacientesWidget.routeName,
        extra: <String, dynamic>{
          '__transition_info__': TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
            duration: Duration(milliseconds: 0),
          ),
        },
      );
    } else if ((rol == 'Administrador') ||
        (rol ==
            valueOrDefault<String>(
              FFAppConstants.Profesional,
              'Profesional',
            ))) {
      context.goNamed(
        WebWidget.routeName,
        extra: <String, dynamic>{
          '__transition_info__': TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
            duration: Duration(milliseconds: 0),
          ),
        },
      );
    } else {
      _redirigido = false;
      _mostrarError('Tu cuenta no tiene un rol válido. Contacta al equipo.',
          puedeReintentar: false);
      return;
    }

    await userDoc.reference.update(createUsersRecordData(
      lastconnectedday: getCurrentTimestamp,
    ));
  }

  Widget _buildError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  color: Colors.white,
                  fontSize: 15.0,
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 16.0),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.0,
            runSpacing: 8.0,
            children: [
              if (_puedeReintentar)
                ElevatedButton(
                  onPressed: _startAuthListener,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: FlutterFlowTheme.of(context).primary,
                    elevation: 0,
                  ),
                  child: const Text('Reintentar'),
                ),
              OutlinedButton(
                onPressed: _signOutAndRedirect,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _timeoutTimer?.cancel();
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 100.0,
                height: 57.0,
                decoration: BoxDecoration(),
              ),
              Container(
                decoration: BoxDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/Group_1.png',
                        width: 250.0,
                        height: 89.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    if (_error == null)
                      const SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.5,
                        ),
                      )
                    else
                      _buildError(context),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 24.0),
                child: Container(
                  width: 100.0,
                  height: 57.0,
                  decoration: BoxDecoration(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
