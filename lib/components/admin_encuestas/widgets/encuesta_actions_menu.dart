import '/backend/backend.dart';
import '/dashboard/web/encuestas/model/eliminarencuesta/eliminarencuesta_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../admin_encuestas_model.dart';
import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

/// Three-dot popup menu replacing the custom expand-actions from the
/// original FlutterFlow implementation. Keeps the same Edit/Delete actions.
class EncuestaActionsMenu extends StatelessWidget {
  const EncuestaActionsMenu({
    super.key,
    required this.model,
    required this.encuesta,
    required this.onStateChanged,
  });

  final AdminEncuestasModel model;
  final EncuestasRecord encuesta;
  final VoidCallback onStateChanged;

  Future<void> _handleEdit(BuildContext context) async {
    model.documentID = encuesta.reference;
    model.doc = encuesta;
    model.updatePage(() {});
    FFAppState().selectUser = 'Editar Encuesta';
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
            child: EliminarencuestaWidget(
              id: encuesta.reference,
              esTamizaje: encuesta.tipo == 'Tamizajes',
            ),
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
      icon: Container(
        width: 26.0,
        height: 26.0,
        decoration: BoxDecoration(
          color: const Color(0xFF265294),
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.more_horiz,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            await _handleEdit(context);
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
              Text('Editar'),
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
              Text('Borrar'),
            ],
          ),
        ),
      ],
    );
  }
}
