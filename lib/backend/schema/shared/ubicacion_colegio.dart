import '../colegios_record.dart';

/// Ubicación (municipio y barrio) de un adolescente según su colegio.
///
/// En todos los formularios que dan de alta o editan un adolescente (registro
/// de la app, Crear/Editar usuario del admin y alta desde el wizard de
/// tamizaje manual) solo se elige el colegio: el municipio y el barrio se
/// toman de la colección `colegios` y se muestran de solo lectura.
typedef UbicacionColegio = ({String municipio, String barrio});

/// Municipio y barrio del colegio llamado [nombre] (sin espacios extremos).
///
/// `null` si el nombre está vacío o no está en el catálogo. Si hay colegios
/// con el mismo nombre se toma el primero: hoy las copias repetidas tienen el
/// mismo barrio y municipio.
UbicacionColegio? ubicacionDeColegio(
  Iterable<ColegiosRecord> colegios,
  String? nombre,
) {
  final buscado = (nombre ?? '').trim();
  if (buscado.isEmpty) return null;
  for (final c in colegios) {
    if (c.nombre.trim() == buscado) {
      return (municipio: c.municipio.trim(), barrio: c.barrio.trim());
    }
  }
  return null;
}

/// Nombres de colegio para los desplegables: sin vacíos ni repetidos y en
/// orden alfabético (sin distinguir mayúsculas).
List<String> nombresDeColegios(Iterable<ColegiosRecord> colegios) =>
    colegios.map((c) => c.nombre).where((n) => n.isNotEmpty).toSet().toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
