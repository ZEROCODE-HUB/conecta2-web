import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'editar_contenido_widget.dart' show EditarContenidoWidget;
import 'package:flutter/material.dart';

class EditarContenidoModel extends FlutterFlowModel<EditarContenidoWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  bool isDataUploading_uploadDataMes2 = false;
  FFUploadedFile uploadedLocalFile_uploadDataMes2 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataMes2 = '';

  bool isDataUploading_uploadDataXz5 = false;
  FFUploadedFile uploadedLocalFile_uploadDataXz5 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataXz5 = '';

  // State field(s) for DropDown-roles widget.
  List<String>? dropDownRolesValue;
  FormFieldController<List<String>>? dropDownRolesValueController;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;

  /// Contenido en edición (sin guardar) que muestra la vista previa.
  ContenidoRecord? previa;

  /// Deja el formulario vacío para abrir otro contenido. El modelo vive en
  /// [AdminContenido2Model] y se reutiliza: sin esto, el título, los roles y
  /// las imágenes del contenido anterior se escribían en el siguiente.
  /// Llamar solo con el editor cerrado.
  void reiniciar() {
    textController?.dispose();
    textController = null;
    isDataUploading_uploadDataMes2 = false;
    uploadedLocalFile_uploadDataMes2 =
        FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
    uploadedFileUrl_uploadDataMes2 = '';
    isDataUploading_uploadDataXz5 = false;
    uploadedLocalFile_uploadDataXz5 =
        FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
    uploadedFileUrl_uploadDataXz5 = '';
    dropDownRolesValue = null;
    dropDownRolesValueController = null;
    dropDownValue = null;
    dropDownValueController = null;
    previa = null;
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
