/// Dashboard sections that map 1:1 to child routes under `/web`.
/// The enum drives both the URL (`path`) and the legacy `_model.select`
/// string used by `MenuPcWidget` while the migration stabilizes.
enum WebSection {
  usuarios('usuarios', 'Usuarios'),
  pacientes('pacientes', 'Pacientes'),
  encuestas('encuestas', 'Encuestas'),
  tamizajes('tamizajes', 'Tamizajes'),
  tamizajesManuales('tamizajes-manuales', 'ProfesionalTamizajesManuales'),
  notificaciones('notificaciones', 'Notificaciones'),
  contenido('contenido', 'Contenido'),
  estadisticas('estadisticas', 'Estadísticas'),
  mapa('mapa', 'ProfesionalMapa'),
  excel('excel', 'Excel'),
  instituciones('instituciones', 'Instituciones'),
  barrios('barrios', 'Barrios'),
  recordatorios('recordatorios', 'Recordatorios'),
  perfil('perfil', 'Ajustes de perfil');

  const WebSection(this.path, this.legacySelect);

  /// URL segment under `/web/`. Example: `usuarios` → `/web/usuarios`.
  final String path;

  /// Legacy value that the if/else switchboard in `web_widget.dart` used
  /// before the migration to real routes. Kept so existing code that
  /// reads `_model.menuPcModel.select` keeps working.
  final String legacySelect;

  String get fullPath => '/web/$path';

  static WebSection? fromPath(String uriPath) {
    for (final s in WebSection.values) {
      if (uriPath == s.fullPath || uriPath.startsWith('${s.fullPath}/')) {
        return s;
      }
    }
    return null;
  }
}
