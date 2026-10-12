import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/form_field_controller.dart';

/// Mapa de categoria -> tipos de pregunta permitidos.
/// Si la categoria no esta en el mapa, retorna todos los tipos (comportamiento default).
const Map<String, List<String>> kTiposPorCategoria = {
  'Consumo de SPA': ['Tamizaje (Sustancias)', 'Condicionante', 'Descriptiva'],
  'Escala autoestima': ['Tamizaje autoestima', 'Descriptiva'],
  'CDI': ['Tamizaje CDI', 'Descriptiva'],
  'Depresión Beck': ['Tamizajes Depresion Beck', 'Descriptiva'],
  'CRQ': ['Tamizaje CRQ', 'Descriptiva'],
  'RQC': ['Tamizaje RQC', 'Descriptiva'],
  'SRQ': ['Tamizaje SRQ', 'Descriptiva'],
  'CRQ / SRQ': ['Tamizaje CRQ / SRQ', 'Descriptiva'],
  'RQC / SRQ': ['Tamizaje RQC / SRQ', 'Descriptiva'],
  'Escala ansiedad': ['Tamizaje ansiedad', 'Descriptiva'],
};

/// Variables para preguntas tipo *Tamizajes Depresion Beck*: los 21 ítems del
/// inventario BDI-II en orden habitual. El valor se guarda en `variable`.
const List<String> kVariablesBeckBDI = [
  'Tristeza',
  'Pesimismo',
  'Fracaso',
  'Pérdida de placer',
  'Sentimientos de culpa',
  'Sentimientos de castigo',
  'Disconformidad con uno mismo',
  'Autocrítica',
  'Pensamientos o deseos suicidas',
  'Llanto',
  'Agitación',
  'Pérdida de interés',
  'Indecisión',
  'Desvalorización',
  'Pérdida de energía',
  'Cambios en los hábitos de sueño',
  'Irritabilidad',
  'Cambios en el apetito',
  'Dificultad de concentración',
  'Cansancio o fatiga',
  'Pérdida de interés en el sexo',
];

/// Retorna los tipos de pregunta permitidos para una categoria.
/// Si categoria es null, vacia o 'Todas', retorna [todosLosTipos].
List<String> tiposPermitidos(String? categoria, List<String> todosLosTipos) {
  if (categoria == null || categoria.isEmpty || categoria == 'Todas') {
    return todosLosTipos;
  }
  final permitidos = kTiposPorCategoria[categoria];
  if (permitidos == null) return todosLosTipos;
  // Conserva el orden de [todosLosTipos] y filtra a los permitidos por categoria.
  return todosLosTipos.where((t) => permitidos.contains(t)).toList();
}

