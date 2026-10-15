import '/backend/backend.dart';
import '/components/footer/footer_widget.dart';
import '/components/header/header_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'encuestas_and_tamizajes_widget.dart' show EncuestasAndTamizajesWidget;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class EncuestasAndTamizajesModel
    extends FlutterFlowModel<EncuestasAndTamizajesWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];
  // State field(s) for SurveyLists1 widget.

  PagingController<DocumentSnapshot?, EncuestasRecord>?
      surveyLists1PagingController;
  Query? surveyLists1PagingQuery;
  List<StreamSubscription?> surveyLists1StreamSubscriptions = [];

  // Stores action output result for [Firestore Query - Query a collection] action in Container widget.
  RespuestasRecord? exist2;
  // Model for header component.
  late HeaderModel headerModel;
  // Model for footer component.
  late FooterModel footerModel;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    footerModel = createModel(context, () => FooterModel());
  }

  @override
  void dispose() {
    surveyLists1StreamSubscriptions.forEach((s) => s?.cancel());
    surveyLists1PagingController?.dispose();

    headerModel.dispose();
    footerModel.dispose();
  }

  /// Additional helper methods.
  PagingController<DocumentSnapshot?, EncuestasRecord>
      setSurveyLists1Controller(
    Query query, {
    DocumentReference<Object?>? parent,
  }) {
    surveyLists1PagingController ??=
        _createSurveyLists1Controller(query, parent);
    if (surveyLists1PagingQuery != query) {
      surveyLists1PagingQuery = query;
      surveyLists1PagingController?.refresh();
    }
    return surveyLists1PagingController!;
  }

  PagingController<DocumentSnapshot?, EncuestasRecord>
      _createSurveyLists1Controller(
    Query query,
    DocumentReference<Object?>? parent,
  ) {
    final controller = PagingController<DocumentSnapshot?, EncuestasRecord>(
        firstPageKey: null);
    return controller
      ..addPageRequestListener(
        (nextPageMarker) => queryEncuestasRecordPage(
          queryBuilder: (_) => surveyLists1PagingQuery ??= query,
          nextPageMarker: nextPageMarker,
          streamSubscriptions: surveyLists1StreamSubscriptions,
          controller: controller,
          pageSize: 5,
          isStream: true,
        ),
      );
  }
}
