import '/backend/backend.dart';

/// Correo como se guarda en `users.email`: sin espacios y en minúsculas,
/// igual que Firebase Auth.
String normalizarCorreo(String correo) => correo.trim().toLowerCase();

/// Perfil de `users` que ya usa [correo], o `null` si está libre.
///
/// Firebase Auth no deja repetir correos entre cuentas de acceso, pero los
/// adolescentes que registra un profesional no tienen cuenta: solo este
/// chequeo los ve. Busca el correo tal cual y normalizado para cubrir
/// perfiles antiguos guardados con mayúsculas. [excluir] es el propio
/// perfil (al editar o tras crear la cuenta). Requiere sesión iniciada.
Future<UsersRecord?> perfilConCorreo(
  String correo, {
  DocumentReference? excluir,
}) async {
  final tal = correo.trim();
  if (tal.isEmpty) return null;
  final variantes = {tal, normalizarCorreo(tal)}.toList();
  final perfiles = await queryUsersRecordOnce(
    queryBuilder: (u) => u.where('email', whereIn: variantes),
  );
  for (final p in perfiles) {
    if (excluir == null || p.reference.path != excluir.path) return p;
  }
  return null;
}

/// Mensaje para avisar que el correo ya pertenece a otro usuario.
String mensajeCorreoRegistrado(String correo, UsersRecord perfil) =>
    mensajeCorreoRegistradoPor(correo, perfil.displayName, perfil.rol);

String mensajeCorreoRegistradoPor(String correo, String nombre, String rol) {
  final quien = nombre.trim().isNotEmpty ? nombre.trim() : 'otro usuario';
  final tipo = rol.trim().isNotEmpty ? ' (${rol.trim()})' : '';
  return 'El correo ${correo.trim()} ya pertenece al usuario "$quien"$tipo.';
}

/// Aviso del autorregistro cuando el correo ya tiene un perfil (por ejemplo,
/// un adolescente registrado por su profesional, sin cuenta de acceso).
const kMensajeCorreoYaRegistradoApp =
    'Este correo ya está registrado por tu institución o tu profesional. '
    'Pide al administrador que te dé acceso.';
