import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/form_field_controller.dart';
import 'encuesta_list_card.dart';

/// "Encuestas creadas" del perfil del profesional: chips (Encuestas /
/// Tamizajes) + las encuestas cuyo `created_by` es ese profesional.
class EncuestasCreadasSection extends StatelessWidget {
  const EncuestasCreadasSection({
    super.key,
    required this.profesionalRef,
    required this.selected,
    required this.controller,
    required this.onChanged,
    required this.onOpenResultados,
  });

  final DocumentReference profesionalRef;
  final String? selected;
  final FormFieldController<List<String>> controller;
  final ValueChanged<String?> onChanged;
  final ValueChanged<EncuestasRecord> onOpenResultados;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tipo = selected ?? 'Encuestas';
    final nombreTipo = tipo == 'Tamizajes' ? 'tamizajes' : 'encuestas';

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: const AlignmentDirectional(0.0, -1.0),
            child: FlutterFlowChoiceChips(
              options: const [ChipData('Encuestas'), ChipData('Tamizajes')],
              onChanged: (val) => onChanged(val?.firstOrNull),
              selectedChipStyle: ChipStyle(
                backgroundColor: const Color(0xFF265294),
                textStyle: theme.bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontStyle: theme.bodyMedium.fontStyle,
                  ),
                  color: theme.primaryBackground,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
                iconColor: theme.primaryText,
                iconSize: 18.0,
                elevation: 4.0,
                borderRadius: BorderRadius.circular(16.0),
              ),
              unselectedChipStyle: ChipStyle(
                backgroundColor: theme.alternate,
                textStyle: theme.bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: theme.bodyMedium.fontWeight,
                    fontStyle: theme.bodyMedium.fontStyle,
                  ),
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                ),
                iconColor: theme.secondaryText,
                iconSize: 18.0,
                elevation: 0.0,
                borderRadius: BorderRadius.circular(16.0),
              ),
              chipSpacing: 30.0,
              rowSpacing: 12.0,
              multiselect: false,
              initialized: selected != null,
              alignment: WrapAlignment.spaceEvenly,
              controller: controller,
              wrapped: false,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
            child: Text(
              'Creadas por el profesional: $tipo',
              style: theme.bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontStyle: theme.bodyMedium.fontStyle,
                ),
                fontSize: 24.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
            child: SizedBox(
              height: 400.0,
              child: StreamBuilder<List<EncuestasRecord>>(
                stream: queryEncuestasRecord(
                  queryBuilder: (r) => r
                      .where('created_by', isEqualTo: profesionalRef)
                      .where('tipo', isEqualTo: tipo),
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(theme.primary),
                        ),
                      ),
                    );
                  }
                  // Más recientes primero (orden en el cliente: sin índice).
                  final list = [...snapshot.data!]..sort((a, b) =>
                      (b.createAt ?? DateTime(0))
                          .compareTo(a.createAt ?? DateTime(0)));
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Este profesional no ha creado $nombreTipo.',
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontStyle: theme.bodyMedium.fontStyle,
                          ),
                          letterSpacing: 0.0,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final record = list[index];
                      return EncuestaListCard(
                        encuesta: record,
                        etiquetas: [
                          record.publicado ? 'Publicado' : 'Borrador',
                          if (record.categoria.isNotEmpty) record.categoria,
                        ],
                        onTap: () => onOpenResultados(record),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
