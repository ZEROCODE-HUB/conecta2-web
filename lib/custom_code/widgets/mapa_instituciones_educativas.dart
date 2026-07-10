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


part 'mapa_barrio_dialog.dart';
part 'mapa_detalle_helpers.dart';

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
  gm.GoogleMapController? mapController;
  Set<gm.Marker> markers = {};

  String? municipioSeleccionado;
  String? barrioSeleccionado;
  int? anoSeleccionado;
  bool isLoadingData = true;
  bool isDialogOpen = false;

  // Lista de instituciones cargadas desde Firebase
  List<Map<String, dynamic>> instituciones = [];
  bool isLoadingInstituciones = true;

  // Lista de barrios cargados desde Firebase
  List<Map<String, dynamic>> barrios = [];
  bool isLoadingBarrios = true;

  // Datos de municipios con coordenadas específicas
  final Map<String, Map<String, dynamic>> municipios = {
    'Cartagena': {
      'centro': gm.LatLng(10.3932, -75.4832),
      'zoom': 12.5,
    },
    'Bucaramanga': {
      'centro': gm.LatLng(7.1193, -73.1227),
      'zoom': 12.5,
    },
    'Montería': {
      'centro': gm.LatLng(8.7479, -75.8814),
      'zoom': 12.5,
    },
    'Cúcuta': {
      'centro': gm.LatLng(7.8939, -72.5078),
      'zoom': 12.5,
    },
    'Barrancabermeja': {
      'centro': gm.LatLng(7.0653, -73.8547),
      'zoom': 12.5,
    },
  };

  // Color primario por defecto para evitar valores nulos
  Color get primaryColor => FlutterFlowTheme.of(context).primary ?? Colors.blue;

  @override
  void initState() {
    super.initState();

    // Test de parseo de coordenadas
    print('🧪 Probando parseo de coordenadas:');
    print('  "1.039.606" -> ${_parseCoordinate("1.039.606")}');
    print('  "-7.546.132" -> ${_parseCoordinate("-7.546.132")}');
    print('  "10.39033" -> ${_parseCoordinate("10.39033")}');

    _cargarBarrios();
    _cargarInstituciones();
  }

  // Función para obtener colegios que tienen tamizajes (lugares intervenidos)
  Future<Set<String>> _obtenerColegiosConTamizaje() async {
    Set<String> colegiosConTamizaje = {};
    try {
      print('📋 Buscando todos los tamizajes para filtrar mapa...');
      final tamizajesSnapshot = await FirebaseFirestore.instance
          .collection('Encuestas')
          .where('tipo', isEqualTo: 'Tamizajes')
          .where('Publicado', isEqualTo: true)
          .get();

      Set<String> userPaths = {};
      for (var doc in tamizajesSnapshot.docs) {
        final data = doc.data();
        final userRefList = data['user_Ref'] as List<dynamic>? ?? [];
        for (var userRef in userRefList) {
          if (userRef is DocumentReference) {
            userPaths.add(userRef.path);
          }
        }
      }

      print('👥 Usuarios únicos con tamizajes: ${userPaths.length}');

      if (userPaths.isEmpty) return {};

      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      
      for (var doc in usersSnapshot.docs) {
        if (userPaths.contains(doc.reference.path)) {
          final data = doc.data();
          final colegio = data['colegio']?.toString().trim();
          if (colegio != null && colegio.isNotEmpty) {
            colegiosConTamizaje.add(colegio);
          }
        }
      }
      
      print('🏫 Colegios con tamizajes encontrados: ${colegiosConTamizaje.length}');
      
    } catch (e) {
      print('❌ Error obteniendo colegios con tamizaje: $e');
    }
    return colegiosConTamizaje;
  }

  // Función para cargar barrios desde Firebase
  Future<void> _cargarBarrios() async {
    try {
      setState(() {
        isLoadingBarrios = true;
      });

      final querySnapshot =
          await FirebaseFirestore.instance.collection('barrios').get();

      List<Map<String, dynamic>> barriosTemp = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        barriosTemp.add({
          'nombre': data['nombre'] ?? 'Sin nombre',
          'municipio': data['municipio'] ?? 'Desconocido',
        });
      }

      print('✅ Total barrios cargados: ${barriosTemp.length}');

      setState(() {
        barrios = barriosTemp;
        isLoadingBarrios = false;
      });
    } catch (e) {
      print('Error cargando barrios: $e');
      setState(() {
        isLoadingBarrios = false;
      });
    }
  }

  // Función para cargar instituciones desde Firebase
  Future<void> _cargarInstituciones() async {
    try {
      setState(() {
        isLoadingInstituciones = true;
      });

      // Obtener colegios intervenidos (con tamizajes)
      Set<String> colegiosConTamizaje = await _obtenerColegiosConTamizaje();

      final querySnapshot =
          await FirebaseFirestore.instance.collection('colegios').get();

      List<Map<String, dynamic>> institucionesTemp = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final nombreColegio = data['nombre']?.toString().trim() ?? 'Sin nombre';

        // Filtrar: Solo agregar si el colegio está en la lista de colegios con tamizaje
        if (!colegiosConTamizaje.contains(nombreColegio)) continue;

        // Parsear latitud y longitud desde strings
        double? latitud = _parseCoordinate(data['latitud']);
        double? longitud = _parseCoordinate(data['longitud']);

        // Solo agregar si tiene coordenadas válidas y dentro de rangos razonables para Colombia
        if (latitud != null &&
            longitud != null &&
            _esCoordenadaValida(latitud, longitud)) {
          institucionesTemp.add({
            'nombre': data['nombre']?.toString().trim() ?? 'Sin nombre',
            'tipo': data['sector']?.toString().trim() ?? 'DESCONOCIDO',
            'barrio': data['barrio']?.toString().trim() ?? 'Sin barrio',
            'direccion':
                data['direccion']?.toString().trim() ?? 'Sin dirección',
            'codigo': data['cod_dane']?.toString().trim() ?? '',
            'municipio': data['municipio']?.toString().trim() ?? 'Desconocido',
            'latitud': latitud,
            'longitud': longitud,
            'id': doc.id, // Agregar ID del documento para mayor control
          });
        } else {
          print(
              '⚠️ Coordenadas inválidas para: ${data['nombre']} - Lat: $latitud, Lng: $longitud');
        }
      }

      print('✅ Total instituciones cargadas: ${institucionesTemp.length}');
      print('📊 Primeras 3 instituciones:');
      for (int i = 0;
          i < (institucionesTemp.length < 3 ? institucionesTemp.length : 3);
          i++) {
        print('   ${i + 1}. ${institucionesTemp[i]['nombre']}');
        print(
            '      Lat: ${institucionesTemp[i]['latitud']}, Lng: ${institucionesTemp[i]['longitud']}');
        print('      Barrio: ${institucionesTemp[i]['barrio']}');
        print('      Municipio: ${institucionesTemp[i]['municipio']}');
      }

      setState(() {
        instituciones = institucionesTemp;
        isLoadingInstituciones = false;
      });

      _updateMarkers();
    } catch (e) {
      print('Error cargando instituciones: $e');
      setState(() {
        isLoadingInstituciones = false;
      });
    }
  }

  // Función para validar si las coordenadas están dentro de rangos razonables para Colombia
  bool _esCoordenadaValida(double latitud, double longitud) {
    // Colombia está aproximadamente entre latitud -4 y 13, longitud -79 y -67
    return latitud >= -4.0 &&
        latitud <= 13.0 &&
        longitud >= -79.0 &&
        longitud <= -67.0;
  }

  // Función auxiliar para parsear coordenadas
  double? _parseCoordinate(dynamic value) {
    if (value == null) return null;

    try {
      // Si ya es un número
      if (value is num) return value.toDouble();

      // Si es string, limpiar y convertir
      if (value is String) {
        String cleaned = value.trim();

        // Si está vacío, retornar null
        if (cleaned.isEmpty) return null;

        // El formato parece ser: "1.039.606" para latitud y "-7.546.132" para longitud
        // Esto significa: latitud = 1.039606 y longitud = -75.46132

        // Contar puntos
        int puntoCount = '.'.allMatches(cleaned).length;

        if (puntoCount <= 1) {
          // Formato normal de decimal
          return double.parse(cleaned);
        } else {
          // Múltiples puntos - son separadores de miles
          // Simplemente remover todos los puntos excepto el último

          // Guardar el signo si existe
          bool isNegative = cleaned.startsWith('-');
          if (isNegative) {
            cleaned = cleaned.substring(1);
          }

          // Encontrar la posición del último punto
          int lastDotIndex = cleaned.lastIndexOf('.');

          // Remover todos los puntos
          String sinPuntos = cleaned.replaceAll('.', '');

          // Calcular cuántos dígitos decimales había después del último punto
          int decimales = cleaned.length - lastDotIndex - 1;

          // Insertar el punto decimal en la posición correcta
          String resultado;
          if (decimales > 0 && sinPuntos.length > decimales) {
            int posicionDecimal = sinPuntos.length - decimales;
            resultado = sinPuntos.substring(0, posicionDecimal) +
                '.' +
                sinPuntos.substring(posicionDecimal);
          } else {
            resultado = sinPuntos;
          }

          double valor = double.parse(resultado);
          return isNegative ? -valor : valor;
        }
      }
    } catch (e) {
      print('❌ Error parseando coordenada: $value - $e');
    }

    return null;
  }

  List<Map<String, dynamic>> get institucionesFiltradas {
    return instituciones.where((institucion) {
      bool matchMunicipio = municipioSeleccionado == null ||
          (institucion['municipio']?.toString().toUpperCase() ==
              municipioSeleccionado?.toUpperCase());

      bool matchBarrio = barrioSeleccionado == null ||
          (institucion['barrio']?.toString().toUpperCase() ==
              barrioSeleccionado?.toUpperCase());

      return matchMunicipio && matchBarrio;
    }).toList();
  }

  /// Anos disponibles basados en created_time de los usuarios. Por defecto
  /// usa los ultimos 5 anos desde hoy para no requerir query adicional.
  List<int> get anosDisponibles {
    final currentYear = DateTime.now().year;
    return List<int>.generate(5, (i) => currentYear - i);
  }

  List<String> get barriosDisponibles {
    if (municipioSeleccionado == null) return [];

    // Obtener barrios desde la colección "barrios" filtrados por municipio
    final barriosFiltrados = barrios
        .where((barrio) =>
            barrio['municipio']?.toString().toUpperCase() ==
            municipioSeleccionado?.toUpperCase())
        .map((barrio) => barrio['nombre'] as String)
        .toSet()
        .toList();

    barriosFiltrados.sort();
    return barriosFiltrados;
  }

  // MÉTODO OPTIMIZADO Y CORREGIDO: Obtener estadísticas de la institución
  Future<Map<String, dynamic>> _getInstitucionStats(
      String nombreInstitucion) async {
    try {
      print('🔍 Obteniendo estadísticas para: $nombreInstitucion');

      // Obtener rol del usuario actual
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();
      final userRol = userDoc.data()?['rol'] as String?;

      List<QueryDocumentSnapshot> usuariosInstitucion = [];

      if (userRol == 'Profesional') {
        // Filtrar solo los pacientes asignados
        final pacientesSnap = await FirebaseFirestore.instance
            .collection('users')
            .where('Profesionales.Ref', isEqualTo: userDoc.reference)
            .get();
            
        // Filtrar los que pertenecen a esta institución (ignorando espacios/mayúsculas)
        usuariosInstitucion = pacientesSnap.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return false;
          final col = (data['colegio']?.toString() ?? '').trim().toLowerCase();
          return col == nombreInstitucion.trim().toLowerCase();
        }).toList();
      } else {
        // Para Administrador (u otros): buscar TODOS los estudiantes de esta institución
        // Como 'colegio' puede tener espacios extras, usamos una consulta más amplia
        final allUsersSnap = await FirebaseFirestore.instance
            .collection('users')
            .where('rol', isEqualTo: 'Adolescente')
            .get();
            
        usuariosInstitucion = allUsersSnap.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return false;
          final col = (data['colegio']?.toString() ?? '').trim().toLowerCase();
          return col == nombreInstitucion.trim().toLowerCase();
        }).toList();
      }

      print('👥 Usuarios encontrados en la institución ($userRol): ${usuariosInstitucion.length}');

      // Filtrar por año si está seleccionado
      List<QueryDocumentSnapshot> usuariosFiltrados = usuariosInstitucion;
      if (anoSeleccionado != null) {
        usuariosFiltrados = usuariosInstitucion.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return false;
          final createdTime = data['created_time'] as Timestamp?;
          if (createdTime != null) {
            return createdTime.toDate().year == anoSeleccionado;
          }
          return false;
        }).toList();
        print(
            '📅 Usuarios filtrados por año $anoSeleccionado: ${usuariosFiltrados.length}');
      }

      final totalUsuariosFiltrados = usuariosFiltrados.length;
      final userPaths =
          usuariosFiltrados.map((doc) => doc.reference.path).toSet();

      print('🔍 User paths a buscar: ${userPaths.length}');

      // 2. Buscar tamizajes respondidos por estos usuarios
      Map<String, Map<String, dynamic>> tamizajesRespondidosMap = {};

      final patientRefs = usuariosFiltrados.map((doc) => doc.reference).toList();
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> allRespuestas = [];

      const chunkSize = 30;
      final chunks = <List<DocumentReference>>[];
      for (var i = 0; i < patientRefs.length; i += chunkSize) {
        chunks.add(patientRefs.sublist(
          i,
          i + chunkSize > patientRefs.length ? patientRefs.length : i + chunkSize,
        ));
      }

      print('📋 Buscando respuestas para ${patientRefs.length} usuarios en ${chunks.length} lotes...');

      final queryTasks = chunks.map((chunk) {
        return FirebaseFirestore.instance
            .collectionGroup('Respuestas')
            .where('User_respuesta', whereIn: chunk)
            .get();
      });

      final queryResults = await Future.wait(queryTasks);
      for (var res in queryResults) {
        allRespuestas.addAll(res.docs);
      }

      for (var respuestaDoc in allRespuestas) {
        final data = respuestaDoc.data();
        if ((data['invalidado'] as bool?) == true) continue;

        final titulo = (data['Titlo'] ?? data['titlo'] ?? '').toString();
        if (titulo.isEmpty) continue;

        if (!tamizajesRespondidosMap.containsKey(titulo)) {
          tamizajesRespondidosMap[titulo] = {'respuestas': 0};
        }
        tamizajesRespondidosMap[titulo]!['respuestas'] = (tamizajesRespondidosMap[titulo]!['respuestas'] as int) + 1;
      }

      // Extraer listas para retornar
      Map<String, int> respuestasPorTamizaje = {};
      List<String> tamizajesRespondidos = [];

      tamizajesRespondidosMap.forEach((titulo, data) {
        respuestasPorTamizaje[titulo] = data['respuestas'] as int;
        tamizajesRespondidos.add(titulo);
      });

      print('📊 Resultado final para $nombreInstitucion:');
      print('   - Total usuarios: $totalUsuariosFiltrados');
      print('   - Tamizajes respondidos: ${tamizajesRespondidos.length}');
      print('   - Respuestas por tamizaje: $respuestasPorTamizaje');

      return {
        'totalUsuarios': totalUsuariosFiltrados,
        'respuestasPorTamizaje': respuestasPorTamizaje,
        'tamizajesRespondidos': tamizajesRespondidos,
      };
    } catch (e) {
      print('❌ Error getting institution stats: $e');
      return {
        'totalUsuarios': 0,
        'respuestasPorTamizaje': {},
        'tamizajesRespondidos': [],
      };
    }
  }

  void _updateMarkers() {
    final institucionesMostrar = institucionesFiltradas;

    print('🗺️ Actualizando marcadores...');
    print('   Instituciones filtradas: ${institucionesMostrar.length}');
    print('   Total instituciones en base: ${instituciones.length}');

    Set<gm.Marker> newMarkers = {};

    for (var institucion in institucionesMostrar) {
      // Crear marcador único con ID que incluya el ID del documento
      String markerId = '${institucion['id']}_${institucion['nombre']}';

      newMarkers.add(
        gm.Marker(
          markerId: gm.MarkerId(markerId),
          position: gm.LatLng(
            institucion['latitud'],
            institucion['longitud'],
          ),
          icon: gm.BitmapDescriptor.defaultMarker,
          onTap: () {
            if (!isDialogOpen) {
              _mostrarDetalleInstitucion(institucion);
            }
          },
          infoWindow: gm.InfoWindow(
            title: institucion['nombre'],
            snippet: 'Toca para ver detalles',
            onTap: () {
              if (!isDialogOpen) {
                _mostrarDetalleInstitucion(institucion);
              }
            },
          ),
        ),
      );
    }

    print('   ✅ Total marcadores creados: ${newMarkers.length}');

    setState(() {
      markers = newMarkers;
    });

    if (municipioSeleccionado != null && mapController != null) {
      final dataMunicipio = municipios[municipioSeleccionado];
      if (dataMunicipio != null) {
        mapController!.animateCamera(
          gm.CameraUpdate.newCameraPosition(
            gm.CameraPosition(
              target: dataMunicipio['centro'],
              zoom: dataMunicipio['zoom'],
            ),
          ),
        );
      }
    }
  }


  void _onMapCreated(gm.GoogleMapController controller) {
    mapController = controller;
  }

  // Método para mostrar el selector de barrios con búsqueda
  void _mostrarSelectorBarrios() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SearchableBarrioDialog(
          barrios: barriosDisponibles,
          barrioSeleccionado: barrioSeleccionado,
          onBarrioSelected: (String? barrio) {
            setState(() {
              barrioSeleccionado = barrio;
              _updateMarkers();
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                target: municipios['Cartagena']!['centro'],
                zoom: municipios['Cartagena']!['zoom'],
              ),
              markers: markers,
              mapType: gm.MapType.normal,
              myLocationButtonEnabled: !isDialogOpen,
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
          if (isLoadingInstituciones || isLoadingBarrios)
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
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Cargando lugares intervenidos...'),
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
                        value: municipioSeleccionado,
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
                          ...municipios.keys.map((String municipio) {
                            return DropdownMenuItem<String>(
                              value: municipio,
                              child: Text(municipio,
                                  style: TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            municipioSeleccionado = newValue;
                            barrioSeleccionado = null;
                            _updateMarkers();
                          });
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
                                    onPressed: municipioSeleccionado == null
                                        ? null
                                        : () {
                                            setState(() {
                                              barrioSeleccionado = null;
                                              _updateMarkers();
                                            });
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
                            barrioSeleccionado ?? 'Todos',
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
                        value: anoSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Año',
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
                          ...anosDisponibles.map((int ano) {
                            return DropdownMenuItem<int>(
                              value: ano,
                              child:
                                  Text('$ano', style: TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                        ],
                        onChanged: (int? newValue) {
                          setState(() {
                            anoSeleccionado = newValue;
                            _updateMarkers();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
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
                            '${institucionesFiltradas.length}',
                            style: TextStyle(
                              fontSize: 16,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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

// Widget de diálogo con búsqueda para barrios
