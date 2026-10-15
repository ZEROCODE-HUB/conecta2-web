import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/pop_ups/thank_you_copy/thank_you_copy_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'calendar_header.dart';
import '../../emociones_service.dart';

/// Feedback form shown after the user picks an emotion. Works for both the
/// "sad/neutral" path (asset CHICA / CHICO) and the "happy" path; the parent
/// supplies the correct imagery + copy.
/// Evita guardar dos veces si se toca "enviar" repetidamente.
bool _guardandoEmocion = false;

class EmotionFeedbackForm extends StatelessWidget {
  const EmotionFeedbackForm({
    super.key,
    required this.heroAsset,
    required this.message,
    required this.messageTextAlign,
    required this.isKeyboardVisible,
    required this.controller,
    required this.focusNode,
    required this.validator,
    required this.emocionElegida,
    required this.onSubmitted,
  });

  final String heroAsset;
  final String message;
  final TextAlign messageTextAlign;
  final bool isKeyboardVisible;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(BuildContext, String?)? validator;
  final int? emocionElegida;

  /// Called after the registro is persisted and dialog shown.
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    heroAsset,
                    width: 300.0,
                    height: 200.0,
                    fit: BoxFit.contain,
                  ),
                ),
                CalendarHeader(
                  message: message,
                  showImage: false,
                  textAlign: messageTextAlign,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                0.0,
                isKeyboardVisible ? 20.0 : 160.0,
                0.0,
                0.0,
              ),
              child: _buildInputRow(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final labelMedium = theme.labelMedium;
    final bodyMedium = theme.bodyMedium;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: false,
                  obscureText: false,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Escribe',
                    labelStyle: labelMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: labelMedium.fontWeight,
                        fontStyle: labelMedium.fontStyle,
                      ),
                      color: const Color(0xFF9E8888),
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: labelMedium.fontWeight,
                      fontStyle: labelMedium.fontStyle,
                    ),
                    hintStyle: labelMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: labelMedium.fontWeight,
                        fontStyle: labelMedium.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight: labelMedium.fontWeight,
                      fontStyle: labelMedium.fontStyle,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                  style: bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: bodyMedium.fontWeight,
                      fontStyle: bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight: bodyMedium.fontWeight,
                    fontStyle: bodyMedium.fontStyle,
                  ),
                  maxLines: 4,
                  minLines: 1,
                  validator: validator?.asValidator(context),
                ),
              ),
            ),
            Builder(
              builder: (context) => InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () => _handleSubmit(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/ICONO_DE_ENVIARRecurso_28Plantilla.png',
                    height: 30.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final userRef = currentUserReference;
    final emocion = emocionElegida;
    if (_guardandoEmocion || userRef == null || emocion == null) return;
    _guardandoEmocion = true;
    try {
      // Un registro por día: se comprueba en Firestore, no en el dispositivo
      // (otro teléfono, reinstalación o la web podían duplicarlo).
      final hoy = await emocionDeHoy(userRef);
      if (hoy == null) {
        await EmocionesRegistroRecord.createDoc(userRef).set(
          createEmocionesRegistroRecordData(
            fecha: functions.formatdate(getCurrentTimestamp),
            emocion: emocion,
            descripcion: controller.text.trim(),
          ),
        );
      }
      // El estado local se actualiza antes del diálogo: si la app se cierra
      // con el diálogo abierto, no queda desincronizado.
      await sincronizarEmociones(userRef);
      if (!context.mounted) return;
      if (hoy != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya registraste tu emoción de hoy.'),
          ),
        );
        onSubmitted();
        return;
      }
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
                child: ThankYouCopyWidget(),
              ),
            ),
          );
        },
      );
      onSubmitted();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No se pudo guardar tu emoción. Revisa tu conexión e inténtalo de nuevo.'),
          ),
        );
      }
    } finally {
      _guardandoEmocion = false;
    }
  }
}

/// Finish-state view: showing the chosen emotion result with celebratory or
/// supportive copy plus a cached network image.
class EmotionFinishView extends StatelessWidget {
  const EmotionFinishView({super.key});

  @override
  Widget build(BuildContext context) {
    final emocion = FFAppState().emocionDay;
    final theme = FlutterFlowTheme.of(context);
    final labelSmall = theme.labelSmall;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
      child: Container(
        width: double.infinity,
        height: 150.0,
        decoration: BoxDecoration(
          color: theme.primary,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(-1.0, 0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        _finishImageUrl(emocion),
                        fit: BoxFit.contain,
                        width: 150.0,
                        height: 150.0,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 15.0, 15.0, 15.0),
                      child: Text(
                        _finishText(context, emocion),
                        style: labelSmall.override(
                          font: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontStyle: labelSmall.fontStyle,
                            height: 1.2,
                          ),
                          fontSize: 18.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle: labelSmall.fontStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _finishImageUrl(int emocion) {
    switch (emocion) {
      case 5:
        return 'assets/images/ChicoRecurso.png';
      case 4:
        return 'assets/images/ChicoRecurso.png';
      default:
        return 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/ro5jhc7xaao0/CHICORecurso_22Plantilla_(1).png';
    }
  }

  String _finishText(BuildContext context, int emocion) {
    final prefix =
        emocion == 5 ? 'Felicitaciones, hoy ' : 'Desafortunadamente, ';
    final date = dateTimeFormat(
      "MMMMd",
      FFAppState().dateEmocion,
      locale: FFLocalizations.of(context).languageCode,
    );
    String label;
    switch (emocion) {
      case 1:
        label = 'Enojo';
        break;
      case 2:
        label = 'Miedo';
        break;
      case 3:
        label = 'Tristeza';
        break;
      case 4:
        label = 'Indiferencia';
        break;
      default:
        label = 'Alegría';
    }
    return '$prefix$date tus emociones son más de $label';
  }
}
