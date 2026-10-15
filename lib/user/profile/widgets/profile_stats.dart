import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A labeled text form field styled like the profile form inputs. Used for
/// the name / email / phone / DNI / address form fields.
class ProfileFormField extends StatelessWidget {
  const ProfileFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    this.validator,
    this.wrapInAuthStream = true,
    this.readOnly = false,
    this.nota,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(BuildContext, String?)? validator;
  final bool wrapInAuthStream;

  /// Campo no editable (p. ej. el correo de acceso).
  final bool readOnly;

  /// Texto de ayuda bajo el campo.
  final String? nota;

  @override
  Widget build(BuildContext context) {
    final field = _buildField(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [_buildLabel(context)],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: SizedBox(
                  height: 47.0,
                  child: wrapInAuthStream
                      ? AuthUserStreamWidget(builder: (context) => field)
                      : field,
                ),
              ),
            ),
          ],
        ),
        if (nota != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 0.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    nota!,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(BuildContext context) {
    final bodyMedium = FlutterFlowTheme.of(context).bodyMedium;
    return Text(
      label,
      style: bodyMedium.override(
        font: GoogleFonts.outfit(
          fontWeight: bodyMedium.fontWeight,
          fontStyle: bodyMedium.fontStyle,
        ),
        letterSpacing: 0.0,
        fontWeight: bodyMedium.fontWeight,
        fontStyle: bodyMedium.fontStyle,
      ),
    );
  }

  Widget _buildField(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final labelMedium = theme.labelMedium;
    final bodyMedium = theme.bodyMedium;
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: !readOnly,
      readOnly: readOnly,
      obscureText: false,
      decoration: InputDecoration(
        labelStyle: labelMedium.override(
          font: GoogleFonts.inter(
            fontWeight: labelMedium.fontWeight,
            fontStyle: labelMedium.fontStyle,
          ),
          color: theme.primaryText,
          fontSize: 14.0,
          letterSpacing: 0.0,
          fontWeight: labelMedium.fontWeight,
          fontStyle: labelMedium.fontStyle,
        ),
        hintText: hintText,
        hintStyle: labelMedium.override(
          font: GoogleFonts.inter(
            fontWeight: labelMedium.fontWeight,
            fontStyle: labelMedium.fontStyle,
          ),
          color: const Color(0x7C1F2129),
          fontSize: 16.0,
          letterSpacing: 0.0,
          fontWeight: labelMedium.fontWeight,
          fontStyle: labelMedium.fontStyle,
        ),
        enabledBorder: _border(theme.alternate),
        focusedBorder: _border(theme.primary),
        errorBorder: _border(theme.error),
        focusedErrorBorder: _border(theme.error),
        filled: true,
        fillColor: readOnly ? theme.alternate.withValues(alpha: 0.35) : null,
      ),
      style: bodyMedium.override(
        font: GoogleFonts.inter(
          fontWeight: bodyMedium.fontWeight,
          fontStyle: bodyMedium.fontStyle,
        ),
        fontSize: 14.0,
        letterSpacing: 0.0,
        fontWeight: bodyMedium.fontWeight,
        fontStyle: bodyMedium.fontStyle,
      ),
      validator: validator?.asValidator(context),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      );
}
