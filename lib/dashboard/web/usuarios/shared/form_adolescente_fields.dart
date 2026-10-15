import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'user_form_fields.dart';

/// Adolescente-specific sidebar content shown when the selected rol is
/// 'Adolescente'. Currently renders the "Acudiente" and "Profesional"
/// dropdowns (the fields that link an adolescent to an accompanying
/// acudiente/profesional).
class AdolescenteSidebarFields extends StatelessWidget {
  const AdolescenteSidebarFields({
    super.key,
    required this.acudienteController,
    required this.profesionalController,
    required this.onAcudienteChanged,
    required this.onProfesionalChanged,
  });

  final FormFieldController<String> Function() acudienteController;
  final FormFieldController<String> Function() profesionalController;
  final ValueChanged<String?> onAcudienteChanged;
  final ValueChanged<String?> onProfesionalChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 15.0),
          child: buildFieldLabel(context, 'Acudiente'),
        ),
        buildUsersByRoleDropdown(
          context: context,
          rol: 'Acudiente',
          controllerFactory: acudienteController,
          onChanged: onAcudienteChanged,
        ),
        Padding(
          padding:
              const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 15.0),
          child: buildFieldLabel(context, 'Profesional'),
        ),
        buildUsersByRoleDropdown(
          context: context,
          rol: 'Profesional',
          controllerFactory: profesionalController,
          onChanged: onProfesionalChanged,
          valoresPorId: true,
          etiquetaVacia: 'Sin profesional',
        ),
      ],
    );
  }
}
