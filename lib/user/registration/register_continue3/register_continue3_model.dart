import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'register_continue3_widget.dart' show RegisterContinue3Widget;
import 'package:flutter/material.dart';

class RegisterContinue3Model extends FlutterFlowModel<RegisterContinue3Widget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  DateTime? datePicked1;
  DateTime? datePicked2;
  // State field(s) for TextFieldNombreParentesco widget.
  FocusNode? textFieldNombreParentescoFocusNode;
  TextEditingController? textFieldNombreParentescoTextController;
  String? Function(BuildContext, String?)?
      textFieldNombreParentescoTextControllerValidator;
  String? _textFieldNombreParentescoTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Ingresa el nombre del acudiente';
    }

    return null;
  }
  // State field(s) for TextFieldParentesco widget.
  FocusNode? textFieldParentescoFocusNode;
  TextEditingController? textFieldParentescoTextController;
  String? Function(BuildContext, String?)?
      textFieldParentescoTextControllerValidator;
  String? _textFieldParentescoTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Ingresa el parentesco';
    }

    return null;
  }

  // State field(s) for correoParentesco widget.
  FocusNode? correoParentescoFocusNode;
  TextEditingController? correoParentescoTextController;
  String? Function(BuildContext, String?)?
      correoParentescoTextControllerValidator;
  String? _correoParentescoTextControllerValidator(
      BuildContext context, String? val) {
    final correo = val?.trim() ?? '';
    if (correo.isEmpty) {
      return 'Ingresa el correo del acudiente';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(correo)) {
      return 'Ingresa un correo válido';
    }

    return null;
  }

  // State field(s) for TextFieldTelefonoParentesco widget.
  FocusNode? textFieldTelefonoParentescoFocusNode;
  TextEditingController? textFieldTelefonoParentescoTextController;
  String? Function(BuildContext, String?)?
      textFieldTelefonoParentescoTextControllerValidator;
  String? _textFieldTelefonoParentescoTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Ingresa el teléfono del acudiente';
    }

    return null;
  }

  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  UsersRecord? usuarioCreado;

  @override
  void initState(BuildContext context) {
    textFieldNombreParentescoTextControllerValidator =
        _textFieldNombreParentescoTextControllerValidator;
    textFieldParentescoTextControllerValidator =
        _textFieldParentescoTextControllerValidator;
    correoParentescoTextControllerValidator =
        _correoParentescoTextControllerValidator;
    textFieldTelefonoParentescoTextControllerValidator =
        _textFieldTelefonoParentescoTextControllerValidator;
  }

  @override
  void dispose() {
    textFieldNombreParentescoFocusNode?.dispose();
    textFieldNombreParentescoTextController?.dispose();

    textFieldParentescoFocusNode?.dispose();
    textFieldParentescoTextController?.dispose();

    correoParentescoFocusNode?.dispose();
    correoParentescoTextController?.dispose();

    textFieldTelefonoParentescoFocusNode?.dispose();
    textFieldTelefonoParentescoTextController?.dispose();
  }
}
