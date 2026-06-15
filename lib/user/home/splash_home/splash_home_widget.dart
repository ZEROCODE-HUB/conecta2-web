import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SplashHomeModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (valueOrDefault(currentUserDocument?.rol, '') ==
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
      } else if (valueOrDefault(currentUserDocument?.rol, '') ==
          valueOrDefault<String>(
            FFAppConstants.acudiente,
            'Acudiente',
          )) {
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
      } else if ((valueOrDefault(currentUserDocument?.rol, '') ==
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
      } else if ((valueOrDefault(currentUserDocument?.rol, '') ==
              'Administrador') ||
          (valueOrDefault(currentUserDocument?.rol, '') ==
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
        context.goNamed(SplashWidget.routeName);

        return;
      }

      await currentUserReference!.update(createUsersRecordData(
        lastconnectedday: getCurrentTimestamp,
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
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
