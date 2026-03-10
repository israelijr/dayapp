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
  String get defaultLabel => 'Predeterminado';

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
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get security => 'Seguridad';

  @override
  String get themeAndScheme => 'Tema y Esquema';

  @override
  String get backup => 'Copia de seguridad';

  @override
  String get automaticBackup => 'Copia de seguridad automática';

  @override
  String get lastAutoBackup => 'Última copia automática';

  @override
  String get backupOnLogout => 'Copia al cerrar sesión';

  @override
  String get enabled => 'Habilitado';

  @override
  String get disabled => 'Deshabilitado';

  @override
  String get confirm => 'Confirmar';

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
  String get backgroundLockDialogPrompt =>
      '¿Después de cuánto tiempo en segundo plano debe bloquearse la aplicación?';

  @override
  String get backgroundLockTimeLabel => 'Tiempo';

  @override
  String get backgroundLockDialogResult => 'Resultado:';

  @override
  String get backgroundLockSuggestions => 'Sugerencias:';

  @override
  String get backgroundLockImmediateHint => '0 = inmediato';

  @override
  String get backgroundLockNever => 'No bloquear';

  @override
  String get backgroundLockImmediately => 'Inmediatamente';

  @override
  String backgroundLockSeconds(int count) {
    return '$count segundos';
  }

  @override
  String get backgroundLockOneMinute => '1 minuto';

  @override
  String backgroundLockMinutes(int count) {
    return '$count minutos';
  }

  @override
  String get backgroundLockOneHour => '1 hora';

  @override
  String backgroundLockHours(int count) {
    return '$count horas';
  }

  @override
  String get statistics => 'Estadísticas';

  @override
  String get noStoriesYetTitle => 'Ninguna historia registrada aún';

  @override
  String get noStoriesYetSubtitle =>
      'Comienza a registrar tus días para ver las estadísticas';

  @override
  String get trends => 'Tendencias';

  @override
  String get last30Days => 'Últimos 30 días';

  @override
  String get activityByWeekday => 'Actividad por día de la semana';

  @override
  String get streaksTitle => 'Rachas';

  @override
  String get longestStreakPrefix => 'Racha más larga:';

  @override
  String get tableOfMoods => 'Tabla de estados de ánimo';

  @override
  String get moodCount => 'Contador de estados';

  @override
  String get topTags => 'Mejores etiquetas';

  @override
  String get storiesLabel => 'Historias';

  @override
  String get activeDaysLabel => 'Días activos';

  @override
  String get avgPerDayLabel => 'Prom/día';

  @override
  String get mediaLabel => 'Medios';

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
  String get birthDate => 'Fecha de nacimiento';

  @override
  String get almostReady => 'casi listo...';

  @override
  String get optionalData => 'Los datos a continuación son opcionales';

  @override
  String get birthDateFormat => 'Fecha de nacimiento (DD/MM/AAAA)';

  @override
  String get invalidBirthDate =>
      'Fecha de nacimiento inválida (use DD/MM/AAAA)';

  @override
  String get userNotFound => 'Usuario no encontrado.';

  @override
  String get create => 'Crear';

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
  String get usePin => 'Usar PIN';

  @override
  String get noStoriesHere => 'No hay historias para mostrar aquí.';

  @override
  String get storiesGroupedOrArchived => 'Están agrupadas o archivadas.';

  @override
  String get useBiometrics => 'Usar biometría';

  @override
  String get unlockWithBiometrics => 'Desbloquear con biometría';

  @override
  String get useAccountPassword => 'Usar contraseña de la cuenta';

  @override
  String get forgotPin => 'Olvidé mi PIN';

  @override
  String get unlockTitle => 'Desbloquee la aplicación';

  @override
  String get search => 'Buscar';

  @override
  String get searchStoriesTitle => 'Busca tus historias';

  @override
  String get searchStoriesSubtitle =>
      'Usa los filtros de arriba para encontrar tus recuerdos.';

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
  String get share => 'Compartir';

  @override
  String get home => 'Inicio';

  @override
  String get groups => 'Grupos';

  @override
  String get record => 'registro';

  @override
  String get records => 'registros';

  @override
  String get filterText => 'Texto';

  @override
  String get filterTag => 'Tag';

  @override
  String get filterEmoticon => 'Emoticon';

  @override
  String get searchHintTag => 'Escribe una etiqueta...';

  @override
  String get searchHintText => 'Buscar en título o descripción...';

  @override
  String get clearSearchTooltip => 'Limpiar búsqueda';

  @override
  String get clear => 'Limpiar';

  @override
  String get tapToSelectEmoji => 'Toque para seleccionar un emoji:';

  @override
  String get takePhoto => 'Tomar una foto';

  @override
  String get recordVideoLabel => 'Grabar un vídeo';

  @override
  String get recordAudioLabel => 'Grabar audio';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get dontShowAgain => 'No mostrar de nuevo';

  @override
  String get laterLabel => 'Más tarde';

  @override
  String get configureLabel => 'Configurar';

  @override
  String get imageCopiedBase64 => 'Imagen copiada al portapapeles (base64)';

  @override
  String get newGroup => 'Nuevo Grupo';

  @override
  String get editGroup => 'Editar Grupo';

  @override
  String get chooseIcon => 'Seleccionar ícono';

  @override
  String groupDeleteWarning(Object count) {
    return 'Este grupo tiene $count historia(s) vinculada(s). Si se elimina, esas historias volverán a la pantalla principal (sin grupo). ¿Continuar?';
  }

  @override
  String get unarchive => 'Desarchivar';

  @override
  String get group => 'Grupo';

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
  String get backupNotAvailableDetail =>
      'La función de copia de seguridad requiere acceso al sistema de archivos, disponible solo en las versiones de Android, iOS y escritorio.';

  @override
  String get backupInfoTitle => 'Sobre la copia de seguridad';

  @override
  String get backupInfoDetails =>
      'La copia de seguridad completa incluye:\n• Base de datos (historias, textos, fotos, audios)\n• Archivos de vídeo\n\nSe creará un archivo ZIP y puedes guardarlo donde quieras:\n• OneDrive\n• Google Drive\n• Correo electrónico\n• Cualquier otra ubicación';

  @override
  String get backupComplete => 'Copia de seguridad completa';

  @override
  String get backupZipSubtitle => 'Archivo ZIP con todos tus datos';

  @override
  String get backupZipExplanation =>
      'Genera un archivo ZIP que puedes guardar en OneDrive, Google Drive, correo electrónico o cualquier otra ubicación.';

  @override
  String get restoreSectionTitle => 'Restaurar copia de seguridad';

  @override
  String get restoreSectionDescription =>
      'Selecciona un archivo de copia de seguridad (ZIP) creado previamente para restaurar todos tus datos.';

  @override
  String get processing => 'Procesando...';

  @override
  String get pleaseWait => 'Por favor espera...';

  @override
  String get backupStarting => 'Iniciando copia de seguridad...';

  @override
  String get backupCreatedSuccess =>
      '¡Archivo de copia de seguridad creado! Usa el menú de compartir para guardarlo.';

  @override
  String backupError(Object message) {
    return 'Error al crear copia de seguridad: $message';
  }

  @override
  String get restoreStarting => 'Iniciando restauración...';

  @override
  String get restoreSuccess => '¡Restauración completada con éxito!';

  @override
  String restoreError(Object message) {
    return 'Error al restaurar: $message';
  }

  @override
  String get restoreConfirmTitle => '⚠️ Confirmar restauración';

  @override
  String get restoreConfirmContent =>
      'Todos los datos actuales serán reemplazados por la copia de seguridad.\n\nEsta acción no se puede deshacer. ¿Deseas continuar?';

  @override
  String get restoreSuccessTitle => '✅ Restauración completada';

  @override
  String get restoreSuccessContent =>
      '¡La copia de seguridad se restauró con éxito!\n\nTodas tus historias se han restaurado al estado del backup.\n\nNecesitas iniciar sesión nuevamente para completar el proceso.';

  @override
  String get helpAboutTitle => 'Sobre el DayApp';

  @override
  String get helpAboutDescription =>
      'DayApp es una aplicación de diario personal que te permite registrar tus historias, recuerdos y pensamientos de forma organizada y segura.';

  @override
  String get helpNavigationTitle => 'Navegación Principal';

  @override
  String get helpHomeItemDesc =>
      'Visualiza tus historias como tarjetas o lista. Toca una historia para ver, mantén presionado para opciones.';

  @override
  String get helpGroupsNavDesc =>
      'Organiza tus historias en grupos temáticos. Crea grupos personalizados para categorizar tus recuerdos.';

  @override
  String get helpSearchItemDesc =>
      'Encuentra historias rápidamente por título, contenido o fecha.';

  @override
  String get helpCreatingTitle => 'Creando Historias';

  @override
  String get helpNewStoryDesc =>
      'Toca el botón flotante (+) para crear una nueva historia. Añade título, texto enriquecido, imágenes, vídeos y audios.';

  @override
  String get helpTextEditorTitle => 'Editor de Texto';

  @override
  String get helpTextEditorDesc =>
      'Usa formato enriquecido: negrita, cursiva, listas, enlaces y más.';

  @override
  String get helpMediaDesc =>
      'Agrega fotos de la galería o cámara, graba vídeos y audios directamente en la aplicación.';

  @override
  String get helpGroupsAssocDesc =>
      'Asocia cada historia con uno o más grupos para una mejor organización.';

  @override
  String get helpCalendarDesc =>
      'Visualiza tus historias organizadas por fecha. Toca una fecha para ver todas las historias de ese día.';

  @override
  String get helpCreateGroupTitle => 'Crear Grupo';

  @override
  String get helpCreateGroupDesc =>
      'Ve a \"Administrar grupos\" en el menú lateral para crear nuevos grupos con colores personalizados.';

  @override
  String get helpEditGroupTitle => 'Editar Grupo';

  @override
  String get helpEditGroupDesc =>
      'Mantén presionado un grupo para editar su nombre, color o eliminarlo.';

  @override
  String get helpBackupSecurityTitle => 'Copia de seguridad y seguridad';

  @override
  String get helpAutomaticBackupTitle => 'Copia de seguridad automática';

  @override
  String get helpAutomaticBackupDesc =>
      'Configura copia de seguridad automática al cerrar sesión en Configuración. Se creará una copia y podrás elegir dónde guardarla.';

  @override
  String get helpManualBackupTitle => 'Copia de seguridad manual';

  @override
  String get helpManualBackupDesc =>
      'Ve a \"Administrar copia de seguridad\" en Configuración para crear una copia completa con todos los medios.';

  @override
  String get helpRestoreTitle => 'Restaurar';

  @override
  String get helpRestoreDesc =>
      'Usa \"Restaurar desde archivo\" para recuperar datos de una copia anterior.';

  @override
  String get helpPinSecurityTitle => 'PIN de seguridad';

  @override
  String get helpPinSecurityDesc =>
      'Configura un PIN de 4 a 8 dígitos para proteger el acceso a la app.';

  @override
  String get helpBiometricsDesc =>
      'Usa huella o reconocimiento facial para desbloquear la app rápidamente, si está disponible en tu dispositivo.';

  @override
  String get helpPasswordUnlockTitle => 'Desbloqueo por contraseña';

  @override
  String get helpPasswordUnlockDesc =>
      'Además de PIN y biometría, puedes desbloquear la app usando tu contraseña de cuenta. Útil si olvidas el PIN o la biometría falla.';

  @override
  String get helpBackgroundLockDesc =>
      'Cuando la app se minimiza o cambias a otra app, se bloquea automáticamente después del tiempo configurado. Puedes establecer el tiempo libremente en la configuración (segundos, minutos u horas).';

  @override
  String get helpLockExceptionsTitle => 'Excepciones de bloqueo';

  @override
  String get helpLockExceptionsDesc =>
      'La app no se bloquea cuando usas funciones internas que abren otras apps, como seleccionar fotos de la galería, grabar vídeos, elegir ubicación de backup o compartir historias.';

  @override
  String get helpPinRecoveryTitle => 'Recuperación de PIN';

  @override
  String get helpPinRecoveryDesc =>
      '¿Olvidaste tu PIN? Usa la opción \"Olvidé mi PIN\" en la pantalla de bloqueo. Se enviará un código de recuperación al correo registrado.';

  @override
  String get helpThemeDesc => 'Alterna entre tema claro, oscuro o automático.';

  @override
  String get helpNotificationsSettingsDesc =>
      'Configura recordatorios para escribir en el diario.';

  @override
  String get helpBackgroundLockSettingsDesc =>
      'Define cuánto tiempo la app puede permanecer en segundo plano antes de bloquearse. Puedes usar valores en segundos, minutos u horas, con total libertad.';

  @override
  String get helpBackupSettingTitle => 'Copia de seguridad';

  @override
  String get helpBackupSettingDesc =>
      'Administra opciones de copia de seguridad y restauración.';

  @override
  String get helpTrashDesc =>
      'Las historias eliminadas permanecen en la papelera durante 30 días. Accede a \"Papelera\" en el menú lateral para recuperar o eliminar permanentemente.';

  @override
  String get helpStatisticsDesc =>
      'Visualiza estadísticas sobre el uso del diario: número de historias, palabras escritas, grupos más usados, etc.';

  @override
  String get helpTipsTitle => 'Consejos de uso';

  @override
  String get helpOrganizationTipTitle => 'Organización';

  @override
  String get helpOrganizationTipDesc =>
      'Usa grupos para categorizar tus historias por temas, sentimientos o periodos de vida.';

  @override
  String get helpSearchTipTitle => 'Búsqueda';

  @override
  String get helpSearchTipDesc =>
      'Usa la función de búsqueda para encontrar historias antiguas rápidamente.';

  @override
  String get helpBackupTipTitle => 'Copia de seguridad regular';

  @override
  String get helpBackupTipDesc =>
      'Realiza copias regularmente, especialmente antes de actualizaciones o cambios de dispositivo.';

  @override
  String get helpPrivacyTipTitle => 'Privacidad';

  @override
  String get helpPrivacyTipDesc =>
      'Tus historias se almacenan localmente y están cifradas. Configura un PIN para protección adicional.';

  @override
  String get helpSupportTitle => 'Soporte';

  @override
  String get helpSupportDesc =>
      'Para dudas o problemas, contáctanos por correo de soporte o revisa las actualizaciones de la app.';

  @override
  String get errorCreateAccount =>
      'Error al crear la cuenta. Por favor, inténtalo de nuevo.';

  @override
  String get errorShare => 'Error al compartir';

  @override
  String errorPlayAudio(Object message) {
    return 'Error al reproducir audio: $message';
  }

  @override
  String errorSelectVideos(Object message) {
    return 'Error al seleccionar videos: $message';
  }

  @override
  String errorSelectFile(Object message) {
    return 'Error al seleccionar archivo: $message';
  }

  @override
  String errorRecordVideo(Object message) {
    return 'Error al grabar video: $message';
  }

  @override
  String errorStartRecording(Object message) {
    return 'Error al iniciar la grabación: $message';
  }

  @override
  String errorPauseRecording(Object message) {
    return 'Error al pausar la grabación: $message';
  }

  @override
  String errorResumeRecording(Object message) {
    return 'Error al reanudar la grabación: $message';
  }

  @override
  String errorStopRecording(Object message) {
    return 'Error al detener la grabación: $message';
  }

  @override
  String errorSelectAudios(Object message) {
    return 'Error al seleccionar audios: $message';
  }

  @override
  String get errorLoadVideo => 'Error al cargar video';

  @override
  String get errorSelectImage => 'Error al seleccionar imagen';

  @override
  String get imagePickerTitleMultiple => 'Agregar Fotos';

  @override
  String get imagePickerTitleSingle => 'Agregar Foto';

  @override
  String get imagePickerChooseOptionMultiple =>
      'Elige una opción (la galería permite varias fotos):';

  @override
  String get imagePickerChooseOptionSingle => 'Elige una opción:';

  @override
  String get imagePickerGalleryMultiple => 'Seleccionar de la galería';

  @override
  String get imagePickerGallerySingle => 'Buscar en la galería';

  @override
  String get imagePickerTakePhoto => 'Tomar una foto';

  @override
  String get audioPickerTitleMultiple => 'Agregar Audios';

  @override
  String get audioPickerTitleSingle => 'Agregar Audio';

  @override
  String get audioPickerChooseOptionMultiple =>
      'Elige una opción (los archivos permiten varios audios):';

  @override
  String get audioPickerChooseOptionSingle => 'Elige una opción:';

  @override
  String get audioPickerSelectFilesMultiple => 'Seleccionar archivos de audio';

  @override
  String get audioPickerSelectFilesSingle => 'Buscar archivo de audio';

  @override
  String get audioPickerRecord => 'Grabar audio';

  @override
  String get videoPickerTitleMultiple => 'Agregar Videos';

  @override
  String get videoPickerTitleSingle => 'Agregar Video';

  @override
  String get videoPickerChooseOptionMultiple =>
      'Elige una opción (los archivos permiten varios videos):';

  @override
  String get videoPickerChooseOptionSingle => 'Elige una opción:';

  @override
  String get videoPickerSelectFilesMultiple => 'Seleccionar archivos de video';

  @override
  String get videoPickerSelectFilesSingle => 'Buscar archivo de video';

  @override
  String get videoPickerRecord => 'Grabar video';

  @override
  String get successVideoAdded => '¡Video agregado con éxito!';

  @override
  String successVideosAdded(Object count) {
    return '¡$count videos agregados con éxito!';
  }

  @override
  String get startRecording => 'Comenzar grabación';

  @override
  String get recordingPaused => 'Grabación pausada';

  @override
  String get recording => 'Grabando...';

  @override
  String get readyToRecord => 'Listo para grabar';

  @override
  String get notificationDialogTitle => 'Programar notificación';

  @override
  String get notificationDialogPrompt =>
      '¿Cuándo te gustaría ser notificado sobre esta entrada?';

  @override
  String get emailAlreadyRegistered => 'E-mail ya registrado.';

  @override
  String get successNotificationScheduled =>
      'Notificación programada con éxito';

  @override
  String notificationReminderTitle(Object title) {
    return 'Recordatorio: $title';
  }

  @override
  String get successImageAdded => '¡Imagen agregada con éxito!';

  @override
  String successImagesAdded(Object count) {
    return '¡$count imágenes agregadas con éxito!';
  }

  @override
  String errorSearch(Object message) {
    return 'Error en la búsqueda: $message';
  }

  @override
  String get successStoryRestored => 'Historia restaurada con éxito';

  @override
  String get successStoryDeletedPermanently =>
      'Historia eliminada permanentemente';

  @override
  String get trashAlreadyEmpty => 'La papelera ya está vacía';

  @override
  String get successVideoRecorded => '¡Video grabado con éxito!';

  @override
  String get permissionMicrophoneDenied => 'Permiso de micrófono no concedido';

  @override
  String errorSelectImages(Object message) {
    return 'Error al seleccionar imágenes: $message';
  }

  @override
  String get successPhotoCaptured => '¡Foto capturada con éxito!';

  @override
  String get restoreStoriesTitle => 'Restaurar historias';

  @override
  String restoreStoriesConfirm(Object count) {
    return '¿Desea restaurar $count historia(s) seleccionada(s)?';
  }

  @override
  String get restoreLabel => 'Restaurar';

  @override
  String get permanentlyDeleteTitle => 'Eliminar permanentemente';

  @override
  String get permanentlyDeleteConfirm =>
      'Esta acción no se puede deshacer. ¿Realmente desea eliminar esta historia permanentemente?';

  @override
  String get permanentlyDeleteLabel => 'Eliminar permanentemente';

  @override
  String deleteGroupConfirm(Object name) {
    return '¿Desea eliminar el grupo \"$name\" de sus historias?';
  }

  @override
  String get recoverPinDescription =>
      'Enviaremos un código de recuperación a su correo electrónico registrado.';

  @override
  String get emptyTrashTitle => 'Empty trash';

  @override
  String emptyTrashConfirm(Object count) {
    return '¿Desea eliminar permanentemente $count historia(s) de la papelera?';
  }

  @override
  String get emptyTrashLabel => 'Empty trash';

  @override
  String errorTakePhoto(Object message) {
    return 'Error al tomar foto: $message';
  }

  @override
  String get notifications => 'Notificaciones';

  @override
  String get entryNotifications => 'Notificaciones de entradas';

  @override
  String get entryNotificationsInfo =>
      'Las entradas con fecha al menos 2 horas por delante pueden tener notificaciones programadas.';

  @override
  String get defaultAdvanceTitle => 'Antelación predeterminada';

  @override
  String get notificationAdvanceTitle => 'Antelación de la notificación';

  @override
  String get notificationAdvancePrompt =>
      '¿Con cuánto tiempo de antelación desea ser notificado?';

  @override
  String get notificationAdvanceDefault => 'Antelación predeterminada';

  @override
  String get manageCompleteBackup => 'Administrar copia de seguridad completa';

  @override
  String get backupWithVideosZip =>
      'Copia de seguridad con videos en archivo ZIP';

  @override
  String get backupOnLogoutDescription =>
      'La copia de seguridad se creará al cerrar sesión';

  @override
  String get automaticBackupInfo =>
      'Cuando cierre sesión, se creará una copia de seguridad y podrá elegir dónde guardarla (carpeta local, Google Drive, etc).';

  @override
  String get biometricsNotAvailable => 'No disponible en este dispositivo';

  @override
  String get biometricsDisabled => 'Biometría deshabilitada';

  @override
  String get biometricConfiguredInfo =>
      'La biometría está configurada. Puede iniciar sesión usando su huella dactilar o reconocimiento facial.';

  @override
  String get biometricAuthFailed => 'Error en la autenticación biométrica';

  @override
  String get confirmIdentityToEnableBiometrics =>
      'Confirme su identidad para habilitar la biometría';

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

  @override
  String get titleRequired => '¡El título es obligatorio!';

  @override
  String errorSavingStory(Object error) {
    return 'Error al guardar la historia: $error';
  }

  @override
  String get exportPdfFieldsRequired =>
      'El título y la descripción son obligatorios para exportar.';

  @override
  String get exportHistory => 'Exportar historia';

  @override
  String get exportHistoryPrompt =>
      '¿Desea guardar antes de exportar o solo ver una vista previa?';

  @override
  String get preview => 'Vista previa';

  @override
  String get saveAndExport => 'Guardar y exportar';

  @override
  String get untitled => 'Sin título';

  @override
  String errorLoadingFile(Object error) {
    return 'Error al cargar el archivo: $error';
  }

  @override
  String get discard => 'Descartar';

  @override
  String get discardStoryTitle => '¿Descartar historia?';

  @override
  String get unsavedStoryPrompt =>
      'Tiene una historia nueva sin guardar. ¿Salir sin guardar?';

  @override
  String get changeDateTooltip => 'Cambiar fecha';

  @override
  String get storyTitleLabel => 'Título';

  @override
  String get storyTitleHint => 'Ingrese el título';

  @override
  String get descriptionLabel => 'Descripción';

  @override
  String get descriptionHint => 'Escribe tu historia...';

  @override
  String get tagsLabel => 'Etiquetas';

  @override
  String get photosSection => 'Fotos';

  @override
  String get audiosSection => 'Audios';

  @override
  String get videosSection => 'Videos';

  @override
  String get importTxtTooltip => 'Importar .txt';

  @override
  String get expandTooltip => 'Expandir';

  @override
  String get photoTooltip => 'Foto';

  @override
  String get videoTooltip => 'Vídeo';

  @override
  String get audioTooltip => 'Audio';

  @override
  String get emojiTooltip => 'Emoji';

  @override
  String get editDescription => 'Editar Descripción';

  @override
  String get editStory => 'Editar historia';

  @override
  String get discardChangesTitle => '¿Descartar cambios?';

  @override
  String get discardChangesPrompt =>
      'Tiene cambios sin guardar. ¿Salir sin guardar?';

  @override
  String get archivedStateLabel => 'Archivado';

  @override
  String get archiveSubtitle => 'Ocultar de la pantalla principal';

  @override
  String get chooseEmoji => 'Elige un emoji';

  @override
  String get emojiGroupSentimentos => 'Sentimientos';

  @override
  String get emojiGroupAnimais => 'Animales';

  @override
  String get emojiGroupVegetais => 'Plantas';

  @override
  String get emojiGroupCeu => 'Cielo';

  @override
  String get emojiGroupObjetos => 'Objetos';

  @override
  String get emojiGroupAlimentos => 'Alimentos';

  @override
  String get emojiGroupLugares => 'Lugares';

  @override
  String get emojiGroupSimbolos => 'Símbolos';

  @override
  String get moodQuestion => '¿Cómo te sentiste en esta historia?';

  @override
  String get moodDifficult => 'Difícil';

  @override
  String get moodNeutral => 'Neutro';

  @override
  String get moodGood => 'Bueno';

  @override
  String get moodVeryGood => 'Muy bueno';

  @override
  String get energyQuestion => '¿Cómo estaba tu energía?';

  @override
  String get energyLow => 'Baja';

  @override
  String get energyNormal => 'Normal';

  @override
  String get energyHigh => 'Alta';
}
