// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'DayApp';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get deviceDefault => 'Predeterminado del dispositivo';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get errorInitializingApp => 'Error al inicializar la aplicación';

  @override
  String get theme => 'Tema';

  @override
  String get pinUnlock => 'PIN de desbloqueo';

  @override
  String get changePin => 'Cambiar PIN';

  @override
  String get enableBiometrics => 'Inicio biométrico';

  @override
  String get information => 'Información';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get configurePin => 'Configurar PIN';

  @override
  String get biometrics => 'Biometría';

  @override
  String get backgroundLock => 'Bloqueo en segundo plano';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get manageGroups => 'Administrar grupos';

  @override
  String get trash => 'Papelera';

  @override
  String get help => 'Ayuda';

  @override
  String get about => 'Acerca de';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get name => 'Nombre';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get createAccountButton => 'Crear cuenta';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get needHelp => '¿Necesitas ayuda?';

  @override
  String get currentPinLabel => 'PIN actual';

  @override
  String get newPinLabel => 'Nuevo PIN';

  @override
  String get pinLabel => 'PIN';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get enterCurrentPin => 'Ingrese el PIN actual';

  @override
  String get enterPin => 'Ingrese el PIN';

  @override
  String get pinLengthError => 'El PIN debe tener entre 4 y 8 dígitos';

  @override
  String get pinsDoNotMatch => 'Los PIN no coinciden';

  @override
  String get pinIncorrect => 'PIN actual incorrecto';

  @override
  String get pinChangedSuccess => '¡PIN cambiado con éxito!';

  @override
  String get pinConfiguredSuccess => '¡PIN configurado con éxito!';

  @override
  String get informYourEmail => 'Ingrese su correo electrónico.';

  @override
  String get invalidEmail => 'Ingrese un correo electrónico válido.';

  @override
  String get emailNotFound =>
      'Correo no encontrado. Verifique e inténtelo de nuevo.';

  @override
  String codeSent(Object email) {
    return 'Código enviado a $email! Verifique su bandeja de entrada.';
  }

  @override
  String get codeMustBe6 => 'El código debe tener 6 dígitos.';

  @override
  String get codeVerified => '¡Código verificado! Defina su nueva contraseña.';

  @override
  String get codeInvalid => 'Código inválido o expirado. Intente nuevamente.';

  @override
  String get enterNewPassword => 'Ingrese la nueva contraseña.';

  @override
  String get passwordResetSuccess =>
      '¡Contraseña restablecida con éxito! Inicie sesión con la nueva contraseña.';

  @override
  String get errorResetPassword =>
      'Error al restablecer la contraseña. Intente nuevamente.';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String get resendCodeSuccess =>
      '¡Nuevo código enviado! Verifique su bandeja de entrada.';

  @override
  String get resendCodeError => 'Error al reenviar código. Intente nuevamente.';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get sendCode => 'Enviar código';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get nameMinLength => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get emailRequired => 'Correo electrónico es obligatorio';

  @override
  String get emailInvalid => 'Ingrese un correo electrónico válido';

  @override
  String get welcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get accessAccount => 'Accede a tu cuenta';

  @override
  String get enterPassword => 'Ingrese su contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get noAccountCreateHere => '¿No tienes cuenta? Crea una aquí.';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get biometricsEnabledSuccess => '¡Biometría habilitada con éxito!';

  @override
  String get biometricLoginError => 'Error al iniciar sesión con biometría.';

  @override
  String get invalidCredentials => 'Correo electrónico o contraseña inválidos.';

  @override
  String get profileUpdatedSuccess => '¡Perfil actualizado con éxito!';

  @override
  String get profileUpdateError =>
      'Error al actualizar el perfil. Intente nuevamente.';

  @override
  String get unlockAppReason => 'Desbloquee la aplicación para continuar';

  @override
  String get fillEmailAndPassword =>
      'Complete el correo electrónico y la contraseña';

  @override
  String get emailOrPasswordIncorrect => 'Correo o contraseña incorrectos';

  @override
  String get noEmailRegistered =>
      'Ningún correo registrado. Configurelo en las configuraciones.';

  @override
  String checkEmailOrUseCode(Object email) {
    return 'Verifique su correo en $email o use el código mostrado';
  }

  @override
  String get errorGeneratingCode =>
      'Error al generar código. Intente nuevamente.';

  @override
  String get errorSendingCode => 'Error al enviar código. Intente nuevamente.';

  @override
  String get recoverPinTitle => 'Recuperar PIN';

  @override
  String get enterRecoveryCodePrompt =>
      'Ingrese el código enviado a su correo:';

  @override
  String get recoveryCodeLabel => 'Código de recuperación (6 dígitos)';

  @override
  String get enterPasswordToContinue => 'Ingrese su contraseña para continuar';

  @override
  String get enterPinToContinue => 'Ingrese su PIN para continuar';

  @override
  String get useBiometricsToContinue => 'Use su biometría para continuar';

  @override
  String get unlockTitle => 'Desbloquee la aplicación';

  @override
  String get search => 'Buscar';

  @override
  String unsavedBackups(Object count) {
    return 'Tienes $count historias sin copia de seguridad.';
  }

  @override
  String get backupRecommendation =>
      'Recomendamos hacer una copia de seguridad para evitar perder tus datos.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get performBackup => 'Hacer copia de seguridad';

  @override
  String get deleteStoryTitle => 'Eliminar historia';

  @override
  String get deleteStoryConfirm => '¿Desea mover esta historia a la papelera?';

  @override
  String get deleteLabel => 'Eliminar';

  @override
  String get movedToTrash => 'Historia movida a la papelera';

  @override
  String errorDeletingStory(Object error) {
    return 'Error al eliminar historia: $error';
  }

  @override
  String get noRecordsThisDay => 'No hay registros para este día';

  @override
  String get storyUngrouped => 'Historia desagrupada';

  @override
  String get save => 'Guardar';

  @override
  String get confirmDeletion => 'Confirmar eliminación';

  @override
  String get groupDeletedSuccess => 'Grupo eliminado con éxito';

  @override
  String get noGroupsFound => 'Ningún grupo encontrado';

  @override
  String get shareError => 'No se pudo compartir';

  @override
  String get cannotDeletePhoto => 'No es posible eliminar esta foto';

  @override
  String get deletePhotoTitle => 'Eliminar foto';

  @override
  String get deletePhotoConfirm => '¿Desea realmente eliminar esta foto?';

  @override
  String get deleteGroupTitle => 'Eliminar Grupo';

  @override
  String groupDeleteWarning(Object count) {
    return 'Este grupo tiene $count historia(s) vinculada(s). Si se elimina, esas historias volverán a la pantalla principal (sin grupo). ¿Continuar?';
  }

  @override
  String get unarchive => 'Desarchivar';

  @override
  String get group => 'Grupo';

  @override
  String get share => 'Compartir';

  @override
  String get imageCopiedBase64 => 'Imagen copiada al portapapeles (base64)';

  @override
  String get newGroup => 'Nuevo Grupo';

  @override
  String get editGroup => 'Editar Grupo';

  @override
  String get chooseIcon => 'Seleccionar ícono';

  @override
  String get selectGroup => 'Seleccionar Grupo';

  @override
  String get existingGroups => 'Grupos Existentes';

  @override
  String get createNewGroup => 'Crear Nuevo Grupo';

  @override
  String get groupNameLabel => 'Nombre del Grupo';

  @override
  String get createAndSelect => 'Crear y Seleccionar';

  @override
  String get manageBackups => 'Administrar copia de seguridad';

  @override
  String get createAndShareBackup => 'Crear y compartir copia de seguridad';

  @override
  String get restoreFromFile => 'Restaurar desde archivo';

  @override
  String get backupNotAvailableWeb =>
      'Copia de seguridad no disponible en la web';

  @override
  String get backupComplete => 'Copia de seguridad completa';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get groupExists => 'El grupo ya existe';

  @override
  String get enterGroupName => 'Ingrese un nombre para el grupo';

  @override
  String get archivedTitle => 'Archivados';

  @override
  String get toggleToIcons => 'Cambiar a vista de iconos';

  @override
  String get toggleToCards => 'Cambiar a vista de tarjetas';

  @override
  String get menu => 'Menú';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get editTip => 'Editar - doble toque';

  @override
  String get exportPdf => 'Exportar PDF';

  @override
  String get close => 'Cerrar';

  @override
  String get newStory => 'Nueva historia';

  @override
  String get noArchivedStories => 'No hay historias archivadas.';

  @override
  String get edit => 'Editar';

  @override
  String previewTitle(Object title) {
    return 'Previsualización - $title';
  }

  @override
  String get archiveLabel => 'Archiv ar';

  @override
  String get storyArchived => 'Historia archivada';

  @override
  String get undo => 'Deshacer';

  @override
  String get ungroup => 'Desagrupar';

  @override
  String noStoriesInGroup(Object group) {
    return 'No hay historias en el grupo $group';
  }

  @override
  String exportPdfError(Object error) {
    return 'Error al exportar PDF: $error';
  }
}
