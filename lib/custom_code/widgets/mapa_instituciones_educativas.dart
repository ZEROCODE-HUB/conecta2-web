// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/tamizajes/shared/tamizaje_service.dart';
import 'mapa_helpers.dart';

part 'mapa_barrio_dialog.dart';
part 'mapa_detalle_helpers.dart';

/// Mapa de intervención (Estadísticas → Mapa del panel web).
///
/// Un colegio está "intervenido" si alguno de sus adolescentes visibles (todos
/// para el administrador; los asignados para el profesional) tiene al menos un
/// tamizaje respondido y no invalidado, incluidos los tamizajes manuales.
class MapaInstitucionesEducativas extends StatefulWidget {
  const MapaInstitucionesEducativas({
    Key? key,
    this.width,
    this.height,
    required this.googleMapsApiKey,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String googleMapsApiKey;

  @override
  _MapaInstitucionesEducativasState createState() =>
      _MapaInstitucionesEducativasState();
}

class _MapaInstitucionesEducativasState
    extends State<MapaInstitucionesEducativas> {
  // Centro inicial mientras cargan los colegios (todos están en Cartagena).
  static const _centroInicial = gm.LatLng(10.3932, -75.4832);

  gm.GoogleMapController? mapController;
  Set<gm.Marker> markers = {};

  /// Municipio y barrio elegidos, normalizados con [normalizarTexto].
  String? municipioSeleccionado;
  String? barrioSeleccionado;
  int? anoSeleccionado;
  bool isLoading = true;
  bool errorCarga = false;
  bool isDialogOpen = false;

  /// Colegios del catálogo con coordenadas válidas, uno por nombre.
  List<Map<String, dynamic>> instituciones = [];

  /// Colegios del catálogo con coordenadas inválidas: clave → datos.
  Map<String, Map<String, dynamic>> colegiosSinCoordenadas = {};

  /// Nombre del colegio tal como lo escribió el adolescente: clave → nombre.
  Map<String, String> nombreColegioAdolescente = {};

  /// Adolescentes visibles por colegio: clave → rutas `users/{id}`.
  Map<String, Set<String>> adolescentesPorColegio = {};

  /// Respuestas válidas de tamizaje de los adolescentes visibles.
  List<RespuestaMapa> respuestas = [];

  Color get primaryColor => FlutterFlowTheme.of(context).primary;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final yo = currentUserReference;
      final rol = currentUserDocument?.rol ??
          (yo == null ? '' : (await UsersRecord.getDocumentOnce(yo)).rol);
      final esProfesional = rol == FFAppConstants.Profesional && yo != null;

      final colegiosFuture =
          FirebaseFirestore.instance.collection('colegios').get();
      final tamizajesFuture = queryEncuestasRecordOnce(
        queryBuilder: (q) => q.where('tipo', isEqualTo: 'Tamizajes'),
      );
      final usuariosFuture = queryUsersRecordOnce(
        queryBuilder: (q) => esProfesional
            ? q.where('Profesionales.Ref', isEqualTo: yo)
            : q.where('rol', isEqualTo: FFAppConstants.adolescente),
      );

      final adolescentes = (await usuariosFuture)
          .where((u) => u.rol == FFAppConstants.adolescente)
          .toList();
      final colegioPorUsuario = <String, String>{};
      final porColegio = <String, Set<String>>{};
      final nombresAdolescentes = <String, String>{};
      for (final u in adolescentes) {
        final clave = normalizarTexto(u.colegio);
        if (clave.isEmpty) continue;
        colegioPorUsuario[u.reference.path] = clave;
        porColegio.putIfAbsent(clave, () => {}).add(u.reference.path);
        nombresAdolescentes.putIfAbsent(clave, () => u.colegio.trim());
      }

      final tituloPorTamizaje = {
        for (final e in await tamizajesFuture) e.reference.id: e.titulo.trim(),
      };
      final idsTamizaje = tituloPorTamizaje.keys.toSet();

      // Respuestas de los adolescentes, en lotes de 30 (límite de whereIn).
      final refs = adolescentes.map((u) => u.reference).toList();
      final lotes = await Future.wait([
        for (var i = 0; i < refs.length; i += 30)
          queryRespuestasRecordOnce(
            queryBuilder: (q) => q.where(
              'User_respuesta',
              whereIn:
                  refs.sublist(i, i + 30 > refs.length ? refs.length : i + 30),
            ),
          ),
      ]);
      final respuestasTemp = <RespuestaMapa>[];
      for (final r in lotes.expand((l) => l)) {
        if (r.invalidado) continue;
        if (!TamizajeService.esRespuestaDeTamizaje(r, idsTamizaje)) continue;
        final usuario = r.userRespuesta?.path;
        final colegio = colegioPorUsuario[usuario];
        if (usuario == null || colegio == null) continue;
        final titulo = tituloPorTamizaje[r.reference.parent.parent!.id] ?? '';
        respuestasTemp.add(RespuestaMapa(
          usuario: usuario,
          colegio: colegio,
          tamizaje: (titulo.isNotEmpty ? titulo : r.titlo.trim()).toUpperCase(),
          fecha: r.fecha,
        ));
      }

      final institucionesTemp = <Map<String, dynamic>>[];
      final sinCoordenadas = <String, Map<String, dynamic>>{};
      final vistos = <String>{};
      for (final doc in (await colegiosFuture).docs) {
        final data = doc.data();
        final nombre = data['nombre']?.toString().trim() ?? '';
        final clave = normalizarTexto(nombre);
        if (clave.isEmpty || vistos.contains(clave)) continue;
        final latitud = parseCoordenada(data['latitud'], esLatitud: true);
        final longitud = parseCoordenada(data['longitud'], esLatitud: false);
        final institucion = {
          'id': doc.id,
          'clave': clave,
          'nombre': nombre,
          'tipo': data['sector']?.toString().trim() ?? 'DESCONOCIDO',
          'barrio': data['barrio']?.toString().trim() ?? 'Sin barrio',
          'direccion': data['direccion']?.toString().trim() ?? 'Sin dirección',
          'codigo': data['cod_dane']?.toString().trim() ?? '',
          'municipio': data['municipio']?.toString().trim() ?? '',
          'latitudTexto': data['latitud']?.toString() ?? '',
          'longitudTexto': data['longitud']?.toString() ?? '',
          'latitud': latitud,
          'longitud': longitud,
        };
        if (latitud == null || longitud == null) {
          // Puede haber otra copia del colegio con coordenadas válidas.
          sinCoordenadas.putIfAbsent(clave, () => institucion);
          continue;
        }
        vistos.add(clave);
        sinCoordenadas.remove(clave);
        institucionesTemp.add(institucion);
      }

      if (!mounted) return;
      setState(() {
        instituciones = institucionesTemp;
        colegiosSinCoordenadas = sinCoordenadas;
        nombreColegioAdolescente = nombresAdolescentes;
        adolescentesPorColegio = porColegio;
        respuestas = respuestasTemp;
        isLoading = false;
      });
      _updateMarkers();
    } catch (e) {
      debugPrint('Mapa de intervención: error al cargar: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorCarga = true;
      });
    }
  }

  /// Colegios intervenidos en el año elegido, con municipio y barrio
  /// filtrados.
  List<Map<String, dynamic>> get institucionesFiltradas {
    final intervenidos = colegiosIntervenidos(respuestas, anoSeleccionado);
    return instituciones.where((institucion) {
      if (!intervenidos.contains(institucion['clave'])) return false;
      final matchMunicipio = municipioSeleccionado == null ||
          normalizarTexto(institucion['municipio']) == municipioSeleccionado;
      final matchBarrio = barrioSeleccionado == null ||
          normalizarTexto(institucion['barrio']) == barrioSeleccionado;
      return matchMunicipio && matchBarrio;
    }).toList();
  }

  /// Municipios de los colegios intervenidos: clave → nombre para mostrar.
  Map<String, String> get municipiosDisponibles {
    final intervenidos = colegiosIntervenidos(respuestas, null);
    final resultado = <String, String>{};
    for (final i in instituciones) {
      if (!intervenidos.contains(i['clave'])) continue;
      final clave = normalizarTexto(i['municipio']);
      if (clave.isEmpty) continue;
      resultado.putIfAbsent(clave, () => enFormatoTitulo(i['municipio']));
    }
    return Map.fromEntries(
        resultado.entries.toList()..sort((a, b) => a.value.compareTo(b.value)));
  }

  /// Barrios de los colegios intervenidos del municipio elegido: clave →
  /// nombre para mostrar.
  Map<String, String> get barriosDisponibles {
    if (municipioSeleccionado == null) return {};
    final intervenidos = colegiosIntervenidos(respuestas, anoSeleccionado);
    final resultado = <String, String>{};
    for (final i in instituciones) {
      if (!intervenidos.contains(i['clave'])) continue;
      if (normalizarTexto(i['municipio']) != municipioSeleccionado) continue;
      final clave = normalizarTexto(i['barrio']);
      if (clave.isEmpty) continue;
      resultado.putIfAbsent(clave, () => (i['barrio'] as String).trim());
    }
    return Map.fromEntries(
        resultado.entries.toList()..sort((a, b) => a.value.compareTo(b.value)));
  }

  List<int> get anosDisponibles => anosConRespuestas(respuestas);

  /// Colegios intervenidos en el año elegido que no se pueden poner en el
  /// mapa, con el motivo.
  List<({String nombre, String motivo})> get colegiosSinUbicar {
    final ubicados = instituciones.map((i) => i['clave'] as String).toSet();
    final resultado = <({String nombre, String motivo})>[];
    for (final clave in colegiosIntervenidos(respuestas, anoSeleccionado)) {
      if (ubicados.contains(clave)) continue;
      final sinCoordenadas = colegiosSinCoordenadas[clave];
      resultado.add(sinCoordenadas != null
          ? (
              nombre: sinCoordenadas['nombre'] as String,
              motivo: 'Coordenadas inválidas en Instituciones '
                  '(latitud "${sinCoordenadas['latitudTexto']}", '
                  'longitud "${sinCoordenadas['longitudTexto']}").',
            )
          : (
              nombre: nombreColegioAdolescente[clave] ?? clave,
              motivo: 'El colegio del adolescente no está en el catálogo de '
                  'Instituciones.',
            ));
    }
    return resultado..sort((a, b) => a.nombre.compareTo(b.nombre));
  }

  void _updateMarkers() {
    final newMarkers = <gm.Marker>{
      for (final institucion in institucionesFiltradas)
        gm.Marker(
          markerId: gm.MarkerId(institucion['id']),
          position: gm.LatLng(institucion['latitud'], institucion['longitud']),
          icon: gm.BitmapDescriptor.defaultMarker,
          onTap: () {
            if (!isDialogOpen) _mostrarDetalleInstitucion(institucion);
          },
          infoWindow: gm.InfoWindow(
            title: institucion['nombre'],
            snippet: 'Toca para ver detalles',
            onTap: () {
              if (!isDialogOpen) _mostrarDetalleInstitucion(institucion);
            },
          ),
        ),
    };
    setState(() {
      markers = newMarkers;
    });
    _encuadrarMarcadores();
  }

  /// Mueve la cámara para que se vean todos los marcadores.
  void _encuadrarMarcadores() {
    final controller = mapController;
    if (controller == null || markers.isEmpty) return;
    final posiciones = markers.map((m) => m.position).toList();
    if (posiciones.length == 1) {
      controller
          .animateCamera(gm.CameraUpdate.newLatLngZoom(posiciones.first, 15));
      return;
    }
    var sur = posiciones.first.latitude, norte = sur;
    var oeste = posiciones.first.longitude, este = oeste;
    for (final p in posiciones) {
      if (p.latitude < sur) sur = p.latitude;
      if (p.latitude > norte) norte = p.latitude;
      if (p.longitude < oeste) oeste = p.longitude;
      if (p.longitude > este) este = p.longitude;
    }
    controller.animateCamera(gm.CameraUpdate.newLatLngBounds(
      gm.LatLngBounds(
        southwest: gm.LatLng(sur, oeste),
        northeast: gm.LatLng(norte, este),
      ),
      80,
    ));
  }

  void _onMapCreated(gm.GoogleMapController controller) {
    mapController = controller;
    _encuadrarMarcadores();
  }

  // Método para mostrar el selector de barrios con búsqueda
  void _mostrarSelectorBarrios() {
    final disponibles = barriosDisponibles;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SearchableBarrioDialog(
          barrios: disponibles.values.toList(),
          barrioSeleccionado: disponibles[barrioSeleccionado],
          onBarrioSelected: (String? barrio) {
            barrioSeleccionado =
                barrio == null ? null : normalizarTexto(barrio);
            _updateMarkers();
          },
        );
      },
    );
  }

  void _mostrarColegiosSinUbicar() {
    final lista = colegiosSinUbicar;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Colegios intervenidos sin ubicar'),
        content: SizedBox(
          width: 420,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Tienen tamizajes pero no se pueden mostrar en el mapa. '
                'Corrígelos en Instituciones.',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              SizedBox(height: 12),
              for (final c in lista)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.warning_amber_rounded,
                      color: Colors.orange[700]),
                  title: Text(c.nombre, style: TextStyle(fontSize: 14)),
                  subtitle: Text(c.motivo, style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final municipios = municipiosDisponibles;
    final barrios = barriosDisponibles;
    final anos = anosDisponibles;
    final sinUbicar = colegiosSinUbicar;
    return Container(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          AbsorbPointer(
            absorbing: isDialogOpen,
            child: gm.GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: gm.CameraPosition(
                target: _centroInicial,
                zoom: 12.5,
              ),
              markers: markers,
              mapType: gm.MapType.normal,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: !isDialogOpen,
              compassEnabled: !isDialogOpen,
              zoomGesturesEnabled: !isDialogOpen,
              scrollGesturesEnabled: !isDialogOpen,
              tiltGesturesEnabled: !isDialogOpen,
              rotateGesturesEnabled: !isDialogOpen,
            ),
          ),
          if (isDialogOpen)
            Container(
              color: Colors.black54,
            ),
          if (isLoading || errorCarga || (!isLoading && markers.isEmpty))
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoading) ...[
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                      Text(isLoading
                          ? 'Cargando lugares intervenidos...'
                          : errorCarga
                              ? 'No se pudieron cargar los datos del mapa.'
                              : 'No hay colegios intervenidos con estos filtros.'),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: municipios.containsKey(municipioSeleccionado)
                            ? municipioSeleccionado
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Municipio',
                          prefixIcon: Icon(Icons.location_city, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child:
                                Text('Todos', style: TextStyle(fontSize: 14)),
                          ),
                          for (final m in municipios.entries)
                            DropdownMenuItem<String>(
                              value: m.key,
                              child:
                                  Text(m.value, style: TextStyle(fontSize: 14)),
                            ),
                        ],
                        onChanged: (String? newValue) {
                          municipioSeleccionado = newValue;
                          barrioSeleccionado = null;
                          _updateMarkers();
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    // Campo de barrio con búsqueda
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: municipioSeleccionado == null
                            ? null
                            : _mostrarSelectorBarrios,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Barrio',
                            prefixIcon: Icon(Icons.map, size: 20),
                            suffixIcon: barrioSeleccionado != null
                                ? IconButton(
                                    icon: Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      barrioSeleccionado = null;
                                      _updateMarkers();
                                    },
                                    padding: EdgeInsets.zero,
                                  )
                                : Icon(Icons.arrow_drop_down, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            isDense: true,
                            enabled: municipioSeleccionado != null,
                          ),
                          child: Text(
                            barrios[barrioSeleccionado] ?? 'Todos',
                            style: TextStyle(
                              fontSize: 14,
                              color: municipioSeleccionado == null
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<int>(
                        value: anos.contains(anoSeleccionado)
                            ? anoSeleccionado
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Año del tamizaje',
                          prefixIcon: Icon(Icons.calendar_today, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem<int>(
                            value: null,
                            child:
                                Text('Todos', style: TextStyle(fontSize: 14)),
                          ),
                          for (final ano in anos)
                            DropdownMenuItem<int>(
                              value: ano,
                              child:
                                  Text('$ano', style: TextStyle(fontSize: 14)),
                            ),
                        ],
                        onChanged: (int? newValue) {
                          anoSeleccionado = newValue;
                          if (!barriosDisponibles
                              .containsKey(barrioSeleccionado)) {
                            barrioSeleccionado = null;
                          }
                          _updateMarkers();
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Tooltip(
                      message: 'Colegios intervenidos en el mapa',
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.school,
                              color: primaryColor,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '${markers.length}',
                              style: TextStyle(
                                fontSize: 16,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (sinUbicar.isNotEmpty) ...[
                      SizedBox(width: 8),
                      Tooltip(
                        message: 'Colegios intervenidos que no se pueden '
                            'mostrar en el mapa',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _mostrarColegiosSinUbicar,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.orange[800], size: 18),
                                SizedBox(width: 6),
                                Text(
                                  '${sinUbicar.length} sin ubicar',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
