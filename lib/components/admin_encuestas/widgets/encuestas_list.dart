import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../admin_encuestas_model.dart';
import 'encuesta_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays the header row and the filtered list of encuestas.
class EncuestasList extends StatefulWidget {
  const EncuestasList({
    super.key,
    required this.model,
    required this.tipo,
    required this.allEncuestas,
    required this.onStateChanged,
  });

  final AdminEncuestasModel model;
  final String tipo;
  final List<EncuestasRecord> allEncuestas;
  final VoidCallback onStateChanged;

  @override
  State<EncuestasList> createState() => _EncuestasListState();
}

class _EncuestasListState extends State<EncuestasList> {
  static const int _pageSize = 20;
  int _currentPage = 0;

  List<EncuestasRecord> _filtered() {
    final m = widget.model;
    final showFullList = m.isShowFullList == true;
    final hasPublicadoFilter = m.dropDownValue1 != null;
    final hasRolFilter = m.dropDownValue2 != null && m.dropDownValue2 != '';

    List<EncuestasRecord> base;
    if (!showFullList) {
      base = m.simpleSearchResults;
    } else {
      base = widget.allEncuestas;
    }

    Iterable<EncuestasRecord> result = base;

    // Oculta docs con el título literal 'Vacío' — residuo de la versión
    // anterior, que persistía un doc placeholder al presionar "Crear nuevo".
    // Hoy no creamos docs hasta el submit, así que los tamizajes con título
    // vacío suelen ser legítimos (p. ej. borrador a medio nombrar) y deben
    // verse en el listado para que el usuario pueda editarlos.
    result = result.where((e) => e.titulo.trim() != 'Vacío');

    if (hasPublicadoFilter) {
      result = result.where((e) => e.publicado == m.dropDownValue1);
    }
    if (hasRolFilter) {
      result = result.where((e) => e.roles.contains(m.dropDownValue2));
    }

    return result.toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();
    final totalPages =
        (filtered.length / _pageSize).ceil().clamp(1, 1 << 30);
    if (_currentPage >= totalPages) {
      _currentPage = totalPages - 1;
    }
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);
    final pageItems = filtered.isEmpty
        ? const <EncuestasRecord>[]
        : filtered.sublist(start, end);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Expanded(
            child: pageItems.isEmpty
                ? _buildEmpty(context)
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: pageItems.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Color(0xFFEEEEEE),
                    ),
                    itemBuilder: (context, index) {
                      return EncuestaRow(
                        model: widget.model,
                        encuesta: pageItems[index],
                        onStateChanged: widget.onStateChanged,
                      );
                    },
                  ),
          ),
          if (filtered.length > _pageSize)
            _buildPagination(context, totalPages, filtered.length),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No hay ${widget.tipo.toLowerCase()} que coincidan con los filtros.',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final headerStyle =
        FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w500),
              color: const Color(0xFF9E8888),
              fontSize: 18.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
            );

    return Container(
      width: double.infinity,
      height: 60.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
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
            Expanded(
              flex: 35,
              child: Align(
                alignment: AlignmentDirectional.center,
                child: Text(
                  widget.tipo == 'Encuestas'
                      ? 'Nombre de la encuesta'
                      : 'Nombre del tamizaje',
                  style: headerStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 14,
              child: Align(
                alignment: AlignmentDirectional.center,
                child: Text(
                  'Dirigido para',
                  style: headerStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 16,
              child: Align(
                alignment: AlignmentDirectional.center,
                child: Text(
                  'Estado',
                  style: headerStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 15,
              child: Align(
                alignment: AlignmentDirectional.center,
                child: Text(
                  'Creación',
                  style: headerStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Expanded(flex: 12, child: SizedBox.shrink()),
            const Expanded(flex: 10, child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(
      BuildContext context, int totalPages, int totalItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'Anterior',
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            'Página ${_currentPage + 1} de $totalPages  ($totalItems)',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
          IconButton(
            tooltip: 'Siguiente',
            onPressed: _currentPage < totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
