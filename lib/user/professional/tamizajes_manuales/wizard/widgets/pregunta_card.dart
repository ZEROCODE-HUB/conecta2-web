import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/tamizajes/shared/assist_utils.dart';

import '../state/respuesta_state.dart';

/// Renders a single question card, dispatching on question type.
class MobilePreguntaCard extends StatelessWidget {
  const MobilePreguntaCard({
    super.key,
    required this.numero,
    required this.estado,
    required this.theme,
    required this.onChanged,
  });

  final int numero;
  final RespuestaState estado;
  final FlutterFlowTheme theme;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final p = estado.pregunta;
    final completado = estado.estaCompleto();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: completado
              ? const Color(0xFF34A853).withValues(alpha: 0.4)
              : theme.alternate,
          width: completado ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completado
                        ? const Color(0xFF34A853)
                        : const Color(0xFF265294),
                  ),
                  alignment: Alignment.center,
                  child: completado
                      ? const Icon(Icons.check,
                          size: 14, color: Colors.white)
                      : Text(
                          '$numero',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p.pregunta,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: theme.primaryText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _renderInput(context),
          ],
        ),
      ),
    );
  }

  Widget _renderInput(BuildContext context) {
    final p = estado.pregunta;
    final tipo = p.tipo;
    final kind = estado.tipoKind;

    // Descriptiva -- info only
    if (kind == PreguntaTipo.descriptiva) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: theme.secondaryText),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pregunta informativa, sin respuesta requerida.',
                style: GoogleFonts.inter(
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  color: theme.secondaryText,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Abiertas -- multiline text
    if (kind == PreguntaTipo.abiertas) {
      return TextField(
        controller: estado.textController,
        maxLines: 3,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Respuesta del adolescente...',
          hintStyle: GoogleFonts.inter(
              fontSize: 13, color: theme.secondaryText),
          filled: true,
          fillColor: theme.primaryBackground,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.alternate),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.alternate),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF265294), width: 1.5),
          ),
        ),
        onChanged: (_) => onChanged(),
      );
    }

    // Tamizaje radio types
    if (kind == PreguntaTipo.tamizajeRadio) {
      return _buildAtributosRadio(p.respuestaTamizaje);
    }

    // Seleccion -- checkboxes for multiple selection
    if (kind == PreguntaTipo.seleccionMultiple) {
      final opciones = p.respuestaSelection;
      if (opciones.isEmpty) {
        return Text('Sin opciones configuradas',
            style: GoogleFonts.inter(
                fontSize: 13, color: theme.secondaryText));
      }
      return Column(
        children: opciones.map((op) {
          final marcada = estado.seleccionMultiple.contains(op);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: marcada
                  ? const Color(0xFF265294).withValues(alpha: 0.08)
                  : theme.primaryBackground,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  if (marcada) {
                    estado.seleccionMultiple.remove(op);
                  } else {
                    estado.seleccionMultiple.add(op);
                  }
                  onChanged();
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: marcada
                                ? const Color(0xFF265294)
                                : theme.alternate,
                            width: 2,
                          ),
                          color: marcada
                              ? const Color(0xFF265294)
                              : Colors.transparent,
                        ),
                        child: marcada
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          op,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: marcada
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: theme.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    // Selección única -- radio from respuestasSeleccionUnica
    if (kind == PreguntaTipo.seleccionUnica) {
      final opciones = p.respuestasSeleccionUnica;
      if (opciones.isEmpty) {
        return Text('Sin opciones configuradas',
            style: GoogleFonts.inter(
                fontSize: 13, color: theme.secondaryText));
      }
      return Column(
        children: opciones.map((op) {
          final selected = estado.seleccionUnica == op;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: selected
                  ? const Color(0xFF265294).withValues(alpha: 0.08)
                  : theme.primaryBackground,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  estado.seleccionUnica = op;
                  onChanged();
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF265294)
                                : theme.alternate,
                            width: 2,
                          ),
                          color: selected
                              ? const Color(0xFF265294)
                              : Colors.transparent,
                        ),
                        child: selected
                            ? const Icon(Icons.circle,
                                size: 10, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          op,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: theme.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    // Verdadero o falso -- toggle buttons
    if (kind == PreguntaTipo.verdaderoFalso) {
      return Row(
        children: [
          Expanded(
            child: ToggleButton(
              label: 'Verdadero',
              icon: Icons.check_circle_outline,
              selected: estado.trueAndFalseSeleccion == 1,
              theme: theme,
              onTap: () {
                estado.trueAndFalseSeleccion = 1;
                onChanged();
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ToggleButton(
              label: 'Falso',
              icon: Icons.cancel_outlined,
              selected: estado.trueAndFalseSeleccion == 0,
              theme: theme,
              onTap: () {
                estado.trueAndFalseSeleccion = 0;
                onChanged();
              },
            ),
          ),
        ],
      );
    }

    // Tamizaje (Sustancias): una pregunta evalúa SOLO su sustancia asignada.
    if (kind == PreguntaTipo.tamizajeSustancias) {
      final sustancia = canonicaSustancia(p.sustancia);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sustancia.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF009688).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF009688).withValues(alpha: 0.5)),
                ),
                child: Text(
                  'Sustancia: $sustancia',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00796B),
                  ),
                ),
              ),
            ),
          _buildAtributosRadio(p.respuestaTamizaje),
        ],
      );
    }

    // Condicionante: selección MÚLTIPLE. Cada opción marcada habilita las
    // preguntas de su sustancia (igual que el flujo del adolescente).
    if (kind == PreguntaTipo.condicionante) {
      final opciones = p.respuestaCondicionante;
      if (opciones.isEmpty) {
        return Text('Sin opciones condicionantes configuradas',
            style: GoogleFonts.inter(
                fontSize: 13, color: theme.secondaryText));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Marque todas las que apliquen.',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: theme.secondaryText),
            ),
          ),
          ...opciones.map((opt) {
            final marcada =
                estado.condicionanteSeleccionadas.contains(opt.etiqueta);
            final sustancia = canonicaSustancia(opt.sustanciaValor);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: marcada
                    ? const Color(0xFF265294).withValues(alpha: 0.08)
                    : theme.primaryBackground,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    if (marcada) {
                      estado.condicionanteSeleccionadas.remove(opt.etiqueta);
                    } else {
                      estado.condicionanteSeleccionadas.add(opt.etiqueta);
                    }
                    onChanged();
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: marcada
                                  ? const Color(0xFF265294)
                                  : theme.alternate,
                              width: 2,
                            ),
                            color: marcada
                                ? const Color(0xFF265294)
                                : Colors.transparent,
                          ),
                          child: marcada
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt.etiqueta,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: marcada
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: theme.primaryText,
                                ),
                              ),
                              if (sustancia.isNotEmpty)
                                Text(
                                  sustancia,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: theme.secondaryText,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      );
    }

    // Unknown type fallback -- warning styled, shows raw tipo string.
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 20, color: Color(0xFFE65100)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipo de pregunta no soportado',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Valor recibido: "${tipo.isEmpty ? '(vacío)' : tipo}"',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF8A4500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Radio sobre las opciones etiqueta→valor de una pregunta de tamizaje.
  Widget _buildAtributosRadio(List<AtributosStruct> opciones) {
    if (opciones.isEmpty) {
      return Text('Sin opciones configuradas',
          style: GoogleFonts.inter(fontSize: 13, color: theme.secondaryText));
    }
    return Column(
      children: opciones.map((opt) {
        final selected =
            estado.atributoSeleccionado?.etiqueta == opt.etiqueta;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: selected
                ? const Color(0xFF265294).withValues(alpha: 0.08)
                : theme.primaryBackground,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                estado.atributoSeleccionado = opt;
                onChanged();
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF265294)
                              : theme.alternate,
                          width: 2,
                        ),
                        color: selected
                            ? const Color(0xFF265294)
                            : Colors.transparent,
                      ),
                      child: selected
                          ? const Icon(Icons.circle,
                              size: 10, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        opt.etiqueta,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          color: theme.primaryText,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.alternate.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${opt.valor}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

}

class ToggleButton extends StatelessWidget {
  const ToggleButton({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.theme,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final FlutterFlowTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFF265294).withValues(alpha: 0.1)
          : theme.primaryBackground,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? const Color(0xFF265294) : theme.alternate,
              width: selected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? const Color(0xFF265294)
                    : theme.secondaryText,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? const Color(0xFF265294)
                      : theme.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
