import '/auth/firebase_auth/auth_util.dart';
import '/user/registration/sesion_app.dart';
import '/backend/backend.dart';
import '/components/successpopup_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

/// "Restaurar contraseña" button. Triggers a password reset email and shows
/// the shared [SuccesspopupWidget] dialog when it completes.
class ProfileResetPasswordButton extends StatelessWidget {
  const ProfileResetPasswordButton({
    super.key,
    required this.emailController,
  });

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 25.0, 0.0, 0.0),
      child: FFButtonWidget(
        onPressed: () async {
          if (correoDeAcceso.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No se encontró tu correo de acceso.')),
            );
            return;
          }
          await authManager.resetPassword(
            email: correoDeAcceso,
            context: context,
          );
          if (!context.mounted) return;
          await _showSuccess(context);
        },
        text: 'Restaurar contraseña',
        options: FFButtonOptions(
          width: 245.0,
          height: 40.0,
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
          iconPadding: EdgeInsetsDirectional.zero,
          color: const Color(0xFFF6BD33),
          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                font: GoogleFonts.inter(),
                color: const Color(0xFF265294),
                fontSize: 18.0,
                letterSpacing: 0.0,
              ),
          elevation: 3.0,
          borderSide: const BorderSide(color: Colors.transparent, width: 1.0),
          borderRadius: BorderRadius.circular(40.0),
        ),
      ),
    );
  }
}

/// "Guardar" button — persists all profile fields and the newly uploaded
/// photo (if any) back to the user's document.
class ProfileSaveButton extends StatelessWidget {
  const ProfileSaveButton({
    super.key,
    required this.uploadedFileUrl,
    required this.emailController,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
  });

  final String uploadedFileUrl;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 40.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FFButtonWidget(
            onPressed: () async {
              final ref = currentUserReference;
              if (ref == null) return;
              // El correo no se edita aquí: es el de acceso.
              await ref.update(createUsersRecordData(
                displayName: nameController.text,
                photoUrl: uploadedFileUrl.isNotEmpty
                    ? uploadedFileUrl
                    : currentUserPhoto,
                phoneNumber: phoneController.text,
                address: addressController.text,
              ));
              if (!context.mounted) return;
              await _showSuccess(context);
            },
            text: 'Guardar',
            options: FFButtonOptions(
              width: 245.0,
              height: 54.0,
              padding:
                  const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              iconPadding: EdgeInsetsDirectional.zero,
              color: const Color(0xFFF6BD33),
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.inter(),
                    color: const Color(0xFF265294),
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                  ),
              elevation: 3.0,
              borderSide:
                  const BorderSide(color: Color(0xFFF6BD33), width: 1.0),
              borderRadius: BorderRadius.circular(40.0),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showSuccess(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        alignment: const AlignmentDirectional(0.0, 0.0)
            .resolve(Directionality.of(context)),
        child: WebViewAware(child: SuccesspopupWidget()),
      );
    },
  );
}
