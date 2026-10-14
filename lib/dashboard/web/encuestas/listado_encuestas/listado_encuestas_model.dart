import '/flutter_flow/flutter_flow_util.dart';
import 'listado_encuestas_widget.dart' show ListadoEncuestasWidget;
import 'package:flutter/material.dart';

class ListadoEncuestasModel
    extends FlutterFlowModel<ListadoEncuestasWidget> {
  /// Id de la encuesta seleccionada en el filtro (null = todas).
  String? filtroEncuestaId;

  /// Texto de búsqueda.
  String busqueda = '';

  /// Orden por fecha: true = más recientes primero.
  bool ordenDescendente = true;

  /// Página actual (base cero).
  int paginaActual = 0;

  /// Controllers para la barra de búsqueda.
  late TextEditingController searchController;
  late FocusNode searchFocusNode;

  @override
  void initState(BuildContext context) {
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
  }
}
