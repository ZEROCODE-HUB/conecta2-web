import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_search/text_search.dart';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '../admin_contenido_model.dart';

/// Search text field + filter dropdowns row.
class ContenidoFilters extends StatelessWidget {
  const ContenidoFilters({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final AdminContenido2Model model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SizedBox(
              width: screenWidth * 0.333,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(child: _buildSearchField(context, theme)),
                  if (!model.isShowFullList)
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
                      onPressed: () {
                        model.isShowFullList = true;
                        model.searchTextController?.clear();
                        onChanged();
                      },
                    ),
                ],
              ),
            ),
          ),
          Flexible(
            child: _buildPublicadoFilter(context, theme, screenWidth),
          ),
          Flexible(
            child: _buildRolesFilter(context, theme, screenWidth),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, FlutterFlowTheme theme) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.2,
      child: TextFormField(
        controller: model.searchTextController,
        focusNode: model.searchFocusNode,
        onChanged: (_) => EasyDebounce.debounce(
          '_model.searchTextController',
          const Duration(milliseconds: 2000),
          () async {
            try {
              final records = await queryContenidoRecordOnce();
              model.simpleSearchResults = TextSearch(
                records
                    .map((r) => TextSearchItem.fromTerms(r, [r.titulo]))
                    .toList(),
              )
                  .search(model.searchTextController!.text)
                  .map((r) => r.object)
                  .toList();
            } catch (_) {
              model.simpleSearchResults = [];
            }
            model.isShowFullList = false;
            onChanged();
          },
        ),
        autofocus: false,
        obscureText: false,
        decoration: InputDecoration(
          isDense: true,
          labelStyle: theme.labelMedium.override(
            font: GoogleFonts.inter(
              fontWeight: theme.labelMedium.fontWeight,
              fontStyle: theme.labelMedium.fontStyle,
            ),
            color: theme.accent3,
            letterSpacing: 0.0,
            fontWeight: theme.labelMedium.fontWeight,
            fontStyle: theme.labelMedium.fontStyle,
          ),
          hintText: 'Buscar Contenido',
          hintStyle: theme.bodyLarge.override(
            font: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontStyle: theme.bodyLarge.fontStyle,
            ),
            color: theme.accent3,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w500,
            fontStyle: theme.bodyLarge.fontStyle,
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
              color: theme.primary,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: theme.web2,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(
              24.0, 16.0, 24.0, 16.0),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF265294),
            size: 35.0,
          ),
        ),
        style: theme.bodyMedium.override(
          font: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontStyle: theme.bodyMedium.fontStyle,
          ),
          fontSize: 16.0,
          letterSpacing: 0.0,
          fontWeight: FontWeight.w500,
          fontStyle: theme.bodyMedium.fontStyle,
        ),
        validator: model.searchTextControllerValidator.asValidator(context),
      ),
    );
  }

  Widget _buildPublicadoFilter(
      BuildContext context, FlutterFlowTheme theme, double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.333,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
            child: Text(
              'Filtrar por',
              style: theme.bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontStyle: theme.bodyMedium.fontStyle,
                ),
                fontSize: 18.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                fontStyle: theme.bodyMedium.fontStyle,
              ),
            ),
          ),
          Flexible(
            child: FlutterFlowDropDown<bool>(
              controller: model.dropDownValueController1 ??=
                  FormFieldController<bool>(null),
              options: const [true, false],
              optionLabels: const ['PUBLICADO', 'BORRADOR'],
              onChanged: (val) {
                model.dropDownValue1 = val;
                onChanged();
              },
              width: screenWidth * 0.2,
              height: 47.0,
              textStyle: theme.bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontStyle: theme.bodyMedium.fontStyle,
                ),
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                fontStyle: theme.bodyMedium.fontStyle,
              ),
              hintText: 'Please select...',
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF265294),
                size: 24.0,
              ),
              fillColor: theme.secondaryBackground,
              elevation: 2.0,
              borderColor: theme.alternate,
              borderWidth: 2.0,
              borderRadius: 8.0,
              margin: const EdgeInsetsDirectional.fromSTEB(
                  16.0, 4.0, 16.0, 4.0),
              hidesUnderline: true,
              isOverButton: false,
              isSearchable: false,
              isMultiSelect: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesFilter(
      BuildContext context, FlutterFlowTheme theme, double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.333,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
            child: Text(
              'Dirigido para',
              style: theme.bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontStyle: theme.bodyMedium.fontStyle,
                ),
                fontSize: 18.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                fontStyle: theme.bodyMedium.fontStyle,
              ),
            ),
          ),
          Flexible(
            child: FlutterFlowDropDown<String>(
              multiSelectController: model.dropDownValueController2 ??=
                  FormListFieldController<String>(null),
              options: const ['', 'Adolescente', 'Acudiente', 'Profesional'],
              optionLabels: const [
                'All',
                'Adolescente',
                'Acudiente',
                'Profesional',
              ],
              width: screenWidth * 0.2,
              height: 47.0,
              textStyle: theme.bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontStyle: theme.bodyMedium.fontStyle,
                ),
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                fontStyle: theme.bodyMedium.fontStyle,
              ),
              hintText: 'Please select...',
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF265294),
                size: 24.0,
              ),
              fillColor: theme.secondaryBackground,
              elevation: 2.0,
              borderColor: theme.alternate,
              borderWidth: 2.0,
              borderRadius: 8.0,
              margin: const EdgeInsetsDirectional.fromSTEB(
                  16.0, 4.0, 16.0, 4.0),
              hidesUnderline: true,
              isOverButton: false,
              isSearchable: false,
              isMultiSelect: true,
              onMultiSelectChanged: (val) {
                model.dropDownValue2 = val;
                onChanged();
              },
            ),
          ),
        ],
      ),
    );
  }
}
