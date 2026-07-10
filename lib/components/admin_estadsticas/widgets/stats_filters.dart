import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../admin_estadsticas2_model.dart';

/// Dropdown + button toolbar for the Estadisticas screen.
/// Exposes current filter selections through the shared [model].
class StatsFilters extends StatelessWidget {
  const StatsFilters({super.key, required this.model, required this.onChanged});

  final AdminEstadsticas2Model model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _tamizajeDropdown(context),
        _nivelDropdown(context),
        _sustanciaDropdown(context),
        _pdfButton(context),
      ].divide(const SizedBox(width: 8.0)),
    );
  }

  Widget _tamizajeDropdown(BuildContext context) {
    return StreamBuilder<List<EncuestasRecord>>(
      stream: queryEncuestasRecord(
        queryBuilder: (q) => q.where('tipo', isEqualTo: 'Tamizajes'),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _loader(context);
        final list = snapshot.data!;
        return FlutterFlowDropDown<String>(
          controller: model.dropDownTamizajValueController ??=
              FormFieldController<String>(
            model.dropDownTamizajValue ??= model.filtroTamizaje,
          ),
          options: list.map((e) => e.titulo).toList(),
          optionLabels: const <String>[],
          onChanged: (val) {
            model.dropDownTamizajValue = val;
            model.filtroTamizaje = val ?? '';
            onChanged();
          },
          width: 320.0,
          height: 40.0,
          textStyle: _dropdownTextStyle(context),
          hintText: 'Seleccione tamizaje',
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 24.0,
          ),
          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          elevation: 2.0,
          borderColor: Colors.transparent,
          borderWidth: 0.0,
          borderRadius: 8.0,
          margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
          hidesUnderline: true,
          isOverButton: false,
          isSearchable: false,
          isMultiSelect: false,
        );
      },
    );
  }

  Widget _nivelDropdown(BuildContext context) {
    return FlutterFlowDropDown<String>(
      controller: model.dropDownNivelValueController ??=
          FormFieldController<String>(model.dropDownNivelValue ??= 'Todos'),
      options: const ['Bajo', 'Moderado', 'Alto', 'Todos'],
      onChanged: (val) {
        model.dropDownNivelValue = val;
        onChanged();
      },
      width: 200.0,
      height: 40.0,
      textStyle: _dropdownTextStyle(context),
      hintText: 'Secione nivel de riesgo',
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: FlutterFlowTheme.of(context).secondaryText,
        size: 24.0,
      ),
      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
      elevation: 2.0,
      borderColor: Colors.transparent,
      borderWidth: 0.0,
      borderRadius: 8.0,
      margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
      hidesUnderline: true,
      isOverButton: false,
      isSearchable: false,
      isMultiSelect: false,
    );
  }

  Widget _sustanciaDropdown(BuildContext context) {
    return FlutterFlowDropDown<String>(
      controller: model.dropDownSustanciaValueController ??=
          FormFieldController<String>(model.dropDownSustanciaValue ??= 'Todos'),
      options: const [
        'Tabaco',
        'Bebidas alcohólicas',
        'Cannabis',
        'Anfetaminas',
        'Inhalantes',
        'Tranquilizantes',
        'Alucinógenos',
        'Opiáceos',
        'Otros',
        'Todos',
      ],
      onChanged: (val) {
        model.dropDownSustanciaValue = val;
        onChanged();
      },
      width: 200.0,
      height: 40.0,
      textStyle: _dropdownTextStyle(context),
      hintText: 'Sustancia',
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: FlutterFlowTheme.of(context).secondaryText,
        size: 24.0,
      ),
      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
      elevation: 2.0,
      borderColor: Colors.transparent,
      borderWidth: 0.0,
      borderRadius: 8.0,
      margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
      hidesUnderline: true,
      isOverButton: false,
      isSearchable: false,
      isMultiSelect: false,
    );
  }

  Widget _pdfButton(BuildContext context) {
    return FFButtonWidget(
      onPressed: () async {
        await actions.generarReportePDFTamizajeGeneral(
          model.textFieldColegioValue,
          model.dropDownNivelValue,
          model.dropDownSustanciaValue,
          model.dropDownTamizajValue,
        );
      },
      text: 'Generar pdf',
      options: FFButtonOptions(
        height: 40.0,
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        color: FlutterFlowTheme.of(context).secondary,
        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              font: GoogleFonts.inter(
                fontWeight:
                    FlutterFlowTheme.of(context).titleSmall.fontWeight,
                fontStyle:
                    FlutterFlowTheme.of(context).titleSmall.fontStyle,
              ),
              color: Colors.white,
              fontSize: 14.0,
              letterSpacing: 0.0,
            ),
        elevation: 0.0,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  TextStyle _dropdownTextStyle(BuildContext context) {
    final bodyMedium = FlutterFlowTheme.of(context).bodyMedium;
    return bodyMedium.override(
      font: GoogleFonts.inter(
        fontWeight: bodyMedium.fontWeight,
        fontStyle: bodyMedium.fontStyle,
      ),
      letterSpacing: 0.0,
    );
  }

  Widget _loader(BuildContext context) {
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
}
