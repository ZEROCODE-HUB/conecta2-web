import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'contenido_card.dart';

/// Renders the column header and the filtered list of contenidos.
class ContenidoList extends StatelessWidget {
  const ContenidoList({
    super.key,
    required this.allRecords,
    required this.simpleSearchResults,
    required this.isShowFullList,
    required this.publishedFilter,
    required this.rolesFilter,
    required this.onPreview,
    required this.onEdit,
  });

  final List<ContenidoRecord> allRecords;
  final List<ContenidoRecord> simpleSearchResults;
  final bool isShowFullList;
  final bool? publishedFilter;
  final List<String>? rolesFilter;
  final void Function(ContenidoRecord) onPreview;
  final void Function(ContenidoRecord) onEdit;

  /// Aplica a la vez la búsqueda, "Filtrar por" (publicado) y "Dirigido
  /// para" (roles). Un filtro sin valor no filtra. Se parte de [allRecords]
  /// (stream en vivo) para que el estado mostrado sea siempre el actual.
  List<ContenidoRecord> _resolveList() {
    Iterable<ContenidoRecord> lista = allRecords;

    if (!isShowFullList) {
      final ids = simpleSearchResults.map((r) => r.reference.path).toSet();
      lista = lista.where((r) => ids.contains(r.reference.path));
    }

    if (publishedFilter != null) {
      lista = lista.where((r) => r.publicado == publishedFilter);
    }

    // '' es la opción "Todos".
    final roles = (rolesFilter ?? const <String>[])
        .where((r) => r.isNotEmpty)
        .toSet();
    if (roles.isNotEmpty) {
      lista = lista.where((r) => r.roles.any(roles.contains));
    }

    return lista.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final list = _resolveList();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 20.0),
      child: Container(
        width: screenWidth,
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildHeader(context, theme, screenWidth),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  'No hay contenidos que coincidan con los filtros.',
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: theme.secondaryText,
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: list.length,
              itemBuilder: (context, index) => ContenidoCard(
                item: list[index],
                onPreview: onPreview,
                onEdit: onEdit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, FlutterFlowTheme theme, double screenWidth) {
    TextStyle headerStyle() => theme.bodyMedium.override(
          font: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontStyle: theme.bodyMedium.fontStyle,
          ),
          color: const Color(0xFF9E8888),
          fontSize: 18.0,
          letterSpacing: 0.0,
          fontWeight: FontWeight.w500,
          fontStyle: theme.bodyMedium.fontStyle,
        );

    Widget cell(String text, double factor) => Flexible(
          child: Container(
            width: screenWidth * factor,
            height: 100.0,
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
            ),
            child: Align(
              alignment: AlignmentDirectional.center,
              child: Text(text, style: headerStyle()),
            ),
          ),
        );

    Widget empty(double factor) => Flexible(
          child: Container(
            width: screenWidth * factor,
            height: 100.0,
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
            ),
          ),
        );

    return Container(
      width: screenWidth,
      height: 60.0,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            cell('Nombre de la contenido', 0.35),
            cell('Dirigido para', 0.14),
            cell('Estado', 0.16),
            cell('Creación', 0.15),
            empty(0.12),
            empty(0.1),
          ],
        ),
      ),
    );
  }
}
