import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// A single tab "pill" used across the profile views.
class PerfilTabPill extends StatelessWidget {
  const PerfilTabPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF265294) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(40.0),
          border: Border.all(
            color: selected ? const Color(0xFF265294) : const Color(0xFF6E98D7),
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 15.0, 20.0, 15.0),
          child: Text(
            label,
            style: theme.bodyMedium.override(
              font: GoogleFonts.inter(
                fontWeight: theme.bodyMedium.fontWeight,
                fontStyle: theme.bodyMedium.fontStyle,
              ),
              color: selected ? Colors.white : const Color(0xFF265294),
              letterSpacing: 0.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Row of tab pills.
class PerfilTabBar extends StatelessWidget {
  const PerfilTabBar({
    super.key,
    required this.tabs,
    required this.current,
    required this.onSelected,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
  });

  final List<String> tabs;
  final String current;
  final ValueChanged<String> onSelected;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        for (final tab in tabs)
          Flexible(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
              child: PerfilTabPill(
                label: tab,
                selected: current == tab,
                onTap: () => onSelected(tab),
              ),
            ),
          ),
      ],
    );
  }
}
