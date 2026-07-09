import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'editar_usuario_widget.dart' show EditarUsuarioWidget;
import 'package:flutter/material.dart';

class EditarUsuarioModel extends FlutterFlowModel<EditarUsuarioWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadImage2 = false;
  FFUploadedFile uploadedLocalFile_uploadImage2 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadImage2 = '';

  // State field(s) for DropDownAcudienteoAdolescente widget.
  String? dropDownAcudienteoAdolescenteValue;
  FormFieldController<String>? dropDownAcudienteoAdolescenteValueController;
  // State field(s) for DropDownProfesional widget.
  String? dropDownProfesionalValue;
  FormFieldController<String>? dropDownProfesionalValueController;
  // State field(s) for dd-Tipo widget.
  String? ddTipoValue;
  FormFieldController<String>? ddTipoValueController;
  // State field(s) for TextFieldNombres widget.
  FocusNode? textFieldNombresFocusNode;
  TextEditingController? textFieldNombresTextController;
  String? Function(BuildContext, String?)?
      textFieldNombresTextControllerValidator;
  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // State field(s) for TextFieldphone widget.
  FocusNode? textFieldphoneFocusNode;
  TextEditingController? textFieldphoneTextController;
  String? Function(BuildContext, String?)?
      textFieldphoneTextControllerValidator;
  // State field(s) for TextFielddni widget.
  FocusNode? textFielddniFocusNode;
  TextEditingController? textFielddniTextController;
  String? Function(BuildContext, String?)? textFielddniTextControllerValidator;
  // State field(s) for TextFieldaddress widget.
  FocusNode? textFieldaddressFocusNode;
  TextEditingController? textFieldaddressTextController;
  String? Function(BuildContext, String?)?
      textFieldaddressTextControllerValidator;
      
  // New fields for colegio, eps, grado, municipio, barrio
  FocusNode? textFieldcolegioFocusNode;
  TextEditingController? textFieldcolegioTextController;
  String? Function(BuildContext, String?)? textFieldcolegioTextControllerValidator;

  FocusNode? textFieldedadFocusNode;
  TextEditingController? textFieldedadTextController;
  String? Function(BuildContext, String?)? textFieldedadTextControllerValidator;

  String? dropDownGeneroValue;
  FormFieldController<String>? dropDownGeneroValueController;

  FocusNode? textFieldfechaNacimientoFocusNode;
  TextEditingController? textFieldfechaNacimientoTextController;
  String? Function(BuildContext, String?)? textFieldfechaNacimientoTextControllerValidator;

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

  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  UsersRecord? getRefAcud;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  UsersRecord? getRefProf;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldNombresFocusNode?.dispose();
    textFieldNombresTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();

    textFieldphoneFocusNode?.dispose();
    textFieldphoneTextController?.dispose();

    textFielddniFocusNode?.dispose();
    textFielddniTextController?.dispose();

    textFieldaddressFocusNode?.dispose();
    textFieldaddressTextController?.dispose();
    
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
  }
}
