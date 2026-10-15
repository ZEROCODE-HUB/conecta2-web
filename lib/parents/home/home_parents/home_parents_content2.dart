part of 'home_parents_widget.dart';

extension _HomeParentsContent2 on _HomeParentsWidgetState {
  List<Widget> buildMainContentPart2(BuildContext context) {
    return [
    Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          0.0, 20.0, 0.0, 0.0),
      child: Text(
        'Mis Adolescentes',
        style: FlutterFlowTheme.of(context)
            .bodyMedium
            .override(
              font: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontStyle:
                    FlutterFlowTheme.of(context)
                        .bodyMedium
                        .fontStyle,
              ),
              fontSize: 16.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
              fontStyle:
                  FlutterFlowTheme.of(context)
                      .bodyMedium
                      .fontStyle,
            ),
      ),
    ),
    Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          0.0, 10.0, 0.0, 0.0),
      child: AuthUserStreamWidget(
        builder: (context) => StreamBuilder<List<UsersRecord>>(
          stream: queryUsersRecord(
            queryBuilder: (usersRecord) => usersRecord
                // Correo de acceso (Auth), no el editable del perfil: así nadie
                // puede ver adolescentes ajenos cambiando su correo.
                .where('Acudiente.correo', isEqualTo: correoDeAcceso),
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
            final adolescentes = snapshot.data!;
            if (adolescentes.isEmpty) {
              return Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                child: Text(
                  'No hay adolescentes vinculados.',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: adolescentes.map((adolescente) {
                return Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                        ),
                        context: context,
                        builder: (bottomSheetContext) {
                          return Container(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  adolescente.displayName,
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                _buildDetailRow(context, 'Correo', adolescente.email),
                                _buildDetailRow(context, 'Colegio', adolescente.colegio),
                                _buildDetailRow(context, 'Grado', adolescente.grado),
                                _buildDetailRow(context, 'Municipio', adolescente.municipio),
                                SizedBox(height: 12.0),
                                Text(
                                  'Profesional asignado',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                if (adolescente.profesionales.hasRef() ||
                                    adolescente.profesionales.hasNombre())
                                  StreamBuilder<UsersRecord>(
                                    stream: adolescente.profesionales.hasRef()
                                        ? UsersRecord.getDocument(
                                            adolescente.profesionales.ref!)
                                        : null,
                                    builder: (context, profSnapshot) {
                                      final prof = profSnapshot.data;
                                      final nombre = prof?.displayName.isNotEmpty == true
                                          ? prof!.displayName
                                          : adolescente.profesionales.nombre;
                                      final correo = prof?.email ?? '';
                                      final telefono = prof?.phoneNumber ?? '';
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailRow(context, 'Nombre', nombre),
                                          if (correo.isNotEmpty)
                                            _buildDetailRow(context, 'Correo', correo),
                                          if (telefono.isNotEmpty)
                                            _buildDetailRow(context, 'Teléfono', telefono),
                                        ],
                                      );
                                    },
                                  )
                                else
                                  Text(
                                    'Sin profesional asignado',
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                  ),
                                SizedBox(height: 20.0),
                                InkWell(
                                  onTap: () => Navigator.pop(bottomSheetContext),
                                  child: Container(
                                    width: double.infinity,
                                    height: 44.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF265294),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Cerrar',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.0),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 44.0,
                              height: 44.0,
                              decoration: BoxDecoration(
                                color: Color(0xFF265294),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  adolescente.displayName.isNotEmpty
                                      ? adolescente.displayName[0].toUpperCase()
                                      : '?',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    adolescente.displayName,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                  ),
                                  if (adolescente.colegio.isNotEmpty)
                                    Text(
                                      adolescente.colegio,
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                      ),
                                    ),
                                  if (adolescente.profesionales.hasNombre())
                                    Text(
                                      'Prof: ${adolescente.profesionales.nombre}',
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                          fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                        ),
                                        color: Color(0xFF265294),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              color: Color(0xFF265294),
                              size: 24.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    ),
    Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
            0.0, 40.0, 0.0, 0.0),
        child: Container(
          width: double.infinity,
          height: 133.0,
          decoration: BoxDecoration(
            color: Color(0xFF265294),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(
                AyudaWidget.routeName,
                extra: <String, dynamic>{
                  '__transition_info__': TransitionInfo(
                    hasTransition: true,
                    transitionType:
                        PageTransitionType.fade,
                    duration: Duration(milliseconds: 0),
                  ),
                },
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.circleQuestion,
                  color: FlutterFlowTheme.of(context)
                      .secondary,
                  size: 20.0,
                ),
                Text(
                  '¿Necesitas ayuda?',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context)
                      .titleLarge
                      .override(
                        font: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(
                                      context)
                                  .titleLarge
                                  .fontStyle,
                        ),
                        color:
                            FlutterFlowTheme.of(context)
                                .primaryBackground,
                        fontSize: 24.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context)
                                .titleLarge
                                .fontStyle,
                      ),
                ),
              ].divide(SizedBox(height: 5.0)),
            ),
          ),
        ),
      ),
    ),
    ];
  }
}
