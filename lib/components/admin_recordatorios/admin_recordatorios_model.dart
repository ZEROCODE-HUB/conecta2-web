import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'admin_recordatorios_widget.dart' show AdminRecordatoriosWidget;
import 'package:flutter/material.dart';

class AdminRecordatoriosModel
    extends FlutterFlowModel<AdminRecordatoriosWidget> {
  ///  Local state fields for this component.

  /// Current right-panel view: '' (none), 'create', or 'Editar'.
  String? view = '';

  /// The record being edited (null when creating or when no panel is open).
  DocumentReference? recordID;

  ///  State fields for stateful widgets in this component.

  // Search field.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  List<RecordatorRecord> simpleSearchResults = [];
  bool isShowFullList = true;

  // Create-form title.
  FocusNode? text1FocusNode;
  TextEditingController? text1TextController;
  String? Function(BuildContext, String?)? text1TextControllerValidator;

  // Create-form description.
  FocusNode? text2FocusNode;
  TextEditingController? text2TextController;
  String? Function(BuildContext, String?)? text2TextControllerValidator;

  // Edit-form title.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;

  // Edit-form description.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController5;
  String? Function(BuildContext, String?)? textController5Validator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    text1FocusNode?.dispose();
    text1TextController?.dispose();

    text2FocusNode?.dispose();
    text2TextController?.dispose();

    textFieldFocusNode2?.dispose();
    textController4?.dispose();

    textFieldFocusNode3?.dispose();
    textController5?.dispose();
  }
}
