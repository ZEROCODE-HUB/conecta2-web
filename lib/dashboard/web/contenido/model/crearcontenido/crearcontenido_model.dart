import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'crearcontenido_widget.dart' show CrearcontenidoWidget;
import 'package:flutter/material.dart';

class CrearcontenidoModel extends FlutterFlowModel<CrearcontenidoWidget> {
  ///  Local state fields for this component.

  String? imgperfil;

  String? imgportada;

  ///  State fields for stateful widgets in this component.

  // State field(s) for Titulo widget.
  FocusNode? tituloFocusNode;
  TextEditingController? tituloTextController;
  String? Function(BuildContext, String?)? tituloTextControllerValidator;
  bool isDataUploading_uploadDataXz3 = false;
  FFUploadedFile uploadedLocalFile_uploadDataXz3 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataXz3 = '';

  bool isDataUploading_uploadDataXz33 = false;
  FFUploadedFile uploadedLocalFile_uploadDataXz33 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataXz33 = '';

  bool isDataUploading_uploadDataXz2 = false;
  FFUploadedFile uploadedLocalFile_uploadDataXz2 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataXz2 = '';

  bool isDataUploading_uploadDataXz22 = false;
  FFUploadedFile uploadedLocalFile_uploadDataXz22 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataXz22 = '';

  // State field(s) for DropDown widget.
  List<String>? dropDownValue1;
  FormFieldController<List<String>>? dropDownValueController1;
  // State field(s) for DropDown widget.
  String? dropDownValue2;
  FormFieldController<String>? dropDownValueController2;

  /// Contenido en creación (sin guardar) que muestra la vista previa.
  ContenidoRecord? previa;

  /// Deja el formulario vacío para un contenido nuevo. El modelo vive en
  /// [AdminContenido2Model] y se reutiliza: sin esto, el siguiente "Crear
  /// Contenido" salía con los datos del anterior y al publicar lo duplicaba.
  /// Llamar solo con el formulario cerrado.
  void reiniciar() {
    imgperfil = null;
    imgportada = null;
    tituloTextController?.dispose();
    tituloTextController = null;
    isDataUploading_uploadDataXz3 = false;
    uploadedLocalFile_uploadDataXz3 =
        FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
    uploadedFileUrl_uploadDataXz3 = '';
    isDataUploading_uploadDataXz33 = false;
    uploadedLocalFile_uploadDataXz33 =
        FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
    uploadedFileUrl_uploadDataXz33 = '';
    isDataUploading_uploadDataXz2 = false;
    uploadedLocalFile_uploadDataXz2 =
        FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
    uploadedFileUrl_uploadDataXz2 = '';
    isDataUploading_uploadDataXz22 = false;
    uploadedLocalFile_uploadDataXz22 =
        FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
    uploadedFileUrl_uploadDataXz22 = '';
    dropDownValue1 = null;
    dropDownValueController1 = null;
    dropDownValue2 = null;
    dropDownValueController2 = null;
    previa = null;
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tituloFocusNode?.dispose();
    tituloTextController?.dispose();
  }
}
