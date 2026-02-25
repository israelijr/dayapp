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
  String get emailNotFound => 'Correo no encontrado. Verifique e inténtelo de nuevo.';

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
  String get passwordResetSuccess => '¡Contraseña restablecida con éxito! Inicie sesión con la nueva contraseña.';

  @override
  String get errorResetPassword => 'Error al restablecer la contraseña. Intente nuevamente.';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String get resendCodeSuccess => '¡Nuevo código enviado! Verifique su bandeja de entrada.';

  @override
  String get resendCodeError => 'Error al reenviar código. Intente nuevamente.';

  @override
  String get passwordMinLength => 'La contraseña debe tener al menos 6 caracteres.';

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
}