class EncuestaFormHelpers {
  static Widget buildFormularioEspecifico(
      BuildContext context, dynamic model, VoidCallback onUpdate,
      {DocumentReference? encuestaID}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Substance dropdown for Tamizaje (Sustancias)
        if (model.tipoValue == 'Tamizaje (Sustancias)')
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              children: [
                Text('Sustancia: ',
                    style: FlutterFlowTheme.of(context).bodyMedium),
                _buildSustanciaDropdown(context, model, onUpdate,
                    isCondicionante: false),
              ],
            ),
          ),

        // Specific form per type
        Builder(builder: (context) {
          switch (model.tipoValue) {
            case 'abiertas':
              return _buildAbiertaForm(model);
            case 'selección':
              return _buildSeleccionForm(model, onUpdate);
            case 'Condicionante':
              return _buildCondicionanteForm(context, model, onUpdate);
            case 'Selección única':
              return _buildSeleccionUnicaForm(context, model, onUpdate);
            case 'Verdadero o falso':
              return _buildVerdaderoFalsoForm(model, onUpdate);
            case 'Tamizaje':
            case 'Tamizaje (Sustancias)':
            case 'Tamizaje autoestima':
            case 'Tamizaje ansiedad':
              return _buildAutoestimaForm(model, onUpdate);
            case 'Tamizaje CDI':
            case 'Tamizajes Depresion Beck':
              return _buildCDIForm(model, onUpdate);
            case 'Tamizaje CRQ':
            case 'Tamizaje RQC':
            case 'Tamizaje SRQ':
              return _buildCRQSRQForm(model);
            case 'Descriptiva':
              return _buildDescriptivaForm(model);
            default:
              return SizedBox.shrink();
          }
        }),

        // Ocultar respuesta checkbox (not for Descriptiva)
        if (model.tipoValue != 'Descriptiva')
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: _buildOcultarRespuestaCheckbox(context, model, onUpdate),
          ),
      ],
    );
  }

  static Widget _buildDescriptivaForm(dynamic model) {
    return TextFormField(
      controller: model.abiertaTextController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'Escribe aquí el texto informativo o descriptivo...',
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  static Widget _buildOcultarRespuestaCheckbox(
      BuildContext context, dynamic model, VoidCallback onUpdate) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Checkbox(
          value: model.ocultarRespuestaValue ??= false,
          onChanged: (val) {
            model.ocultarRespuestaValue = val!;
            onUpdate();
          },
          activeColor: FlutterFlowTheme.of(context).secondary,
        ),
        Text('Ocultar respuesta',
            style: FlutterFlowTheme.of(context).bodyMedium),
      ],
    );
  }

  static Widget _buildAbiertaForm(dynamic model) {
    return TextFormField(
      controller: model.abiertaTextController,
      decoration: InputDecoration(
        hintText: 'Escribe aquí la respuesta (esto es solo una vista previa)',
        filled: true,
        fillColor: Colors.white,
      ),
      readOnly: true,
    );
  }

  static Widget _buildSeleccionForm(dynamic model, VoidCallback onUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: model.selection1TextController1,
                decoration: InputDecoration(
                  hintText: 'Agregar opción...',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: Color(0xFF265294)),
              onPressed: () {
                if (model.selection1TextController1.text.isNotEmpty) {
                  model.addToRespuestaSelection(
                      model.selection1TextController1.text);
                  model.selection1TextController1?.clear();
                  onUpdate();
                }
              },
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: (model.respuestaSelection as List<String>)
              .map((s) => Chip(
                    label: Text(s),
                    onDeleted: () {
                      model.removeFromRespuestaSelection(s);
                      onUpdate();
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  static Widget _buildCondicionanteForm(
      BuildContext context, dynamic model, VoidCallback onUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: model.selection1TextController2,
                decoration: InputDecoration(
                  hintText: 'Etiqueta (ej. Sí, fumo)',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            _buildSustanciaDropdown(context, model, onUpdate,
                isCondicionante: true),
            IconButton(
              icon: Icon(Icons.add_circle, color: Color(0xFF265294)),
              onPressed: () {
                if (model.selection1TextController2.text.isNotEmpty) {
                  model.addToRespuestaCondicionante(ValorCondicionanteStruct(
                    etiqueta: model.selection1TextController2.text,
                    sustanciaValor: model.dropDownSustanciaCondicionanValue,
                  ));
                  model.selection1TextController2?.clear();
                  onUpdate();
                }
              },
            ),
          ],
        ),
        if ((model.respuestaCondicionante as List<ValorCondicionanteStruct>)
            .isNotEmpty)
          Column(
            children:
                (model.respuestaCondicionante as List<ValorCondicionanteStruct>)
                    .map((rc) => ListTile(
                          title: Text('${rc.etiqueta} -> ${rc.sustanciaValor}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              model.removeFromRespuestaCondicionante(rc);
                              onUpdate();
                            },
                          ),
                        ))
                    .toList(),
          ),
      ],
    );
  }

  static Widget _buildSustanciaDropdown(
      BuildContext context, dynamic model, VoidCallback onUpdate,
      {required bool isCondicionante}) {
    return FlutterFlowDropDown<String>(
      textStyle: FlutterFlowTheme.of(context).bodyMedium,
      controller: isCondicionante
          ? (model.dropDownSustanciaCondicionanValueController ??=
              FormFieldController<String>(null))
          : (model.dropDownSustanciaValueController ??=
              FormFieldController<String>(null)),
      options: [
        'Tabaco',
        'Bebidas alcohólicas',
        'Cannabis',
        'Anfetaminas',
        'Inhalantes',
        'Tranquilizantes',
        'Alucinógenos',
        'Opiáceos',
        'Otros',
        'Cocaina'
      ],
      onChanged: (val) {
        if (isCondicionante) {
          model.dropDownSustanciaCondicionanValue = val;
        } else {
          model.dropDownSustanciaValue = val;
        }
        onUpdate();
      },
      width: 180,
      height: 40,
      hintText: 'Sustancia',
      fillColor: Colors.white,
      elevation: 2.0,
      borderColor: Colors.transparent,
      borderWidth: 0.0,
      borderRadius: 8,
      margin: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
      hidesUnderline: true,
    );
  }

  static Widget _buildSeleccionUnicaForm(
      BuildContext context, dynamic model, VoidCallback onUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: model.selectionunica1TextController,
                decoration: InputDecoration(
                  hintText: 'Agregar opción...',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: Color(0xFF265294)),
              onPressed: () {
                if (model.selectionunica1TextController.text.isNotEmpty) {
                  model.addToSeleccionunica(
                      model.selectionunica1TextController.text);
                  model.selectionunica1TextController?.clear();
                  onUpdate();
                }
              },
            ),
          ],
        ),
        FlutterFlowRadioButton(
          options: (model.seleccionunica as List<String>).toList(),
          onChanged: (val) => onUpdate(),
          controller: model.sunicarespValueController ??=
              FormFieldController<String>(null),
          optionHeight: 32.0,
          textStyle: FlutterFlowTheme.of(context).bodyMedium,
          radioButtonColor: Color(0xFF265294),
          inactiveRadioButtonColor: Colors.grey,
          toggleable: false,
          horizontalAlignment: WrapAlignment.start,
        ),
      ],
    );
  }

  static Widget _buildVerdaderoFalsoForm(dynamic model, VoidCallback onUpdate) {
    return Row(
      children: [
        Checkbox(
          value: model.checkboxValue9 ??= false,
          onChanged: (val) {
            model.checkboxValue9 = val!;
            if (val) model.checkboxValue10 = false;
            onUpdate();
          },
        ),
        Text('Verdadero'),
        SizedBox(width: 20),
        Checkbox(
          value: model.checkboxValue10 ??= false,
          onChanged: (val) {
            model.checkboxValue10 = val!;
            if (val) model.checkboxValue9 = false;
            onUpdate();
          },
        ),
        Text('Falso'),
      ],
    );
  }

  static Widget _buildAutoestimaForm(dynamic model, VoidCallback onUpdate) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: model.autoestimaEtiquetaTextController ??=
                    TextEditingController(),
                focusNode: model.autoestimaEtiquetaFocusNode ??= FocusNode(),
                decoration: InputDecoration(
                    hintText: 'Etiqueta (ej. Muy en desacuerdo)',
                    filled: true,
                    fillColor: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
              width: 100,
              child: TextFormField(
                controller: model.autoestimaValorTextController ??=
                    TextEditingController(),
                focusNode: model.autoestimaValorFocusNode ??= FocusNode(),
                decoration: InputDecoration(
                    hintText: 'Puntaje', filled: true, fillColor: Colors.white),
                keyboardType: TextInputType.number,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: Color(0xFF265294)),
              onPressed: () {
                if (model.autoestimaEtiquetaTextController.text.isNotEmpty) {
                  model.addToRespuestaTamizaje(AtributosStruct(
                    etiqueta: model.autoestimaEtiquetaTextController.text,
                    valor: int.tryParse(
                            model.autoestimaValorTextController.text) ??
                        0,
                  ));
                  model.autoestimaEtiquetaTextController?.clear();
                  model.autoestimaValorTextController?.clear();
                  onUpdate();
                }
              },
            ),
          ],
        ),
        if ((model.respuestaTamizaje as List<AtributosStruct>).isNotEmpty)
          Column(
            children: (model.respuestaTamizaje as List<AtributosStruct>)
                .asMap()
                .entries
                .map((e) => ListTile(
                      title: Text(
                          '${e.key + 1}. ${e.value.etiqueta} (${e.value.valor})'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          model.removeAtIndexFromRespuestaTamizaje(e.key);
                          onUpdate();
                        },
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }

  static Widget _buildCDIForm(dynamic model, VoidCallback onUpdate) {
    return Column(
      children: [
        Row(
          children: [
            Text('Variable:'),
            SizedBox(width: 10),
            Builder(builder: (context) {
              return FlutterFlowDropDown<String>(
                textStyle: FlutterFlowTheme.of(context).bodyMedium,
                controller: model.variableCDIValueController ??=
                    FormFieldController<String>(null),
                options: model.tipoValue == 'Tamizaje CDI'
                    ? const ['Disforia', 'Autoestima Negativa']
                    : kVariablesBeckBDI,
                onChanged: (val) {
                  model.variableCDIValue = val;
                  onUpdate();
                },
                width: 320,
                height: 40,
                fillColor: Colors.white,
                elevation: 2.0,
                borderColor: Colors.transparent,
                borderWidth: 0.0,
                borderRadius: 8,
                margin: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                hidesUnderline: true,
              );
            }),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: model.cdiTextController ??= TextEditingController(),
                focusNode: model.cdiFocusNode ??= FocusNode(),
                decoration: InputDecoration(
                    hintText: 'Opciones de respuesta',
                    filled: true,
                    fillColor: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
              width: 80,
              child: TextFormField(
                controller: model.cdiValorTextController ??=
                    TextEditingController(),
                focusNode: model.cdiValorFocusNode ??= FocusNode(),
                decoration: InputDecoration(
                    hintText: 'Puntaje', filled: true, fillColor: Colors.white),
                keyboardType: TextInputType.number,
              ),
            ),
            Checkbox(
              value: model.ideacionSuicidaValue ??= false,
              onChanged: (val) {
                model.ideacionSuicidaValue = val!;
                onUpdate();
              },
            ),
            Text('IS',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.add_circle, color: Color(0xFF265294)),
              onPressed: () {
                if (model.cdiTextController.text.isNotEmpty) {
                  model.addToRespuestaCDI(AtributosStruct(
                    etiqueta: model.cdiTextController.text,
                    valor: int.tryParse(model.cdiValorTextController.text) ?? 0,
                    ideacionSuicida: model.ideacionSuicidaValue ?? false,
                  ));
                  model.cdiTextController?.clear();
                  model.cdiValorTextController?.clear();
                  model.ideacionSuicidaValue = false;
                  onUpdate();
                }
              },
            ),
          ],
        ),
        if ((model.respuestaCDI as List<AtributosStruct>).isNotEmpty)
          Column(
            children: (model.respuestaCDI as List<AtributosStruct>)
                .asMap()
                .entries
                .map((e) => ListTile(
                      title: Text(
                          '${e.key + 1}. ${e.value.etiqueta} (${e.value.valor})${e.value.ideacionSuicida ? " [IS]" : ""}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          model.removeAtIndexFromRespuestaCDI(e.key);
                          onUpdate();
                        },
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }

  static Widget _buildCRQSRQForm(dynamic model) {
    return Column(
      children: [
        TextFormField(
          controller: model.crqNumeroPreguntaTextController ??=
              TextEditingController(),
          decoration: InputDecoration(
              hintText: 'Número de pregunta original (ej. 17)',
              filled: true,
              fillColor: Colors.white),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: model.crqSiScoreTextController ??=
                    TextEditingController(),
                decoration: InputDecoration(
                    hintText: 'Puntaje SI',
                    filled: true,
                    fillColor: Colors.white),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: model.crqNoScoreTextController ??=
                    TextEditingController(),
                decoration: InputDecoration(
                    hintText: 'Puntaje NO',
                    filled: true,
                    fillColor: Colors.white),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
