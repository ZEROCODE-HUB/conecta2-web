import '/app_state.dart';

/// Marca la sesión como iniciada desde la app.
///
/// `AppStateNotifier.update` (`nav.dart`) cierra cualquier sesión de Firebase
/// si `FFAppState().EmailAdmin` está vacío. El login lo llena antes de
/// `signInWithEmail`; el autorregistro debe hacer lo mismo antes de
/// `createAccountWithEmail`, o la cuenta recién creada queda desconectada
/// antes de guardar su perfil. Aquí no se guarda la contraseña.
void marcarSesionApp(String email) {
  FFAppState().EmailAdmin = email.trim();
}

/// Borra los datos de sesión guardados en el dispositivo (al cerrar sesión o
/// si el registro falla).
void limpiarSesionApp() {
  FFAppState().EmailAdmin = '';
  FFAppState().PasswordAdmin = '';
}
