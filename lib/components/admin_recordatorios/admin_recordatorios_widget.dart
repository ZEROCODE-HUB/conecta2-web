import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:text_search/text_search.dart';
import 'admin_recordatorios_model.dart';
import 'widgets/recordatorio_card.dart';
import 'widgets/recordatorio_filters.dart';
import 'widgets/recordatorio_form.dart';

export 'admin_recordatorios_model.dart';

/// Admin panel for browsing, creating, editing and deleting recordatorios.
///
/// The widget is split into three responsibilities:
///  * [RecordatoriosHeader] / [RecordatoriosSearchBar] (header + filters)
///  * [RecordatorioCard] (list rendering + 3-dot actions menu)
///  * [RecordatorioForm] (create / edit form)
///
/// State continues to live on [AdminRecordatoriosModel] to stay compatible
/// with the generated FlutterFlow model plumbing used elsewhere.
class AdminRecordatoriosWidget extends StatefulWidget {
  const AdminRecordatoriosWidget({super.key});

  @override
  State<AdminRecordatoriosWidget> createState() =>
      _AdminRecordatoriosWidgetState();
}

class _AdminRecordatoriosWidgetState extends State<AdminRecordatoriosWidget> {
  late AdminRecordatoriosModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminRecordatoriosModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.isShowFullList = true;
      safeSetState(() {});
    });

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.text1TextController ??= TextEditingController();
    _model.text1FocusNode ??= FocusNode();

    _model.text2TextController ??= TextEditingController();
    _model.text2FocusNode ??= FocusNode();

    _model.textFieldFocusNode2 ??= FocusNode();
    _model.textFieldFocusNode3 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  bool get _hasSidePanel => _model.view != null && _model.view != '';

  Future<void> _runSearch(String _) async {
    EasyDebounce.debounce(
      '_model.textController1',
      const Duration(milliseconds: 100),
      () async {
        await queryRecordatorRecordOnce()
            .then(
              (records) => _model.simpleSearchResults = TextSearch(
                records
                    .map((record) => TextSearchItem.fromTerms(
                          record,
                          [record.titulo, record.descripcion],
                        ))
                    .toList(),
              )
                  .search(_model.textController1.text)
                  .map((r) => r.object)
                  .toList(),
            )
            .onError((_, __) => _model.simpleSearchResults = [])
            .whenComplete(() => safeSetState(() {}));

        _model.isShowFullList = false;
        safeSetState(() {});
      },
    );
  }

  void _clearSearch() {
    _model.isShowFullList = true;
    safeSetState(() {
      _model.textController1?.clear();
    });
  }

  void _onCardEdit(DocumentReference ref) {
    _model.view = 'Editar';
    _model.recordID = ref;
    // Reset edit-form controllers so they re-initialise from the new record.
    _model.textController4 = null;
    _model.textController5 = null;
    safeSetState(() {});
  }

  void _onCardDeleted() {
    _model.view = '';
    safeSetState(() {});
  }

  Future<void> _saveNewRecordatorio() async {
    await RecordatorRecord.collection.doc().set(createRecordatorRecordData(
          titulo: _model.text1TextController.text,
          descripcion: _model.text2TextController.text,
          createAt: getCurrentTimestamp,
        ));
    safeSetState(() {
      _model.text1TextController?.clear();
      _model.text2TextController?.clear();
    });
    _model.view = '';
    safeSetState(() {});
  }

  Future<void> _saveEditedRecordatorio() async {
    final ref = _model.recordID;
    if (ref == null) return;
    await ref.update(createRecordatorRecordData(
      titulo: _model.textController4?.text,
      descripcion: _model.textController5?.text,
    ));
    _model.view = '';
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Stack(
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: MediaQuery.sizeOf(context).height * 1.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
          ),
          child: Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(50.0, 0.0, 50.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RecordatoriosHeader(
                  onCreatePressed: () {
                    _model.view = 'create';
                    safeSetState(() {});
                  },
                ),
                RecordatoriosSearchBar(
                  controller: _model.textController1!,
                  focusNode: _model.textFieldFocusNode1!,
                  validator: _model.textController1Validator,
                  onChanged: _runSearch,
                  showClearButton: _model.isShowFullList == false,
                  onClear: _clearSearch,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 30.0, 0.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildList()),
                        if (_hasSidePanel)
                          Expanded(child: _buildSidePanel()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    if (_model.textController1.text.isNotEmpty) {
      final list = _model.simpleSearchResults.toList();
      return SingleChildScrollView(
        child: Wrap(
          spacing: 0.0,
          runSpacing: 0.0,
          alignment: WrapAlignment.start,
          children: [
            for (final item in list)
              RecordatorioCard(
                record: item,
                compact: _hasSidePanel,
                onEdit: () => _onCardEdit(item.reference),
                onDeleted: _onCardDeleted,
              ),
          ],
        ),
      );
    }

    return StreamBuilder<List<RecordatorRecord>>(
      stream: queryRecordatorRecord(
        queryBuilder: (recordatorRecord) =>
            recordatorRecord.orderBy('CreateAt', descending: true),
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
        final records = snapshot.data!;
        return SingleChildScrollView(
          child: Wrap(
            spacing: 0.0,
            runSpacing: 0.0,
            alignment: WrapAlignment.start,
            children: [
              for (final item in records)
                RecordatorioCard(
                  record: item,
                  compact: _hasSidePanel,
                  onEdit: () => _onCardEdit(item.reference),
                  onDeleted: _onCardDeleted,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidePanel() {
    if (_model.view == 'create') {
      return RecordatorioForm(
        title: 'Crear Recordatorio',
        titleController: _model.text1TextController!,
        titleFocusNode: _model.text1FocusNode!,
        titleValidator: _model.text1TextControllerValidator,
        descriptionController: _model.text2TextController!,
        descriptionFocusNode: _model.text2FocusNode!,
        descriptionValidator: _model.text2TextControllerValidator,
        onSave: _saveNewRecordatorio,
      );
    }

    if (_model.view == 'Editar' && _model.recordID != null) {
      return StreamBuilder<RecordatorRecord>(
        stream: RecordatorRecord.getDocument(_model.recordID!),
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

          final record = snapshot.data!;
          _model.textController4 ??=
              TextEditingController(text: record.titulo);
          _model.textController5 ??=
              TextEditingController(text: record.descripcion);

          return RecordatorioForm(
            title: 'Editar Recordatorio',
            titleController: _model.textController4!,
            titleFocusNode: _model.textFieldFocusNode2!,
            titleValidator: _model.textController4Validator,
            descriptionController: _model.textController5!,
            descriptionFocusNode: _model.textFieldFocusNode3!,
            descriptionValidator: _model.textController5Validator,
            onSave: _saveEditedRecordatorio,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
