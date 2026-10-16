import '/backend/backend.dart';
import '/backend/push_notifications/push_notifications_util.dart';

/// Opción del selector "¿Notificar cuando se publique?" que activa el aviso.
const String kNotificarContenido = 'Sí, notificar';

/// `true` si el valor del selector pide notificar. Acepta 'All', el valor
/// que guardaba la versión anterior del selector.
bool debeNotificarContenido(String? valor) =>
    valor == kNotificarContenido || valor == 'All';

/// Aviso "nuevo contenido" al publicar, solo a los usuarios cuyo `rol` está
/// en [roles] (a quién va dirigido el contenido).
Future<void> notificarContenidoPublicado({
  required String titulo,
  required List<String> roles,
}) async {
  if (roles.isEmpty) return;
  // `whereIn` admite hasta 30 valores; los roles son 3.
  final usuarios = await queryUsersRecordOnce(
    queryBuilder: (q) => q.where('rol', whereIn: roles),
  );
  if (usuarios.isEmpty) return;
  triggerPushNotification(
    notificationTitle: 'nuevo contenido',
    notificationText:
        'Hemos publicado un nuevo articulo llamado: $titulo puedes verlo en la sección de contenido',
    notificationSound: 'default',
    userRefs: usuarios.map((e) => e.reference).toList(),
    initialPageName: 'book',
    parameterData: {},
  );
}
