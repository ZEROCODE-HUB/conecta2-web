import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renders the six profile text fields arranged as three two-column rows:
///
///   [ Tipo de usuario ] [ Nombres y Apellidos ]
///   [ Email          ] [ Celular             ]
///   [ Documento ID   ] [ Dirección           ]
///
/// Each field is wrapped in [AuthUserStreamWidget] so values refresh when
/// the backing `currentUserDocument` stream emits.
class ProfileForm extends StatelessWidget {
  const ProfileForm({
    super.key,
    required this.rolController,
    required this.rolFocusNode,
    required this.rolValidator,
    required this.nameController,
    required this.nameFocusNode,
    required this.nameValidator,
    required this.emailController,
    required this.emailFocusNode,
    required this.emailValidator,
    required this.phoneController,
    required this.phoneFocusNode,
    required this.phoneValidator,
    required this.idController,
    required this.idFocusNode,
    required this.idValidator,
    required this.addressController,
    required this.addressFocusNode,
    required this.addressValidator,
  });

  final TextEditingController rolController;
  final FocusNode rolFocusNode;
  final String? Function(BuildContext, String?)? rolValidator;

  final TextEditingController nameController;
  final FocusNode nameFocusNode;
  final String? Function(BuildContext, String?)? nameValidator;

  final TextEditingController emailController;
  final FocusNode emailFocusNode;
  final String? Function(BuildContext, String?)? emailValidator;

  final TextEditingController phoneController;
  final FocusNode phoneFocusNode;
  final String? Function(BuildContext, String?)? phoneValidator;

  final TextEditingController idController;
  final FocusNode idFocusNode;
  final String? Function(BuildContext, String?)? idValidator;

  final TextEditingController addressController;
  final FocusNode addressFocusNode;
  final String? Function(BuildContext, String?)? addressValidator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
            child: Text(
              'Datos personales',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    fontSize: 24.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          _row(
            left: _FieldBlock(
              label: 'Tipo de usuario',
              hint: 'rol',
              controller: rolController,
              focusNode: rolFocusNode,
              validator: rolValidator,
              wrapInAuthStream: true,
            ),
            right: _FieldBlock(
              label: 'Nombres y Apellidos',
              hint: 'Nombres y Apellidos',
              controller: nameController,
              focusNode: nameFocusNode,
              validator: nameValidator,
              wrapInAuthStream: true,
              labelFontSize: 18.0,
            ),
          ),
          _row(
            left: _FieldBlock(
              label: 'Correo electrónico',
              hint: 'john@gmail.com',
              controller: emailController,
              focusNode: emailFocusNode,
              validator: emailValidator,
              wrapInAuthStream: false,
              readOnly: true,
              widthOverride: 200.0,
            ),
            right: _FieldBlock(
              label: 'Celular',
              hint: '948 494 132',
              controller: phoneController,
              focusNode: phoneFocusNode,
              validator: phoneValidator,
              wrapInAuthStream: true,
              widthOverride: 200.0,
              labelFontSize: 18.0,
            ),
          ),
          _row(
            left: _FieldBlock(
              label: 'Documento de identidad',
              hint: '134534',
              controller: idController,
              focusNode: idFocusNode,
              validator: idValidator,
              wrapInAuthStream: true,
            ),
            right: _FieldBlock(
              label: 'Dirección',
              hint: 'Jiron 3044',
              controller: addressController,
              focusNode: addressFocusNode,
              validator: addressValidator,
              wrapInAuthStream: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row({required Widget left, required Widget right}) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 25.0),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.validator,
    required this.wrapInAuthStream,
    this.widthOverride,
    this.labelFontSize,
    this.readOnly = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(BuildContext, String?)? validator;
  final bool wrapInAuthStream;
  final double? widthOverride;
  final double? labelFontSize;

  /// Campo no editable (el correo de acceso).
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final field = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
      child: SizedBox(
        width: widthOverride ?? double.infinity,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          readOnly: readOnly,
          obscureText: false,
          decoration: InputDecoration(
            hintText: hint,
            helperText: readOnly
                ? 'Correo de acceso. Para cambiarlo, contacta al administrador.'
                : null,
            helperMaxLines: 2,
            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                  font: GoogleFonts.inter(),
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                ),
            enabledBorder: _underline(context, const Color(0x00000000)),
            focusedBorder: _underline(context, const Color(0x00000000)),
            errorBorder:
                _underline(context, FlutterFlowTheme.of(context).error),
            focusedErrorBorder:
                _underline(context, FlutterFlowTheme.of(context).error),
            filled: true,
            fillColor:
                readOnly ? const Color(0xFFE9ECF2) : const Color(0xFFF5F5F5),
          ),
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                letterSpacing: 0.0,
              ),
          validator: validator?.asValidator(context),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                fontSize: labelFontSize,
                letterSpacing: 0.0,
              ),
        ),
        wrapInAuthStream
            ? AuthUserStreamWidget(builder: (context) => field)
            : field,
      ],
    );
  }

  UnderlineInputBorder _underline(BuildContext context, Color color) {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: color, width: 2.0),
      borderRadius: BorderRadius.circular(8.0),
    );
  }
}
