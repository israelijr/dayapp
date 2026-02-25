// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'DayApp';

  @override
  String get settings => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get deviceDefault => 'Padrão do dispositivo';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Español';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get errorInitializingApp => 'Erro ao inicializar o app';

  @override
  String get theme => 'Tema';

  @override
  String get pinUnlock => 'PIN de Desbloqueio';

  @override
  String get changePin => 'Alterar PIN';

  @override
  String get enableBiometrics => 'Login com Biometria';

  @override
  String get information => 'Informações';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get configurePin => 'Configurar PIN';

  @override
  String get biometrics => 'Biometria';

  @override
  String get backgroundLock => 'Bloqueio em Segundo Plano';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get manageGroups => 'Gerenciar Grupos';

  @override
  String get trash => 'Lixeira';

  @override
  String get help => 'Ajuda';

  @override
  String get about => 'Sobre';

  @override
  String get logout => 'Sair';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get name => 'Nome';

  @override
  String get confirmPassword => 'Confirmar Senha';

  @override
  String get createAccountButton => 'Criar Conta';

  @override
  String get alreadyHaveAccount => 'Já tem uma conta? Faça login';

  @override
  String get needHelp => 'Precisa de ajuda?';

  @override
  String get currentPinLabel => 'PIN atual';

  @override
  String get newPinLabel => 'Novo PIN';

  @override
  String get pinLabel => 'PIN';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get enterCurrentPin => 'Digite o PIN atual';

  @override
  String get enterPin => 'Digite o PIN';

  @override
  String get pinLengthError => 'O PIN deve ter entre 4 e 8 dígitos';

  @override
  String get pinsDoNotMatch => 'Os PINs não coincidem';

  @override
  String get pinIncorrect => 'PIN atual incorreto';

  @override
  String get pinChangedSuccess => 'PIN alterado com sucesso!';

  @override
  String get pinConfiguredSuccess => 'PIN configurado com sucesso!';

  @override
  String get informYourEmail => 'Informe seu e-mail.';

  @override
  String get invalidEmail => 'Informe um e-mail válido.';

  @override
  String get emailNotFound => 'E-mail não encontrado. Verifique e tente novamente.';

  @override
  String codeSent(Object email) {
    return 'Código enviado para $email! Verifique sua caixa de entrada.';
  }

  @override
  String get codeMustBe6 => 'O código deve ter 6 dígitos.';

  @override
  String get codeVerified => 'Código verificado! Defina sua nova senha.';

  @override
  String get codeInvalid => 'Código inválido ou expirado. Tente novamente.';

  @override
  String get enterNewPassword => 'Informe a nova senha.';

  @override
  String get passwordResetSuccess => 'Senha redefinida com sucesso! Faça login com a nova senha.';

  @override
  String get errorResetPassword => 'Erro ao redefinir a senha. Tente novamente.';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem.';

  @override
  String get resendCodeSuccess => 'Novo código enviado! Verifique sua caixa de entrada.';

  @override
  String get resendCodeError => 'Erro ao reenviar código. Tente novamente.';

  @override
  String get passwordMinLength => 'A senha deve ter pelo menos 6 caracteres.';

  @override
  String get sendCode => 'Enviar Código';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get fullName => 'Nome completo';

  @override
  String get nameRequired => 'Nome é obrigatório';

  @override
  String get nameMinLength => 'Nome deve ter pelo menos 2 caracteres';

  @override
  String get emailRequired => 'E-mail é obrigatório';

  @override
  String get emailInvalid => 'Digite um e-mail válido';

  @override
  String get welcomeBack => 'Bem vindo de volta!';

  @override
  String get accessAccount => 'Acesse sua conta';

  @override
  String get enterPassword => 'Digite sua senha';

  @override
  String get signIn => 'Acessar';

  @override
  String get forgotPassword => 'Esqueci minha senha';

  @override
  String get noAccountCreateHere => 'Não tem conta, crie uma aqui.';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get biometricsEnabledSuccess => 'Biometria habilitada com sucesso!';

  @override
  String get biometricLoginError => 'Erro ao fazer login com biometria.';

  @override
  String get invalidCredentials => 'E-mail ou senha inválidos.';

  @override
  String get profileUpdatedSuccess => 'Perfil atualizado com sucesso!';

  @override
  String get profileUpdateError => 'Erro ao atualizar perfil. Tente novamente.';

  @override
  String get unlockAppReason => 'Desbloqueie o app para continuar';

  @override
  String get fillEmailAndPassword => 'Preencha o e-mail e a senha';

  @override
  String get emailOrPasswordIncorrect => 'E-mail ou senha incorretos';

  @override
  String get noEmailRegistered => 'Nenhum e-mail cadastrado. Configure nas configurações.';

  @override
  String checkEmailOrUseCode(Object email) {
    return 'Verifique seu e-mail em $email ou use o código exibido';
  }

  @override
  String get errorGeneratingCode => 'Erro ao gerar código. Tente novamente.';

  @override
  String get errorSendingCode => 'Erro ao enviar código. Tente novamente.';

  @override
  String get recoverPinTitle => 'Recuperar PIN';

  @override
  String get enterRecoveryCodePrompt => 'Digite o código que foi enviado para seu e-mail:';

  @override
  String get recoveryCodeLabel => 'Código de recuperação (6 dígitos)';

  @override
  String get enterPasswordToContinue => 'Digite sua senha para continuar';

  @override
  String get enterPinToContinue => 'Digite seu PIN para continuar';

  @override
  String get useBiometricsToContinue => 'Use sua biometria para continuar';

  @override
  String get unlockTitle => 'Desbloqueie o App';

  @override
  String get search => 'Pesquisar';

  @override
  String unsavedBackups(Object count) {
    return 'Você tem $count histórias sem backup.';
  }

  @override
  String get backupRecommendation => 'Recomendamos fazer backup para evitar perder seus dados.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get performBackup => 'Fazer backup';

  @override
  String get deleteStoryTitle => 'Excluir história';

  @override
  String get deleteStoryConfirm => 'Deseja mover esta história para a lixeira?';

  @override
  String get deleteLabel => 'Excluir';

  @override
  String get movedToTrash => 'História movida para a lixeira';

  @override
  String get unarchive => 'Desarquivar';

  @override
  String get group => 'Grupo';

  @override
  String exportPdfError(Object error) {
    return 'Erro ao exportar PDF: $error';
  }
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr(): super('pt_BR');

  @override
  String get appTitle => 'DayApp';

  @override
  String get settings => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get deviceDefault => 'Padrão do dispositivo';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Español';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get errorInitializingApp => 'Erro ao inicializar o app';

  @override
  String get theme => 'Tema';

  @override
  String get pinUnlock => 'PIN de Desbloqueio';

  @override
  String get changePin => 'Alterar PIN';

  @override
  String get enableBiometrics => 'Login com Biometria';

  @override
  String get information => 'Informações';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get configurePin => 'Configurar PIN';

  @override
  String get biometrics => 'Biometria';

  @override
  String get backgroundLock => 'Bloqueio em Segundo Plano';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get manageGroups => 'Gerenciar Grupos';

  @override
  String get trash => 'Lixeira';

  @override
  String get help => 'Ajuda';

  @override
  String get about => 'Sobre';

  @override
  String get logout => 'Sair';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get name => 'Nome';

  @override
  String get confirmPassword => 'Confirmar Senha';

  @override
  String get createAccountButton => 'Criar Conta';

  @override
  String get alreadyHaveAccount => 'Já tem uma conta? Faça login';

  @override
  String get needHelp => 'Precisa de ajuda?';

  @override
  String get currentPinLabel => 'PIN atual';

  @override
  String get newPinLabel => 'Novo PIN';

  @override
  String get pinLabel => 'PIN';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get enterCurrentPin => 'Digite o PIN atual';

  @override
  String get enterPin => 'Digite o PIN';

  @override
  String get pinLengthError => 'O PIN deve ter entre 4 e 8 dígitos';

  @override
  String get pinsDoNotMatch => 'Os PINs não coincidem';

  @override
  String get pinIncorrect => 'PIN atual incorreto';

  @override
  String get pinChangedSuccess => 'PIN alterado com sucesso!';

  @override
  String get pinConfiguredSuccess => 'PIN configurado com sucesso!';

  @override
  String get informYourEmail => 'Informe seu e-mail.';

  @override
  String get invalidEmail => 'Informe um e-mail válido.';

  @override
  String get emailNotFound => 'E-mail não encontrado. Verifique e tente novamente.';

  @override
  String codeSent(Object email) {
    return 'Código enviado para $email! Verifique sua caixa de entrada.';
  }

  @override
  String get codeMustBe6 => 'O código deve ter 6 dígitos.';

  @override
  String get codeVerified => 'Código verificado! Defina sua nova senha.';

  @override
  String get codeInvalid => 'Código inválido ou expirado. Tente novamente.';

  @override
  String get enterNewPassword => 'Informe a nova senha.';

  @override
  String get passwordResetSuccess => 'Senha redefinida com sucesso! Faça login com a nova senha.';

  @override
  String get errorResetPassword => 'Erro ao redefinir a senha. Tente novamente.';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem.';

  @override
  String get resendCodeSuccess => 'Novo código enviado! Verifique sua caixa de entrada.';

  @override
  String get resendCodeError => 'Erro ao reenviar código. Tente novamente.';

  @override
  String get passwordMinLength => 'A senha deve ter pelo menos 6 caracteres.';

  @override
  String get sendCode => 'Enviar Código';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get fullName => 'Nome completo';

  @override
  String get nameRequired => 'Nome é obrigatório';

  @override
  String get nameMinLength => 'Nome deve ter pelo menos 2 caracteres';

  @override
  String get emailRequired => 'E-mail é obrigatório';

  @override
  String get emailInvalid => 'Digite um e-mail válido';

  @override
  String get welcomeBack => 'Bem vindo de volta!';

  @override
  String get accessAccount => 'Acesse sua conta';

  @override
  String get enterPassword => 'Digite sua senha';

  @override
  String get signIn => 'Acessar';

  @override
  String get forgotPassword => 'Esqueci minha senha';

  @override
  String get noAccountCreateHere => 'Não tem conta, crie uma aqui.';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get biometricsEnabledSuccess => 'Biometria habilitada com sucesso!';

  @override
  String get biometricLoginError => 'Erro ao fazer login com biometria.';

  @override
  String get invalidCredentials => 'E-mail ou senha inválidos.';

  @override
  String get profileUpdatedSuccess => 'Perfil atualizado com sucesso!';

  @override
  String get profileUpdateError => 'Erro ao atualizar perfil. Tente novamente.';

  @override
  String get unlockAppReason => 'Desbloqueie o app para continuar';

  @override
  String get fillEmailAndPassword => 'Preencha o e-mail e a senha';

  @override
  String get emailOrPasswordIncorrect => 'E-mail ou senha incorretos';

  @override
  String get noEmailRegistered => 'Nenhum e-mail cadastrado. Configure nas configurações.';

  @override
  String checkEmailOrUseCode(Object email) {
    return 'Verifique seu e-mail em $email ou use o código exibido';
  }

  @override
  String get errorGeneratingCode => 'Erro ao gerar código. Tente novamente.';

  @override
  String get errorSendingCode => 'Erro ao enviar código. Tente novamente.';

  @override
  String get recoverPinTitle => 'Recuperar PIN';

  @override
  String get enterRecoveryCodePrompt => 'Digite o código que foi enviado para seu e-mail:';

  @override
  String get recoveryCodeLabel => 'Código de recuperação (6 dígitos)';

  @override
  String get enterPasswordToContinue => 'Digite sua senha para continuar';

  @override
  String get enterPinToContinue => 'Digite seu PIN para continuar';

  @override
  String get useBiometricsToContinue => 'Use sua biometria para continuar';

  @override
  String get unlockTitle => 'Desbloqueie o App';

  @override
  String get search => 'Pesquisar';

  @override
  String unsavedBackups(Object count) {
    return 'Você tem $count histórias sem backup.';
  }

  @override
  String get backupRecommendation => 'Recomendamos fazer backup para evitar perder seus dados.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get performBackup => 'Fazer backup';

  @override
  String get deleteStoryTitle => 'Excluir história';

  @override
  String get deleteStoryConfirm => 'Deseja mover esta história para a lixeira?';

  @override
  String get deleteLabel => 'Excluir';

  @override
  String get movedToTrash => 'História movida para a lixeira';

  @override
  String get unarchive => 'Desarquivar';

  @override
  String get group => 'Grupo';

  @override
  String exportPdfError(Object error) {
    return 'Erro ao exportar PDF: $error';
  }
}
