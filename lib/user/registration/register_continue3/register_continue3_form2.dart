part of 'register_continue3_widget.dart';

extension _RegisterContinue3Form2 on _RegisterContinue3WidgetState {
  List<Widget> buildFormChildren2(BuildContext context) {
    return [
    Container(
      decoration: BoxDecoration(),
    ),
    Container(
      decoration: BoxDecoration(),
    ),
    Container(
      decoration: BoxDecoration(),
    ),
    Container(
      decoration: BoxDecoration(),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
            0.0, 20.0, 0.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Teléfono',
              style: FlutterFlowTheme.of(context)
                  .labelSmall
                  .override(
                    font: GoogleFonts.outfit(
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(
                                  context)
                              .labelSmall
                              .fontStyle,
                    ),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    fontStyle:
                        FlutterFlowTheme.of(context)
                            .labelSmall
                            .fontStyle,
                  ),
            ),
            Container(
              constraints: const BoxConstraints(minHeight: 47.0),
              decoration: BoxDecoration(),
              child: TextFormField(
                controller: _model
                    .textFieldTelefonoParentescoTextController,
                focusNode: _model
                    .textFieldTelefonoParentescoFocusNode,
                autofocus: false,
                obscureText: false,
                decoration: InputDecoration(
                  alignLabelWithHint: false,
                  hintText: 'Teléfono del acudiente',
                  hintStyle: FlutterFlowTheme.of(
                          context)
                      .bodyMedium
                      .override(
                        font: GoogleFonts.outfit(
                          fontWeight:
                              FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(
                                      context)
                                  .bodyMedium
                                  .fontStyle,
                        ),
                        color: FlutterFlowTheme.of(
                                context)
                            .accent3,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(
                                    context)
                                .bodyMedium
                                .fontStyle,
                      ),
                  enabledBorder:
                      UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x00000000),
                      width: 1.0,
                    ),
                    borderRadius:
                        BorderRadius.circular(8.0),
                  ),
                  focusedBorder:
                      UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x00000000),
                      width: 1.0,
                    ),
                    borderRadius:
                        BorderRadius.circular(8.0),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(
                              context)
                          .error,
                      width: 1.0,
                    ),
                    borderRadius:
                        BorderRadius.circular(8.0),
                  ),
                  focusedErrorBorder:
                      UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(
                              context)
                          .error,
                      width: 1.0,
                    ),
                    borderRadius:
                        BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor:
                      FlutterFlowTheme.of(context)
                          .secondaryBackground,
                ),
                style: FlutterFlowTheme.of(context)
                    .bodyMedium
                    .override(
                      font: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(
                                    context)
                                .bodyMedium
                                .fontStyle,
                      ),
                      color: Color(0xFF1F2129),
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(
                                  context)
                              .bodyMedium
                              .fontStyle,
                    ),
                textAlign: TextAlign.start,
                keyboardType: TextInputType.phone,
                validator: _model
                    .textFieldTelefonoParentescoTextControllerValidator
                    .asValidator(context),
              ),
            ),
          ].divide(SizedBox(height: 10.0)),
        ),
      ),
    ),
    ];
  }
}
