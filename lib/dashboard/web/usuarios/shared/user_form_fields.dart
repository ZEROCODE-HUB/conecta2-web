import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Default fallback avatar url used across the Usuarios screens.
const String kDefaultAvatarUrl =
    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/9yllj3p8hz5o/User.png';

/// Roles available for user creation/editing.
const List<String> kUserRoles = <String>[
  'Adolescente',
  'Acudiente',
  'Profesional',
];

/// Shared light-grey fill color used for form fields.
const Color kFormFieldFillColor = Color(0xFFF5F5F5);

/// Accent color used for primary buttons.
const Color kAccentYellow = Color(0xFFF6BD33);

/// Accent color used for primary button text.
const Color kAccentBlue = Color(0xFF265294);

/// Safe `Image.asset` with fallback builder so asset load errors don't crash UI.
Widget safeAssetImage(
  String assetPath, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  return Image.asset(
    assetPath,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => Icon(
      Icons.image_not_supported_outlined,
      size: (width ?? height ?? 24.0) * 0.6,
      color: Colors.grey,
    ),
  );
}

/// Builds a styled label `Text` used above every form field in the Usuarios
/// module.
Widget buildFieldLabel(BuildContext context, String text) {
  return Text(
    text,
    style: FlutterFlowTheme.of(context).bodyMedium.override(
          font: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
          ),
          fontSize: 18.0,
          letterSpacing: 0.0,
          fontWeight: FontWeight.w500,
        ),
  );
}

/// Builds a styled section title (e.g. "Datos personales").
Widget buildSectionTitle(BuildContext context, String text,
    {double fontSize = 24.0}) {
  return Text(
    text,
    style: FlutterFlowTheme.of(context).bodyMedium.override(
          font: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
          ),
          fontSize: fontSize,
          letterSpacing: 0.0,
          fontWeight: FontWeight.w600,
        ),
  );
}

/// Returns an [InputDecoration] that matches the design across both
/// crear/editar user forms.
InputDecoration sharedInputDecoration(
  BuildContext context, {
  required String hintText,
  Widget? suffixIcon,
  bool useErrorColor = true,
}) {
  final errorColor =
      useErrorColor ? FlutterFlowTheme.of(context).error : const Color(0x00000000);
  return InputDecoration(
    labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
          font: GoogleFonts.inter(
            fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
            fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
          ),
          fontSize: 16.0,
          letterSpacing: 0.0,
        ),
    hintText: hintText,
    hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
          font: GoogleFonts.inter(
            fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
            fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
          ),
          color: const Color(0xFF9E8888),
          fontSize: 16.0,
          letterSpacing: 0.0,
        ),
    enabledBorder: UnderlineInputBorder(
      borderSide: const BorderSide(color: Color(0x00000000), width: 2.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: const BorderSide(color: Color(0x00000000), width: 2.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: errorColor, width: 2.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: errorColor, width: 2.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    filled: true,
    fillColor: kFormFieldFillColor,
    suffixIcon: suffixIcon,
  );
}

/// Shared text style for text fields.
TextStyle sharedFieldTextStyle(BuildContext context,
    {FontWeight? fontWeight}) {
  return FlutterFlowTheme.of(context).bodyMedium.override(
        font: GoogleFonts.inter(
          fontWeight:
              fontWeight ?? FlutterFlowTheme.of(context).bodyMedium.fontWeight,
          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
        ),
        letterSpacing: 0.0,
        fontWeight:
            fontWeight ?? FlutterFlowTheme.of(context).bodyMedium.fontWeight,
      );
}

/// A "label + TextFormField" pair used extensively in both widgets.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLength,
    this.suffixIcon,
    this.useErrorColor = true,
    this.fontWeight,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool autofocus;
  final int? maxLength;
  final Widget? suffixIcon;
  final bool useErrorColor;
  final FontWeight? fontWeight;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFieldLabel(context, label),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
          child: SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              obscureText: obscureText,
              maxLength: maxLength,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: sharedInputDecoration(
                context,
                hintText: hintText ?? label,
                suffixIcon: suffixIcon,
                useErrorColor: useErrorColor,
              ),
              style: sharedFieldTextStyle(context, fontWeight: fontWeight),
              validator: validator,
            ),
          ),
        ),
      ],
    );
  }
}

/// Common dropdown wrapper that matches the Usuarios design.
Widget buildStyledDropDown({
  required BuildContext context,
  required FormFieldController<String> controller,
  required List<String> options,
  List<String>? optionLabels,
  required ValueChanged<String?> onChanged,
  String hintText = 'Seleccionar...',
  double? width,
  double height = 56.0,
}) {
  return FlutterFlowDropDown<String>(
    controller: controller,
    options: options,
    optionLabels: optionLabels,
    onChanged: onChanged,
    width: width,
    height: height,
    textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
          font: GoogleFonts.inter(
            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
          ),
          letterSpacing: 0.0,
        ),
    hintText: hintText,
    icon: const Icon(
      Icons.keyboard_arrow_down_rounded,
      color: kAccentBlue,
      size: 35.0,
    ),
    fillColor: kFormFieldFillColor,
    elevation: 2.0,
    borderColor: FlutterFlowTheme.of(context).alternate,
    borderWidth: 2.0,
    borderRadius: 8.0,
    margin: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
    hidesUnderline: true,
    isOverButton: false,
    isSearchable: false,
    isMultiSelect: false,
  );
}

