import '/components/header_prof_back/header_prof_back_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'edit_profile_proff_widget.dart' show EditProfileProffWidget;
import 'package:flutter/material.dart';

class EditProfileProffModel extends FlutterFlowModel<EditProfileProffWidget> {
  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadDataB3e = false;
  FFUploadedFile uploadedLocalFile_uploadDataB3e =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataB3e = '';

  // State field(s) for TextFieldname widget.
  FocusNode? textFieldnameFocusNode;
  TextEditingController? textFieldnameTextController;
  String? Function(BuildContext, String?)? textFieldnameTextControllerValidator;
  // State field(s) for TextFieldemail widget.
  FocusNode? textFieldemailFocusNode;
  TextEditingController? textFieldemailTextController;
  String? Function(BuildContext, String?)?
      textFieldemailTextControllerValidator;
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
  // Model for HeaderProfBack component.
  late HeaderProfBackModel headerProfBackModel;

  @override
  void initState(BuildContext context) {
    headerProfBackModel = createModel(context, () => HeaderProfBackModel());
  }

  @override
  void dispose() {
    textFieldnameFocusNode?.dispose();
    textFieldnameTextController?.dispose();

    textFieldemailFocusNode?.dispose();
    textFieldemailTextController?.dispose();

    textFieldphoneFocusNode?.dispose();
    textFieldphoneTextController?.dispose();

    textFielddniFocusNode?.dispose();
    textFielddniTextController?.dispose();

    textFieldaddressFocusNode?.dispose();
    textFieldaddressTextController?.dispose();

    headerProfBackModel.dispose();
  }
}
