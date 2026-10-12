// TamizajeDataTable - main widget.
//
// This widget renders a data table with filtering, column-visibility controls
// and an Excel export button for a given tamizaje questionnaire. Data is
// loaded from Firestore. All pure helpers live in adjacent files under
// `helpers/`, `data/` and `widgets/`.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';

import 'data/substance_data.dart';
import 'helpers/data_transformers.dart';
import '/tamizajes/shared/assist_utils.dart' show esEncuestaAssist;
import 'helpers/excel_export.dart';
import 'widgets/table_header.dart';
import 'widgets/table_row_widget.dart';

class TamizajeDataTable extends StatefulWidget {
  const TamizajeDataTable({
    Key? key,
    this.width,
    this.height,
    required this.tamizajeNombre,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String? tamizajeNombre;

  @override
  State<TamizajeDataTable> createState() => _TamizajeDataTableState();
}

class _TamizajeDataTableState extends State<TamizajeDataTable> {
  List<Map<String, dynamic>> _respuestasProcesadas = [];
  List<Map<String, dynamic>> _respuestasFiltradas = [];
  bool _cargando = false;
  String _error = '';

  final Map<String, Set<String>> _filtros = {};
  final Map<String, String> _filtrosSeleccionados = {};
  bool _mostrarFiltros = false;
  bool _mostrarSeleccionColumnas = false;

  Map<String, bool> _columnasVisibles = {};
  List<Map<String, String>> _ordenColumnas = [];
  Set<String> _variables = {};

  final ScrollController _scrollControllerVertical = ScrollController();
  final ScrollController _scrollControllerHorizontal = ScrollController();

  @override
  void dispose() {
    _scrollControllerVertical.dispose();
    _scrollControllerHorizontal.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.tamizajeNombre != null && widget.tamizajeNombre!.isNotEmpty) {
      _cargarRespuestas();
    }
  }

  @override
  void didUpdateWidget(TamizajeDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tamizajeNombre != oldWidget.tamizajeNombre) {
      _cargarRespuestas();
    }
  }

  void _aplicarFiltros() {
    if (_respuestasProcesadas.isEmpty) {
      _respuestasFiltradas = [];
      return;
    }

    List<Map<String, dynamic>> filtradas = _respuestasProcesadas;
    for (var entry in _filtrosSeleccionados.entries) {
      final columna = entry.key;
      final valor = entry.value;
      if (valor != 'Todos') {
        filtradas = filtradas
            .where((r) => (r[columna]?.toString() ?? '') == valor)
            .toList();
      }
    }

    setState(() {
      _respuestasFiltradas = filtradas;
    });
  }

  void _limpiarFiltros() {
    setState(() {
      _filtrosSeleccionados.clear();
      _respuestasFiltradas = _respuestasProcesadas;
    });
  }

