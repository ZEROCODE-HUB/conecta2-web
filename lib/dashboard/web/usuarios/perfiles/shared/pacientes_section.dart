import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_search/text_search.dart';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'network_avatar.dart';

/// "Pacientes" tab used on the profesional profile view. Shows a search
/// field plus either the remote filtered list or the in-memory search
/// results (scoped to the current profesional).
class PacientesSection extends StatelessWidget {
  const PacientesSection({
    super.key,
    required this.profesionalRef,
    required this.controller,
    required this.focusNode,
    required this.results,
    required this.onResultsChanged,
    required this.onStateChanged,
  });

  final DocumentReference profesionalRef;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<UsersRecord> results;
  final ValueChanged<List<UsersRecord>> onResultsChanged;
  final VoidCallback onStateChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pacientes',
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
          const SizedBox(height: 20.0),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (_) => EasyDebounce.debounce(
                    'pacientes_search',
                    const Duration(milliseconds: 100),
                    () async {
                      await queryUsersRecordOnce().then(
                        (records) => onResultsChanged(
                          TextSearch(
                            records
                                .map((record) => TextSearchItem.fromTerms(
                                    record, [record.displayName]))
                                .toList(),
                          )
                              .search(controller.text)
                              .map((r) => r.object)
                              .toList(),
                        ),
                      );
                    },
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Buscar usuarios',
                    hintStyle: theme.bodyLarge.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontStyle: theme.bodyLarge.fontStyle,
                      ),
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
                      borderSide: BorderSide(color: theme.primary, width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    filled: true,
                    fillColor: theme.web2,
                    contentPadding: const EdgeInsetsDirectional.fromSTEB(
                        24.0, 16.0, 24.0, 16.0),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF265294),
                      size: 28.0,
                    ),
                  ),
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontStyle: theme.bodyMedium.fontStyle,
                    ),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (controller.text.isNotEmpty)
                IconButton(
                  tooltip: 'Limpiar',
                  onPressed: () {
                    controller.clear();
                    onResultsChanged(const []);
                    onStateChanged();
                  },
                  icon: const Icon(Icons.clear, color: Color(0xFF265294)),
                ),
            ],
          ),
          const SizedBox(height: 24.0),
          controller.text.isNotEmpty
              ? _buildSearchResults(context)
              : _buildStreamList(context),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final filtered =
        results.where((e) => e.profesionales.ref == profesionalRef).toList();
    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('Sin coincidencias'),
      );
    }
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: filtered.map((u) => _PatientTile(user: u)).toList(),
    );
  }

  Widget _buildStreamList(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return StreamBuilder<List<UsersRecord>>(
      stream: queryUsersRecord(
        queryBuilder: (u) =>
            u.where('Profesionales.Ref', isEqualTo: profesionalRef),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
              ),
            ),
          );
        }
        final list = snapshot.data!;
        if (list.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Sin pacientes asignados'),
          );
        }
        return Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: list.map((u) => _PatientTile(user: u)).toList(),
        );
      },
    );
  }
}

class _PatientTile extends StatelessWidget {
  const _PatientTile({required this.user});

  final UsersRecord user;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: 300.0,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          NetworkAvatar(url: user.photoUrl, size: 45.0),
          const SizedBox(width: 15.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle: theme.bodyMedium.fontStyle,
                    ),
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user.rol,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontStyle: theme.bodyMedium.fontStyle,
                    ),
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
