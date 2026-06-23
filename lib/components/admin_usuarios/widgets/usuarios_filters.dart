import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_search/text_search.dart';

/// Title row with "Usuarios", current user badge and "Crear nuevo" button.
class UsuariosTitleBar extends StatelessWidget {
  const UsuariosTitleBar({
    super.key,
    required this.onCrearNuevo,
  });

  final VoidCallback onCrearNuevo;

  static const _defaultAvatar =
      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/conecta2-wtnr9n/assets/9yllj3p8hz5o/User.png';

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              'Usuarios',
              style: theme.titleLarge.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Padding(
              //   padding:
              //       const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
              //   child: OutlinedButton.icon(
              //     onPressed: () async {
              //       await actions.generarPDFPrueba();
              //     },
              //     icon: const Icon(
              //       Icons.picture_as_pdf,
              //       color: Color(0xFF265294),
              //       size: 20.0,
              //     ),
              //     label: Text(
              //       'PDF de prueba',
              //       style: theme.bodyMedium.override(
              //         font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              //         color: const Color(0xFF265294),
              //         fontSize: 14.0,
              //         letterSpacing: 0.5,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //     style: OutlinedButton.styleFrom(
              //       side: const BorderSide(
              //           color: Color(0xFF265294), width: 1.5),
              //       padding: const EdgeInsets.symmetric(
              //           horizontal: 20, vertical: 18),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(20.0),
              //       ),
              //     ),
              //   ),
              // ),
              if (valueOrDefault(currentUserDocument?.rol, '') ==
                  'Administrador')
                AuthUserStreamWidget(
                  builder: (context) => FFButtonWidget(
                    onPressed: onCrearNuevo,
                    text: 'Crear nuevo',
                    options: FFButtonOptions(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          60.0, 20.0, 60.0, 20.0),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: theme.secondary,
                      textStyle: theme.bodyMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        color: const Color(0xFF265294),
                        fontSize: 18.0,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              const SizedBox(width: 25.0),
              Container(
                height: 43.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 10.0, 0.0),
                        child: AuthUserStreamWidget(
                          builder: (context) => ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Image.network(
                              valueOrDefault<String>(
                                currentUserPhoto,
                                _defaultAvatar,
                              ),
                              width: 30.0,
                              height: 30.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 30.0,
                                height: 30.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey[400],
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      AuthUserStreamWidget(
                        builder: (context) => Text(
                          currentUserDisplayName,
                          style: theme.bodyMedium.override(
                            font:
                                GoogleFonts.inter(fontWeight: FontWeight.w600),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Search field + "Filtrar por" dropdown.
class UsuariosFilters extends StatelessWidget {
  const UsuariosFilters({
    super.key,
    required this.textController,
    required this.textFieldFocusNode,
    required this.textControllerValidator,
    required this.dropDownValue,
    required this.dropDownValueController,
    required this.isShowFullList,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onDropDownChanged,
  });

  final TextEditingController? textController;
  final FocusNode? textFieldFocusNode;
  final String? Function(BuildContext, String?)? textControllerValidator;
  final String? dropDownValue;
  final FormFieldController<String>? dropDownValueController;
  final bool isShowFullList;

  /// Called with the fresh [simpleSearchResults] list computed by TextSearch.
  final void Function(List<UsersRecord> results) onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String?> onDropDownChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              decoration: const BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: 300.0,
                    child: TextFormField(
                      controller: textController,
                      focusNode: textFieldFocusNode,
                      onChanged: (_) => EasyDebounce.debounce(
                        '_model.textController',
                        const Duration(milliseconds: 100),
                        () async {
                          List<UsersRecord> results = const [];
                          try {
                            final records = await queryUsersRecordOnce();
                            results = TextSearch(
                              records
                                  .map((r) => TextSearchItem.fromTerms(
                                      r, [r.displayName]))
                                  .toList(),
                            )
                                .search(textController?.text ?? '')
                                .map((r) => r.object)
                                .toList();
                          } catch (_) {
                            results = const [];
                          }
                          onSearchChanged(results);
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
                        ),
                        hintText: 'Buscar usuarios',
                        hintStyle: theme.bodyLarge.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                          color: theme.accent3,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(0x00000000), width: 2.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: theme.primary, width: 2.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: theme.error, width: 2.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: theme.error, width: 2.0),
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
                        font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                      ),
                      validator: textControllerValidator.asValidator(context),
                    ),
                  ),
                  if (!isShowFullList)
                    FlutterFlowIconButton(
                      borderRadius: 20.0,
                      borderWidth: 1.0,
                      buttonSize: 40.0,
                      icon: const Icon(
                        Icons.clear,
                        color: Color(0xFF265294),
                        size: 24.0,
                      ),
                      onPressed: onClearSearch,
                    ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
                child: Text(
                  'Filtrar por',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              FlutterFlowDropDown<String>(
                controller: dropDownValueController,
                options: List<String>.from(const [
                  '',
                  'Adolescente',
                  'Acudiente',
                  'Profesional',
                ]),
                optionLabels: const [
                  'All',
                  'Adolescente',
                  'Acudiente',
                  'Profesional',
                ],
                onChanged: onDropDownChanged,
                width: 255.0,
                height: 47.0,
                textStyle: theme.bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
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
                margin:
                    const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                hidesUnderline: true,
                isOverButton: false,
                isSearchable: false,
                isMultiSelect: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