/// Builds a searchable styled dropdown (used by the edit-user form).
Widget buildSearchableDropDown({
  required BuildContext context,
  required FormFieldController<String> controller,
  required List<String> options,
  required ValueChanged<String?> onChanged,
  required String hintText,
  required String searchHintText,
  List<String>? optionLabels,
  double? width,
  double height = 56.0,
}) {
  final labelStyle = FlutterFlowTheme.of(context).labelMedium.override(
        font: GoogleFonts.inter(
          fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
          fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
        ),
        letterSpacing: 0.0,
      );
  final bodyStyle = FlutterFlowTheme.of(context).bodyMedium.override(
        font: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
        ),
        letterSpacing: 0.0,
        fontWeight: FontWeight.w500,
      );
  return FlutterFlowDropDown<String>(
    controller: controller,
    options: options,
    optionLabels: optionLabels,
    onChanged: onChanged,
    width: width,
    height: height,
    searchHintTextStyle: labelStyle,
    searchTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
          font: GoogleFonts.inter(
            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
          ),
          letterSpacing: 0.0,
        ),
    textStyle: bodyStyle,
    hintText: hintText,
    searchHintText: searchHintText,
    icon: Icon(
      Icons.keyboard_arrow_down_rounded,
      color: FlutterFlowTheme.of(context).secondaryText,
      size: 24.0,
    ),
    fillColor: kFormFieldFillColor,
    elevation: 2.0,
    borderColor: FlutterFlowTheme.of(context).alternate,
    borderWidth: 2.0,
    borderRadius: 8.0,
    margin: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
    hidesUnderline: true,
    isOverButton: true,
    isSearchable: true,
    isMultiSelect: false,
  );
}

/// Stream-based role dropdown: lists `UsersRecord`s whose `rol` field equals
/// the given role and exposes their `displayName` values.
///
/// Con [valoresPorId] el valor de cada opción es el id del perfil (no el
/// nombre, que puede repetirse o cambiar), la etiqueta es "Nombre (correo)"
/// y la primera opción, con valor vacío, es [etiquetaVacia].
Widget buildUsersByRoleDropdown({
  required BuildContext context,
  required String rol,
  required FormFieldController<String> Function() controllerFactory,
  required ValueChanged<String?> onChanged,
  bool valoresPorId = false,
  String etiquetaVacia = 'Sin asignar',
}) {
  return StreamBuilder<List<UsersRecord>>(
    stream: queryUsersRecord(
      queryBuilder: (usersRecord) => usersRecord.where('rol', isEqualTo: rol),
    ),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(
          child: SizedBox(
            width: 50.0,
            height: 50.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
          ),
        );
      }
      final users = snapshot.data!;
      if (valoresPorId) {
        final ordenados = [...users]..sort((a, b) => a.displayName
            .toLowerCase()
            .compareTo(b.displayName.toLowerCase()));
        return buildStyledDropDown(
          context: context,
          controller: controllerFactory(),
          options: ['', ...ordenados.map((e) => e.reference.id)],
          optionLabels: [
            etiquetaVacia,
            ...ordenados.map((e) =>
                e.email.isEmpty ? e.displayName : '${e.displayName} (${e.email})'),
          ],
          onChanged: onChanged,
          width: 276.0,
        );
      }
      final names = users.map((e) => e.displayName).toList();
      return buildStyledDropDown(
        context: context,
        controller: controllerFactory(),
        options: names,
        optionLabels: names,
        onChanged: onChanged,
        width: 276.0,
      );
    },
  );
}

/// Builds the primary accented "action" button (e.g. "Crear nuevo usuario").
FFButtonWidget buildPrimaryButton({
  required BuildContext context,
  required String text,
  required Future<void> Function() onPressed,
  double height = 40.0,
  double? width,
  double borderRadius = 45.0,
}) {
  return FFButtonWidget(
    onPressed: onPressed,
    text: text,
    options: FFButtonOptions(
      width: width,
      height: height,
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
      iconPadding:
          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
      color: kAccentYellow,
      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
            font: GoogleFonts.inter(
              fontWeight:
                  FlutterFlowTheme.of(context).titleSmall.fontWeight,
              fontStyle:
                  FlutterFlowTheme.of(context).titleSmall.fontStyle,
            ),
            color: kAccentBlue,
            fontSize: 18.0,
            letterSpacing: 0.0,
          ),
      elevation: 3.0,
      borderSide: const BorderSide(color: kAccentYellow, width: 1.0),
      borderRadius: BorderRadius.circular(borderRadius),
    ),
  );
}

/// Builds the "Cancel" (secondary) button used on both forms.
FFButtonWidget buildSecondaryButton({
  required BuildContext context,
  required String text,
  required Future<void> Function() onPressed,
  double height = 40.0,
  double? width,
  double borderRadius = 45.0,
}) {
  return FFButtonWidget(
    onPressed: onPressed,
    text: text,
    options: FFButtonOptions(
      width: width,
      height: height,
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
      iconPadding:
          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
      color: FlutterFlowTheme.of(context).secondaryBackground,
      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
            font: GoogleFonts.inter(
              fontWeight:
                  FlutterFlowTheme.of(context).titleSmall.fontWeight,
              fontStyle:
                  FlutterFlowTheme.of(context).titleSmall.fontStyle,
            ),
            color: kAccentBlue,
            fontSize: 18.0,
            letterSpacing: 0.0,
          ),
      elevation: 3.0,
      borderSide: const BorderSide(color: kAccentYellow, width: 1.0),
      borderRadius: BorderRadius.circular(borderRadius),
    ),
  );
}

/// Standard white card decoration used for the two side panels.
BoxDecoration sharedCardDecoration() => BoxDecoration(
      color: Colors.white,
      boxShadow: const [
        BoxShadow(
          blurRadius: 50.0,
          color: Color(0x26000000),
          offset: Offset(20.0, 20.0),
        ),
      ],
      borderRadius: BorderRadius.circular(20.0),
    );
