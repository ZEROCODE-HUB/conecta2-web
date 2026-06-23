import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import '/backend/backend.dart';
import '/dashboard/web/usuarios/model/eliminar/eliminar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Three-dot popup menu for profile views, replacing the old "Editar Perfil"
/// button and any direct edit/delete icons. Keeps behaviour consistent with
/// the admin encuesta actions menu.
class PerfilActionsMenu extends StatelessWidget {
  const PerfilActionsMenu({
    super.key,
    required this.userRef,
    required this.onStateChanged,
  });

  final DocumentReference userRef;
  final VoidCallback onStateChanged;

  Future<void> _handleEdit() async {
    FFAppState().selectUser = 'Editar';
    onStateChanged();
  }

  Future<void> _handleDelete(BuildContext context) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return WebViewAware(
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: EliminarWidget(userreference: userRef),
          ),
        );
      },
    );
    onStateChanged();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Acciones',
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: const Color(0xFF265294),
          borderRadius: BorderRadius.circular(12.0),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.more_horiz, color: Colors.white, size: 20.0),
      ),
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            await _handleEdit();
            break;
          case 'delete':
            await _handleDelete(context);
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined, size: 18, color: Color(0xFF265294)),
              SizedBox(width: 8),
              Text('Editar perfil'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Eliminar'),
            ],
          ),
        ),
      ],
    );
  }
}