  Future<void> _cargarRespuestas() async {
    if (widget.tamizajeNombre == null || widget.tamizajeNombre!.isEmpty) {
      setState(() {
        _respuestasProcesadas = [];
        _respuestasFiltradas = [];
        _error = 'Seleccione un tamizaje';
      });
      return;
    }

    setState(() {
      _cargando = true;
      _error = '';
      _filtros.clear();
      _filtrosSeleccionados.clear();
    });

    try {
      final tamizajeSnapshot = await FirebaseFirestore.instance
          .collection('Encuestas')
          .where('tipo', isEqualTo: 'Tamizajes')
          .where('titulo', isEqualTo: widget.tamizajeNombre)
          .where('Publicado', isEqualTo: true)
          .get();

      if (tamizajeSnapshot.docs.isEmpty) {
        setState(() {
          _error = 'No se encontró el tamizaje: ${widget.tamizajeNombre}';
          _cargando = false;
        });
        return;
      }

      final tamizajeDoc = tamizajeSnapshot.docs.first;
      final tamizajeData = tamizajeDoc.data();
      final tamizajeId = tamizajeDoc.id;

      final preguntasEncuesta =
          tamizajeData['Preguntas'] as List<dynamic>? ?? [];
      final Set<String> variables = {};
      for (var preg in preguntasEncuesta) {
        if (preg is Map<String, dynamic>) {
          final v = preg['variable']?.toString().trim() ?? '';
          if (v.isNotEmpty) {
            variables.add(v);
          }
        }
      }

      final categoria = tamizajeData['categoria'] as String? ?? '';
      final titulo = tamizajeData['titulo'] as String? ?? '';
      final bool esAssist =
          categoria == 'ASSIST' || esEncuestaAssist(categoria, titulo);

      if (variables.isEmpty) {
        if (esAssist) {
          variables.addAll(kTodasLasSustancias);
        } else {
          variables.add(categoria.isNotEmpty ? categoria : titulo);
        }
      }

      _variables = variables;

      final List<Map<String, String>> dynamicOrdenColumnas = [];
      final List<Map<String, String>> kColumnasBasicasConLabel = [
        {'label': 'N', 'clave': 'N'},
        {'label': 'AÑO', 'clave': 'ANO'},
        {'label': 'FOLIO', 'clave': 'FOLIO'},
        {'label': 'NOMBRE', 'clave': 'NOMBRE'},
        {'label': 'COLEGIO', 'clave': 'COLEGIO'},
        {'label': 'DOCUMENTO', 'clave': 'DOCUMENTO'},
        {'label': 'EDAD', 'clave': 'EDAD'},
        {'label': 'FECHA NACIMIENTO', 'clave': 'FECHA_NACIMIENTO'},
        {'label': 'GÉNERO', 'clave': 'GENERO'},
        {'label': 'MUNICIPIO', 'clave': 'MUNICIPIO'},
        {'label': 'BARRIO', 'clave': 'BARRIO'},
        {'label': 'GRADO', 'clave': 'GRADO'},
        {'label': 'EPS', 'clave': 'EPS'},
        {'label': 'CURSO DE VIDA', 'clave': 'CURSO_VIDA'},
        {'label': 'FECHA RESPUESTA', 'clave': 'FECHA_RESPUESTA'},
      ];

      for (var col in kColumnasBasicasConLabel) {
        dynamicOrdenColumnas.add(col);
      }

      final bool esSrqOrCrq = categoria == 'CRQ' ||
          categoria == 'SRQ' ||
          categoria == 'CRQ / SRQ' ||
          categoria == 'RQC' ||
          categoria == 'RQC / SRQ' ||
          titulo.toUpperCase().contains('CRQ') ||
          titulo.toUpperCase().contains('SRQ') ||
          titulo.toUpperCase().contains('RQC');

      final List<String> alertasEspecialesNombres = [];
      if (esSrqOrCrq) {
        alertasEspecialesNombres.add('Ideación suicida');
        final alertasConfig = tamizajeData['alertasEspeciales'] as List? ?? [];
        for (var a in alertasConfig) {
          if (a is Map) {
            final nombre = a['nombre'] as String? ?? '';
            if (nombre.isNotEmpty &&
                !nombre.toLowerCase().contains('suicida')) {
              alertasEspecialesNombres.add(nombre);
            }
          }
        }
      }

      if (esSrqOrCrq) {
        for (var alertName in alertasEspecialesNombres) {
          final label = alertName.toUpperCase();
          final clave = sanitizeKey(alertName);
          dynamicOrdenColumnas.add({'label': label, 'clave': clave});
        }
      } else {
        for (var v in variables) {
          final labelValor = v.toUpperCase();
          final labelRiesgo = '${v.toUpperCase()} RIESGO';
          final claveValor = getSubstanceKey(v, 'VALOR');
          final claveRiesgo = getSubstanceKey(v, 'RIESGO');
          dynamicOrdenColumnas.add({'label': labelValor, 'clave': claveValor});
          dynamicOrdenColumnas
              .add({'label': labelRiesgo, 'clave': claveRiesgo});
        }
      }

      _ordenColumnas = dynamicOrdenColumnas;

      final Map<String, bool> dynamicColumnasVisibles = {};
      for (var col in dynamicOrdenColumnas) {
        dynamicColumnasVisibles[col['clave']!] = true;
      }
      _columnasVisibles = dynamicColumnasVisibles;

      final isProfesional =
          valueOrDefault(currentUserDocument?.rol, '') == 'Profesional';
      final profesionalRef = isProfesional ? currentUserReference : null;

      Set<DocumentReference>? patientRefs;
      if (profesionalRef != null) {
        final patientsSnap = await FirebaseFirestore.instance
            .collection('users')
            .where('Profesionales.Ref', isEqualTo: profesionalRef)
            .get();
        patientRefs = patientsSnap.docs
            .where((doc) => doc.data()['rol'] == 'Adolescente')
            .map((doc) => doc.reference)
            .toSet();
      }

      final respuestasSnapshot = await FirebaseFirestore.instance
          .collection('Encuestas')
          .doc(tamizajeId)
          .collection('Respuestas')
          .get();

      List<Map<String, dynamic>> respuestasProcesadas = [];

      for (var respuestaDoc in respuestasSnapshot.docs) {
        final respuestaData = respuestaDoc.data();
        final userRef = respuestaData['User_respuesta'] as DocumentReference?;

        if (userRef != null) {
          if (profesionalRef != null && !patientRefs!.contains(userRef)) {
            continue;
          }
          final userDoc = await userRef.get();
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;

            final resultados =
                procesarRespuestasTamizaje(tamizajeData, respuestaData);
            final resultadosCompletos =
                completarSustanciasFaltantes(resultados, variables);
            final registro = crearRegistroExcel(
              userData,
              resultadosCompletos,
              respuestaData,
              respuestasProcesadas.length + 1,
              variables,
            );

            if (esSrqOrCrq) {
              final disparadas =
                  respuestaData['alertasEspeciales'] as List? ?? [];
              final dispLower =
                  disparadas.map((d) => d.toString().toLowerCase()).toList();

              for (var alertName in alertasEspecialesNombres) {
                final clave = sanitizeKey(alertName);
                bool matches = false;
                if (alertName.toLowerCase() == 'ideación suicida') {
                  matches = dispLower.any(
                      (d) => d.contains('ideacion') || d.contains('suicida'));
                } else {
                  matches = dispLower.contains(alertName.toLowerCase());
                }
                registro[clave] = matches ? 'Sí' : 'No';
              }
            }

            respuestasProcesadas.add(registro);
          }
        }
      }

      _inicializarFiltros(respuestasProcesadas);

      setState(() {
        _respuestasProcesadas = respuestasProcesadas;
        _respuestasFiltradas = respuestasProcesadas;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar respuestas: $e';
        _cargando = false;
      });
    }
  }

  void _inicializarFiltros(List<Map<String, dynamic>> datos) {
    for (var columna in kColumnasFiltrables) {
      _filtros[columna] = {'Todos'};
      for (var registro in datos) {
        final valor = registro[columna]?.toString() ?? '';
        if (valor.isNotEmpty &&
            valor != 'No registrado' &&
            valor != 'No especificado' &&
            valor != 'No registrada') {
          _filtros[columna]!.add(valor);
        }
      }
    }
  }

  Widget _buildFiltroDropdown(String columna, String nombreDisplay) {
    final opciones = _filtros[columna]?.toList() ?? [];
    opciones.sort();

    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        value: _filtrosSeleccionados[columna] ?? 'Todos',
        decoration: InputDecoration(
          labelText: nombreDisplay,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          DropdownMenuItem(
            value: 'Todos',
            child: Text(
              'Todos los $nombreDisplay',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...opciones.where((opcion) => opcion != 'Todos').map((opcion) {
            return DropdownMenuItem(
              value: opcion,
              child: Text(
                opcion.length > 25 ? '${opcion.substring(0, 25)}...' : opcion,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ],
        onChanged: (String? nuevoValor) {
          setState(() {
            if (nuevoValor == 'Todos') {
              _filtrosSeleccionados.remove(columna);
            } else {
              _filtrosSeleccionados[columna] = nuevoValor!;
            }
          });
          _aplicarFiltros();
        },
      ),
    );
  }

  Future<void> _onExportarExcel() async {
    final datosAExportar = _respuestasFiltradas.isNotEmpty
        ? _respuestasFiltradas
        : _respuestasProcesadas;

    await exportarTamizajeAExcel(
      context: context,
      tamizajeNombre: widget.tamizajeNombre,
      datosAExportar: datosAExportar,
      columnasVisibles: _columnasVisibles,
      ordenColumnas: _ordenColumnas,
    );
  }

  @override
  Widget build(BuildContext context) {
    final datosMostrados = _respuestasFiltradas.isNotEmpty
        ? _respuestasFiltradas
        : _respuestasProcesadas;
    final tieneFiltrosActivos = _filtrosSeleccionados.isNotEmpty;
    final columnasVisiblesCount =
        _columnasVisibles.values.where((visible) => visible).length;

    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.tamizajeNombre != null &&
              widget.tamizajeNombre!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Tamizaje: ${widget.tamizajeNombre}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF265295),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      datosMostrados.isNotEmpty ? _onExportarExcel : null,
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: Text(
                    'Exportar Excel (${datosMostrados.length} registros${tieneFiltrosActivos ? ' filtrados' : ''})',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: datosMostrados.isNotEmpty
                        ? const Color(0xFF265295)
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _mostrarFiltros = !_mostrarFiltros;
                      if (_mostrarFiltros) _mostrarSeleccionColumnas = false;
                    });
                  },
                  icon: Icon(
                    _mostrarFiltros ? Icons.filter_alt_off : Icons.filter_alt,
                    color: Colors.white,
                  ),
                  label: Text(
                    _mostrarFiltros ? 'Ocultar Filtros' : 'Mostrar Filtros',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF265295),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _mostrarSeleccionColumnas = !_mostrarSeleccionColumnas;
                      if (_mostrarSeleccionColumnas) _mostrarFiltros = false;
                    });
                  },
                  icon: Icon(
                    _mostrarSeleccionColumnas
                        ? Icons.view_week_outlined
                        : Icons.view_week,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Columnas ($columnasVisiblesCount/${_columnasVisibles.length})',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF265295),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                ),
                if (tieneFiltrosActivos)
                  ElevatedButton.icon(
                    onPressed: _limpiarFiltros,
                    icon: const Icon(Icons.clear_all, color: Colors.white),
                    label: const Text(
                      'Limpiar Filtros',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                  ),
              ],
            ),
          ),
          if (_mostrarFiltros && !_cargando && _respuestasProcesadas.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtros de Datos:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF265295),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _buildFiltroDropdown('COLEGIO', 'Colegio'),
                      _buildFiltroDropdown('GENERO', 'Género'),
                      _buildFiltroDropdown('MUNICIPIO', 'Municipio'),
                      _buildFiltroDropdown('BARRIO', 'Barrio'),
                      _buildFiltroDropdown('GRADO', 'Grado'),
                      _buildFiltroDropdown('EPS', 'EPS'),
                      _buildFiltroDropdown('CURSO_VIDA', 'Curso de Vida'),
                    ],
                  ),
                  if (tieneFiltrosActivos) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Mostrando ${datosMostrados.length} de ${_respuestasProcesadas.length} registros',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (_mostrarSeleccionColumnas && !_cargando)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seleccionar Columnas Visibles:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF265295),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: _ordenColumnas.map((columna) {
                      final clave = columna['clave']!;
                      final label = columna['label']!;
                      final visible = _columnasVisibles[clave] ?? true;
                      return FilterChip(
                        label: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: visible,
                        onSelected: (bool selected) {
                          setState(() {
                            _columnasVisibles[clave] = selected;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF265295),
                        labelStyle: TextStyle(
                          color: visible ? Colors.white : Colors.black87,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$columnasVisiblesCount de ${_columnasVisibles.length} columnas seleccionadas',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando respuestas...'),
                  ],
                ),
              ),
            ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error,
                  style: TextStyle(color: Colors.orange[800]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (!_cargando && datosMostrados.isNotEmpty)
            Expanded(
              child: Scrollbar(
                controller: _scrollControllerVertical,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollControllerVertical,
                  scrollDirection: Axis.vertical,
                  child: Scrollbar(
                    controller: _scrollControllerHorizontal,
                    thumbVisibility: true,
                    trackVisibility: true,
                    notificationPredicate: (notif) => notif.depth == 0,
                    child: SingleChildScrollView(
                      controller: _scrollControllerHorizontal,
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: DataTable(
                          columns: buildDataColumns(
                              _ordenColumnas, _columnasVisibles),
                          rows: buildDataRows(
                            datos: datosMostrados,
                            ordenColumnas: _ordenColumnas,
                            columnasVisibles: _columnasVisibles,
                          ),
                          headingRowColor: MaterialStateProperty.all(
                              const Color(0xFF265295)),
                          dataRowColor:
                              MaterialStateProperty.all(Colors.transparent),
                          border: TableBorder.all(color: Colors.grey.shade300),
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          dataTextStyle: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                          columnSpacing: 20,
                          horizontalMargin: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (!_cargando && datosMostrados.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  const Text(
                    'El archivo Excel incluye todos los campos de riesgo con colores pastel según el nivel de alarma.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    children: [
                      buildLeyendaColor('Sin alarma', const Color(0xFFD3D3D3)),
                      buildLeyendaColor('Bajo', const Color(0xFFC8E6C9)),
                      buildLeyendaColor('Moderado', const Color(0xFFFFF9C4)),
                      buildLeyendaColor('Alto', const Color(0xFFFFCDD2)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
