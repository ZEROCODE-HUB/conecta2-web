import '/auth/firebase_auth/auth_util.dart';
import '/components/calendario_read2/calendario_read2_widget.dart';
import '/components/footer/footer_widget.dart';
import '/components/header/header_widget.dart';
import '/components/show_calender_details/show_calender_details_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'calendario_page_model.dart';
import 'widgets/calendar_header.dart';
import 'widgets/emotion_detail.dart';
import 'widgets/emotion_selector.dart';
export 'calendario_page_model.dart';

class CalendarioPageWidget extends StatefulWidget {
  const CalendarioPageWidget({super.key});

  static String routeName = 'CalendarioPage';
  static String routePath = '/calendarioPage';

  @override
  State<CalendarioPageWidget> createState() => _CalendarioPageWidgetState();
}

class _CalendarioPageWidgetState extends State<CalendarioPageWidget>
    with TickerProviderStateMixin {
  late CalendarioPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CalendarioPageModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final todayFormatted = dateTimeFormat(
        "d/M/y",
        getCurrentTimestamp,
        locale: FFLocalizations.of(context).languageCode,
      );
      final emotionDateFormatted = dateTimeFormat(
        "d/M/y",
        FFAppState().dateEmocion,
        locale: FFLocalizations.of(context).languageCode,
      );

      if (emotionDateFormatted == todayFormatted) {
        _model.slider = 'Finish';
        _model.emocionelegida = FFAppState().emocionDay;
      } else {
        _model.slider = 'Start';
        _model.emocionelegida = null;
        FFAppState().emocionDay = 0;
      }
      safeSetState(() {});

      final lastEmotionFormatted = dateTimeFormat(
        "d/M/y",
        FFAppState().CalenderEmotion.lastOrNull?.date,
        locale: FFLocalizations.of(context).languageCode,
      );
      if (lastEmotionFormatted == '') {
        _model.slider = 'Start';
        _model.emocionelegida = null;
        FFAppState().emocionDay = 0;
        FFAppState().CalenderEmotion = [];
        safeSetState(() {});
      }
    });

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _buildAnimationsMap();

    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  void _buildAnimationsMap() {
    AnimationInfo scaleAnim() => AnimationInfo(
          trigger: AnimationTrigger.onActionTrigger,
          applyInitialState: true,
          effectsBuilder: () => [
            ScaleEffect(
              curve: Curves.easeInOut,
              delay: 0.0.ms,
              duration: 500.0.ms,
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.2, 1.2),
            ),
          ],
        );
    for (var i = 1; i <= 10; i++) {
      animationsMap['containerOnActionTriggerAnimation$i'] = scaleAnim();
    }
  }

  @override
  void dispose() {
    _model.dispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  bool get _keyboardIsVisible =>
      isWeb ? MediaQuery.viewInsetsOf(context).bottom > 0 : _isKeyboardVisible;

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.sizeOf(context).height * 1.0,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 50.0, 20.0, 0.0),
                    child: SingleChildScrollView(
                      primary: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Builder(builder: (context) => _buildSliderContent()),
                        ],
                      ),
                    ),
                  ),
                ),
                wrapWithModel(
                  model: _model.headerModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const HeaderWidget(
                    pageTitle: 'Calendario',
                    showIconBack: false,
                  ),
                ),
                if (!_keyboardIsVisible)
                  Align(
                    alignment: const AlignmentDirectional(0.0, 1.0),
                    child: wrapWithModel(
                      model: _model.footerModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const FooterWidget(active: 2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderContent() {
    if (_model.slider == 'Start') {
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const CalendarHeader(
            message: '¿Como te sientes\nel día de hoy?  ',
          ),
          EmotionSelector(
            animationsMap: animationsMap,
            onEmotionPicked: (emotion) {
              _model.emocionelegida = emotion;
              _model.slider = 'Dis';
              FFAppState().emocionDay = emotion;
              safeSetState(() {});
            },
          ),
        ],
      );
    }

    if (_model.slider == 'Dis' && (_model.emocionelegida ?? 0) <= 4) {
      return EmotionFeedbackForm(
        heroAsset: 'assets/images/CHICARecurso_20Plantilla.png',
        message: '¿Quieres contarme\npor qué te sientes así? ',
        messageTextAlign: TextAlign.left,
        isKeyboardVisible: _keyboardIsVisible,
        controller: _model.textController1!,
        focusNode: _model.textFieldFocusNode1!,
        validator: _model.textController1Validator,
        emocionElegida: _model.emocionelegida,
        onSubmitted: () {
          _model.slider = 'Finish';
          safeSetState(() {});
        },
      );
    }

    if (_model.slider == 'Dis' && _model.emocionelegida == 5) {
      return EmotionFeedbackForm(
        heroAsset: 'assets/images/ChicoRecurso.png',
        message:
            'Qué alegría que estés bien,\npuedes escribirme si\nnecesitas algo',
        messageTextAlign: TextAlign.center,
        isKeyboardVisible: _keyboardIsVisible,
        controller: _model.textController2!,
        focusNode: _model.textFieldFocusNode2!,
        validator: _model.textController2Validator,
        emocionElegida: _model.emocionelegida,
        onSubmitted: () {
          _model.slider = 'Finish';
          safeSetState(() {});
        },
      );
    }

    return SingleChildScrollView(
      primary: false,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const EmotionFinishView(),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
            child: wrapWithModel(
              model: _model.calendarioRead2Model,
              updateCallback: () => safeSetState(() {}),
              updateOnChange: true,
              child: CalendarioRead2Widget(
                inputDate: getCurrentTimestamp,
                initialSelectedDate: getCurrentTimestamp,
                userRef: currentUserReference!,
                onSelectDateAction: (selectedDate) async {
                  await showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return Dialog(
                        elevation: 0,
                        insetPadding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        alignment: const AlignmentDirectional(0.0, 0.0)
                            .resolve(Directionality.of(context)),
                        child: WebViewAware(
                          child: GestureDetector(
                            onTap: () {
                              FocusScope.of(dialogContext).unfocus();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: ShowCalenderDetailsWidget(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
