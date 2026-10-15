import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'user_form_fields.dart';

/// Acudiente-specific sidebar content shown when the selected rol is
/// 'Acudiente'. Renders the "Adolescente" and "Profesional" dropdowns.
class AcudienteSidebarFields extends StatelessWidget {
  const AcudienteSidebarFields({
    super.key,
    required this.adolescenteController,
    required this.profesionalController,
    required this.onAdolescenteChanged,
    required this.onProfesionalChanged,
  });

  final FormFieldController<String> Function() adolescenteController;
  final FormFieldController<String> Function() profesionalController;
  final ValueChanged<String?> onAdolescenteChanged;
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
          child: buildFieldLabel(context, 'Adolescente'),
        ),
        buildUsersByRoleDropdown(
          context: context,
          rol: 'Adolescente',
          controllerFactory: adolescenteController,
          onChanged: onAdolescenteChanged,
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
