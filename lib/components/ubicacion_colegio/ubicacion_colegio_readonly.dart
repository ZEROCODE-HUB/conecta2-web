import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// Municipio y Barrio del adolescente, de solo lectura: salen del colegio
/// elegido (ver `ubicacionDeColegio`). Se usa en Crear/Editar usuario del
/// admin y en el alta de adolescente del wizard de tamizaje manual (web y
/// app del profesional).
///
/// [colegioElegido] en `false` muestra "—" con la pista "Elige un colegio".
/// [compacto] apila los dos campos (pantallas angostas).
class UbicacionColegioReadonly extends StatelessWidget {
  const UbicacionColegioReadonly({
    super.key,
    required this.municipio,
    required this.barrio,
    required this.colegioElegido,
    this.compacto = false,
  });

  final String municipio;
  final String barrio;
  final bool colegioElegido;
  final bool compacto;

  static const _fondo = Color(0xFFEEEFF1);
  static const _gris = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final campos = [
      _Campo(
        etiqueta: 'Municipio',
        valor: municipio,
        colegioElegido: colegioElegido,
      ),
      _Campo(
        etiqueta: 'Barrio',
        valor: barrio,
        colegioElegido: colegioElegido,
      ),
    ];
    final faltaDato =
        colegioElegido && (municipio.trim().isEmpty || barrio.trim().isEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (compacto)
          Column(children: [campos[0], const SizedBox(height: 12), campos[1]])
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: campos[0]),
              const SizedBox(width: 25),
              Expanded(child: campos[1]),
            ],
          ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 16, color: _gris),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                faltaDato
                    ? 'Este colegio no tiene barrio o municipio registrado. '
                        'Puedes completarlo en Instituciones.'
                    : 'Se completan automáticamente con el colegio elegido. '
                        'Para cambiarlos, elige otro colegio.',
                style: GoogleFonts.inter(fontSize: 12, color: _gris),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Campo extends StatelessWidget {
  const _Campo({
    required this.etiqueta,
    required this.valor,
    required this.colegioElegido,
  });

  final String etiqueta;
  final String valor;
  final bool colegioElegido;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final vacio = valor.trim().isEmpty;
    final texto = !colegioElegido
        ? 'Elige un colegio'
        : (vacio ? '—' : valor.trim());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              etiqueta,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.lock_outline,
                size: 14, color: UbicacionColegioReadonly._gris),
          ],
        ),
        const SizedBox(height: 10),
        Semantics(
          label: '$etiqueta: $texto (solo lectura)',
          readOnly: true,
          child: Container(
            width: double.infinity,
            height: 47,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: UbicacionColegioReadonly._fondo,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              texto,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: !colegioElegido || vacio
                    ? UbicacionColegioReadonly._gris
                    : theme.primaryText,
                fontStyle: !colegioElegido ? FontStyle.italic : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
