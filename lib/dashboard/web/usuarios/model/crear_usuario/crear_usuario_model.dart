import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'crear_usuario_widget.dart' show CrearUsuarioWidget;
import 'package:flutter/material.dart';

class CrearUsuarioModel extends FlutterFlowModel<CrearUsuarioWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadImage = false;
  FFUploadedFile uploadedLocalFile_uploadImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadImage = '';

  // State field(s) for DropDown widget.
  String? dropDownValue1;
  FormFieldController<String>? dropDownValueController1;
  // State field(s) for DropDown widget.
  String? dropDownValue2;
  FormFieldController<String>? dropDownValueController2;
  // State field(s) for Tipo widget.
  String? tipoValue;
  FormFieldController<String>? tipoValueController;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for Email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  
  // New fields
  FocusNode? textFieldedadFocusNode;
  TextEditingController? textFieldedadTextController;
  String? Function(BuildContext, String?)? textFieldedadTextControllerValidator;

  String? dropDownGeneroValue;
  FormFieldController<String>? dropDownGeneroValueController;

  FocusNode? textFieldfechaNacimientoFocusNode;
  TextEditingController? textFieldfechaNacimientoTextController;
  String? Function(BuildContext, String?)? textFieldfechaNacimientoTextControllerValidator;
  
  FocusNode? textFieldcolegioFocusNode;
  TextEditingController? textFieldcolegioTextController;
  String? Function(BuildContext, String?)? textFieldcolegioTextControllerValidator;
  FormFieldController<String>? colegioDropDownController;

  FocusNode? textFieldepsFocusNode;
  TextEditingController? textFieldepsTextController;
  String? Function(BuildContext, String?)? textFieldepsTextControllerValidator;

  FocusNode? textFieldgradoFocusNode;
  TextEditingController? textFieldgradoTextController;
  String? Function(BuildContext, String?)? textFieldgradoTextControllerValidator;

  FocusNode? textFieldmunicipioFocusNode;
  TextEditingController? textFieldmunicipioTextController;
  String? Function(BuildContext, String?)? textFieldmunicipioTextControllerValidator;

  FocusNode? textFieldbarrioFocusNode;
  TextEditingController? textFieldbarrioTextController;
  String? Function(BuildContext, String?)? textFieldbarrioTextControllerValidator;

  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;
  // State field(s) for repeatepassword widget.
  FocusNode? repeatepasswordFocusNode;
  TextEditingController? repeatepasswordTextController;
  late bool repeatepasswordVisibility;
  String? Function(BuildContext, String?)?
      repeatepasswordTextControllerValidator;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  UsersRecord? email;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  UsersRecord? getRefAcud;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  UsersRecord? getRefProf;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
    repeatepasswordVisibility = false;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    textFieldFocusNode4?.dispose();
    textController4?.dispose();
    
    textFieldedadFocusNode?.dispose();
    textFieldedadTextController?.dispose();



    textFieldfechaNacimientoFocusNode?.dispose();
    textFieldfechaNacimientoTextController?.dispose();

    textFieldcolegioFocusNode?.dispose();
    textFieldcolegioTextController?.dispose();

    textFieldepsFocusNode?.dispose();
    textFieldepsTextController?.dispose();

    textFieldgradoFocusNode?.dispose();
    textFieldgradoTextController?.dispose();

    textFieldmunicipioFocusNode?.dispose();
    textFieldmunicipioTextController?.dispose();

    textFieldbarrioFocusNode?.dispose();
    textFieldbarrioTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();

    repeatepasswordFocusNode?.dispose();
    repeatepasswordTextController?.dispose();
  }
}
