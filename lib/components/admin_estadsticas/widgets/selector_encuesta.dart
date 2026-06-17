import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '../common/filter_pill.dart';
import '../helpers/stats_calculator.dart';

/// Dropdown to pick a specific encuesta within the currently selected
/// [TamizajeTipo]. Hidden when the list is empty or tipo is "todas".
class SelectorEncuesta extends StatefulWidget {
  const SelectorEncuesta({
    super.key,
    required this.tipo,
    required this.seleccionada,
    required this.onChanged,
  });

  final TamizajeTipo tipo;
  final String? seleccionada;
  final ValueChanged<String?> onChanged;

  @override
  State<SelectorEncuesta> createState() => _SelectorEncuestaState();
}

class _SelectorEncuestaState extends State<SelectorEncuesta> {
  List<String> _items = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(SelectorEncuesta old) {
    super.didUpdateWidget(old);
    if (old.tipo != widget.tipo) _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final result = await loadEncuestasByTipo(widget.tipo);
    if (!mounted) return;
    setState(() {
      _items = result;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (!_cargando && _items.isEmpty) {
      return FilterPill(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            'Sin tamizajes publicados',
            style: filterPillLabelStyle(context),
          ),
        ),
      );
    }

    return FilterPill(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: _cargando
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: widget.seleccionada,
                  hint: Text(
                    'Todos los tamizajes',
                    style: filterPillLabelStyle(context),
                  ),
                  isDense: true,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(
                        'Todos los tamizajes',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.primaryText,
                        ),
                      ),
                    ),
                    ..._items.map(
                      (titulo) => DropdownMenuItem(
                        value: titulo,
                        child: Text(
                          titulo,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.primaryText,
                          ),
                        ),
                      ),
                    ),
                  ],
                  onChanged: widget.onChanged,
                ),
              ),
      ),
    );
  }
}
