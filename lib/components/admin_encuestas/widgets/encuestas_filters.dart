import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '../admin_encuestas_model.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_search/text_search.dart';

/// Filters bar: search field + publicado/borrador dropdown + dirigido-para dropdown.
class EncuestasFilters extends StatelessWidget {
  const EncuestasFilters({
    super.key,
    required this.model,
    required this.onStateChanged,
  });

  final AdminEncuestasModel model;
  final VoidCallback onStateChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _buildSearch(context)),
          const SizedBox(width: 16),
          Expanded(child: _buildPublicadoDropdown(context)),
          const SizedBox(width: 16),
          Expanded(child: _buildRolDropdown(context)),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: TextFormField(
            controller: model.searchTextController,
            focusNode: model.searchFocusNode,
            onChanged: (_) => EasyDebounce.debounce(
              '_model.searchTextController',
              const Duration(milliseconds: 2000),
              () async {
                await queryEncuestasRecordOnce()
                    .then(
                      (records) => model.simpleSearchResults = TextSearch(
                        records
                            .map((record) => TextSearchItem.fromTerms(
                                record, [record.titulo]))
                            .toList(),
                      )
                          .search(model.searchTextController!.text)
                          .map((r) => r.object)
                          .toList(),
                    )
                    .onError((_, __) => model.simpleSearchResults = [])
                    .whenComplete(onStateChanged);

                model.isShowFullList = false;
                onStateChanged();
              },
            ),
            autofocus: false,
            obscureText: false,
            decoration: InputDecoration(
              isDense: true,
              labelStyle:
                  FlutterFlowTheme.of(context).labelMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .labelMedium
                              .fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).accent3,
                        letterSpacing: 0.0,
                      ),
              hintText: 'Buscar',
              hintStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    color: FlutterFlowTheme.of(context).accent3,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                  ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0x00000000),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).error,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).error,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: FlutterFlowTheme.of(context).web2,
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                  24.0, 16.0, 24.0, 16.0),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF265294),
                size: 35.0,
              ),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
            validator: model.searchTextControllerValidator?.asValidator(context),
          ),
        ),
        if (model.isShowFullList == false)
          FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 20.0,
            borderWidth: 1.0,
            buttonSize: 40.0,
            icon: const Icon(
              Icons.clear,
              color: Color(0xFF265294),
              size: 24.0,
            ),
            onPressed: () async {
              model.isShowFullList = true;
              model.searchTextController?.clear();
              onStateChanged();
            },
          ),
      ],
    );
  }

  Widget _buildPublicadoDropdown(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
          child: Text(
            'Filtrar por',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: FlutterFlowDropDown<bool>(
            controller: model.dropDownValueController1 ??=
                FormFieldController<bool>(null),
            options: const [true, false],
            optionLabels: const ['PUBLICADO', 'BORRADOR'],
            onChanged: (val) {
              model.dropDownValue1 = val;
              onStateChanged();
            },
            width: 255.0,
            height: 47.0,
            textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
            hintText: 'Seleccione',
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF265294),
              size: 24.0,
            ),
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            elevation: 2.0,
            borderColor: FlutterFlowTheme.of(context).alternate,
            borderWidth: 2.0,
            borderRadius: 8.0,
            margin:
                const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
            hidesUnderline: true,
            isOverButton: false,
            isSearchable: false,
            isMultiSelect: false,
          ),
        ),
      ],
    );
  }

  Widget _buildRolDropdown(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
          child: Text(
            'Dirigido para',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: FlutterFlowDropDown<String>(
            controller: model.dropDownValueController2 ??=
                FormFieldController<String>(model.dropDownValue2 ??= ''),
            options: const ['', 'Adolescente', 'Acudiente', 'Profesional'],
            optionLabels: const [
              'Todos',
              'Adolescente',
              'Acudiente',
              'Profesional'
            ],
            onChanged: (val) {
              model.dropDownValue2 = val;
              onStateChanged();
            },
            width: 255.0,
            height: 47.0,
            textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
            hintText: 'Selecciona...',
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF265294),
              size: 24.0,
            ),
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            elevation: 2.0,
            borderColor: FlutterFlowTheme.of(context).alternate,
            borderWidth: 2.0,
            borderRadius: 8.0,
            margin:
                const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
            hidesUnderline: true,
            isOverButton: false,
            isSearchable: false,
            isMultiSelect: false,
          ),
        ),
      ],
    );
  }
}
