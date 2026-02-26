// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  // ----- UI elements used in create/edit story screens -----
  @override
  String get storyTitleLabel => 'Título';

  @override
  String get storyTitleHint => 'Digite o título';

  @override
  String get descriptionLabel => 'Descrição';

  @override
  String get descriptionHint => 'Escreva sua história...';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get photosSection => 'Fotos';

  @override
  String get audiosSection => 'Áudios';

  @override
  String get videosSection => 'Vídeos';

  @override
  String get importTxtTooltip => 'Importar .txt';

  @override
  String get expandTooltip => 'Expandir';

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
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get security => 'Segurança';

  @override
  String get themeAndScheme => 'Tema e Esquema';

  @override
  String get backup => 'Backup';

  @override
  String get automaticBackup => 'Backup Automático';

  @override
  String get lastAutoBackup => 'Último backup automático';

  @override
  String get backupOnLogout => 'Backup ao sair';

  @override
  String get enabled => 'Habilitado';

  @override
  String get disabled => 'Desabilitado';

  @override
  String get confirm => 'Confirmar';

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
  String get noStoriesYetTitle => 'Nenhuma história registrada ainda';

  @override
  String get noStoriesYetSubtitle =>
      'Comece a registrar seus dias para ver as estatísticas';

  @override
  String get trends => 'Tendências';

  @override
  String get last30Days => 'Últimos 30 dias';

  @override
  String get activityByWeekday => 'Atividade por dia da semana';

  @override
  String get streaksTitle => 'Dias seguidos';

  @override
  String get longestStreakPrefix => 'Sequência mais longa:';

  @override
  String get tableOfMoods => 'Tabela de humores';

  @override
  String get moodCount => 'Contagem de humor';

  @override
  String get topTags => 'Top tags';

  @override
  String get storiesLabel => 'Histórias';

  @override
  String get activeDaysLabel => 'Dias ativos';

  @override
  String get avgPerDayLabel => 'Média/dia';

  @override
  String get mediaLabel => 'Mídias';

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
  String get emailNotFound =>
      'E-mail não encontrado. Verifique e tente novamente.';

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
  String get passwordResetSuccess =>
      'Senha redefinida com sucesso! Faça login com a nova senha.';

  @override
  String get errorResetPassword =>
      'Erro ao redefinir a senha. Tente novamente.';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem.';

  @override
  String get resendCodeSuccess =>
      'Novo código enviado! Verifique sua caixa de entrada.';

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
  String get noEmailRegistered =>
      'Nenhum e-mail cadastrado. Configure nas configurações.';

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
  String get enterRecoveryCodePrompt =>
      'Digite o código que foi enviado para seu e-mail:';

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
  String get backupRecommendation =>
      'Recomendamos fazer backup para evitar perder seus dados.';

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
  String errorDeletingStory(Object error) {
    return 'Erro ao excluir história: $error';
  }

  @override
  String get noRecordsThisDay => 'Nenhum registro neste dia';

  @override
  String get storyUngrouped => 'História desagrupada';

  @override
  String get save => 'Salvar';

  @override
  String get confirmDeletion => 'Confirmar exclusão';

  @override
  String get groupDeletedSuccess => 'Grupo excluído com sucesso';

  @override
  String get noGroupsFound => 'Nenhum grupo encontrado';

  @override
  String get shareError => 'Não foi possível compartilhar';

  @override
  String get cannotDeletePhoto => 'Não é possível excluir esta foto';

  @override
  String get deletePhotoTitle => 'Excluir foto';

  @override
  String get deletePhotoConfirm => 'Deseja realmente excluir esta foto?';

  @override
  String get deleteGroupTitle => 'Excluir Grupo';

  @override
  String get share => 'Compartilhar';

  @override
  String get home => 'Início';

  @override
  String get groups => 'Grupos';

  @override
  String get imageCopiedBase64 =>
      'Imagem copiada para a área de transferência (base64)';

  @override
  String get newGroup => 'Novo Grupo';

  @override
  String get editGroup => 'Editar Grupo';

  @override
  String get chooseIcon => 'Escolher ícone';

  @override
  String groupDeleteWarning(Object count) {
    return 'Este grupo tem $count história(s) vinculada(s). Se excluído, essas histórias voltarão para a tela inicial (sem grupo). Continuar?';
  }

  @override
  String get unarchive => 'Desarquivar';

  @override
  String get group => 'Grupo';

  @override
  String get selectGroup => 'Selecionar Grupo';

  @override
  String get existingGroups => 'Grupos Existentes';

  @override
  String get createNewGroup => 'Criar Novo Grupo';

  @override
  String get groupNameLabel => 'Nome do Grupo';

  @override
  String get createAndSelect => 'Criar e Selecionar';

  @override
  String get manageBackups => 'Gerenciar Backup';

  @override
  String get createAndShareBackup => 'Criar e Compartilhar Backup';

  @override
  String get restoreFromFile => 'Restaurar de Arquivo';

  @override
  String get backupNotAvailableWeb => 'Backup não disponível na versão web';

  @override
  String get backupComplete => 'Backup Completo';

  @override
  String get notifications => 'Notificações';

  @override
  String get entryNotifications => 'Notificações de Entradas';

  @override
  String get entryNotificationsInfo =>
      'Entradas com data pelo menos 2 horas à frente podem ter notificações agendadas.';

  @override
  String get defaultAdvanceTitle => 'Antecedência Padrão';

  @override
  String get notificationAdvanceTitle => 'Antecedência da Notificação';

  @override
  String get notificationAdvancePrompt =>
      'Com quanto tempo de antecedência você quer ser notificado?';

  @override
  String get notificationAdvanceDefault => 'Antecedência padrão';

  @override
  String get manageCompleteBackup => 'Gerenciar Backup Completo';

  @override
  String get backupWithVideosZip => 'Backup com vídeos em arquivo ZIP';

  @override
  String get backupOnLogoutDescription => 'Backup será criado ao fazer logout';

  @override
  String get automaticBackupInfo =>
      'Ao fazer logout, um backup será criado e você poderá escolher onde salvar (pasta local, Google Drive, etc).';

  @override
  String get biometricsNotAvailable => 'Não disponível neste dispositivo';

  @override
  String get biometricsDisabled => 'Biometria desabilitada';

  @override
  String get biometricConfiguredInfo =>
      'A biometria está configurada. Você pode fazer login usando sua digital ou reconhecimento facial.';

  @override
  String get biometricAuthFailed => 'Falha na autenticação biométrica';

  @override
  String get confirmIdentityToEnableBiometrics =>
      'Confirme sua identidade para habilitar a biometria';

  @override
  String get calendarTitle => 'Calendário';

  @override
  String get groupExists => 'Grupo já existe';

  @override
  String get enterGroupName => 'Digite um nome para o grupo';

  @override
  String get archivedTitle => 'Arquivados';

  @override
  String get toggleToIcons => 'Alternar para visualização de ícones';

  @override
  String get toggleToCards => 'Alternar para visualização em blocos';

  @override
  String get menu => 'Menu';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get editTip => 'Editar - toque duplo';

  @override
  String get exportPdf => 'Exportar PDF';

  @override
  String get close => 'Fechar';

  @override
  String get newStory => 'Nova História';

  @override
  String get noArchivedStories => 'Nenhuma história arquivada.';

  @override
  String get edit => 'Editar';

  @override
  String previewTitle(Object title) {
    return 'Visualização - $title';
  }

  @override
  String get archiveLabel => 'Arquivar';

  @override
  String get storyArchived => 'História arquivada';

  @override
  String get undo => 'Desfazer';

  @override
  String get ungroup => 'Desagrupar';

  @override
  String noStoriesInGroup(Object group) {
    return 'Nenhuma história no grupo $group';
  }

  @override
  String exportPdfError(Object error) {
    return 'Erro ao exportar PDF: $error';
  }

  @override
  String get titleRequired => 'Título é obrigatório!';

  @override
  String errorSavingStory(Object error) => 'Erro ao salvar história: $error';

  @override
  String get exportPdfFieldsRequired =>
      'Título e descrição são obrigatórios para exportar.';

  @override
  String get exportHistory => 'Exportar História';

  @override
  String get exportHistoryPrompt =>
      'Deseja salvar antes de exportar ou ver um preview?';

  @override
  String get preview => 'Preview';

  @override
  String get saveAndExport => 'Salvar e exportar';

  @override
  String get untitled => 'Sem título';

  @override
  String errorLoadingFile(Object error) => 'Erro ao carregar arquivo: $error';

  @override
  String get discard => 'Descartar';

  @override
  String get discardStoryTitle => 'Descartar história?';

  @override
  String get unsavedStoryPrompt =>
      'Você tem uma nova história não salva. Deseja sair sem salvar?';

  @override
  String get changeDateTooltip => 'Alterar Data';

  @override
  String get editStory => 'Editar História';

  @override
  String get discardChangesTitle => 'Descartar alterações?';

  @override
  String get discardChangesPrompt =>
      'Você tem alterações não salvas. Deseja sair sem salvar?';

  @override
  String get archivedStateLabel => 'Arquivado';

  @override
  String get archiveSubtitle => 'Ocultar da tela inicial';
}

class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

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
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get security => 'Segurança';

  @override
  String get themeAndScheme => 'Tema e Esquema';

  @override
  String get backup => 'Backup';

  @override
  String get automaticBackup => 'Backup Automático';

  @override
  String get lastAutoBackup => 'Último backup automático';

  @override
  String get backupOnLogout => 'Backup ao sair';

  @override
  String get enabled => 'Habilitado';

  @override
  String get disabled => 'Desabilitado';

  @override
  String get confirm => 'Confirmar';

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
  String get noStoriesYetTitle => 'Nenhuma história registrada ainda';

  @override
  String get noStoriesYetSubtitle =>
      'Comece a registrar seus dias para ver as estatísticas';

  @override
  String get trends => 'Tendências';

  @override
  String get last30Days => 'Últimos 30 dias';

  @override
  String get activityByWeekday => 'Atividade por dia da semana';

  @override
  String get streaksTitle => 'Dias seguidos';

  @override
  String get longestStreakPrefix => 'Sequência mais longa:';

  @override
  String get tableOfMoods => 'Tabela de humores';

  @override
  String get moodCount => 'Contagem de humor';

  @override
  String get topTags => 'Top tags';

  @override
  String get storiesLabel => 'Histórias';

  @override
  String get activeDaysLabel => 'Dias ativos';

  @override
  String get avgPerDayLabel => 'Média/dia';

  @override
  String get mediaLabel => 'Mídias';

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
  String get emailNotFound =>
      'E-mail não encontrado. Verifique e tente novamente.';

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
  String get passwordResetSuccess =>
      'Senha redefinida com sucesso! Faça login com a nova senha.';

  @override
  String get errorResetPassword =>
      'Erro ao redefinir a senha. Tente novamente.';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem.';

  @override
  String get resendCodeSuccess =>
      'Novo código enviado! Verifique sua caixa de entrada.';

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
  String get noEmailRegistered =>
      'Nenhum e-mail cadastrado. Configure nas configurações.';

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
  String get enterRecoveryCodePrompt =>
      'Digite o código que foi enviado para seu e-mail:';

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
  String get backupRecommendation =>
      'Recomendamos fazer backup para evitar perder seus dados.';

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
  String errorDeletingStory(Object error) {
    return 'Erro ao excluir história: $error';
  }

  @override
  String get noRecordsThisDay => 'Nenhum registro neste dia';

  @override
  String get storyUngrouped => 'História desagrupada';

  @override
  String get save => 'Salvar';

  @override
  String get confirmDeletion => 'Confirmar exclusão';

  @override
  String get groupDeletedSuccess => 'Grupo excluído com sucesso';

  @override
  String get noGroupsFound => 'Nenhum grupo encontrado';

  @override
  String get shareError => 'Não foi possível compartilhar';

  @override
  String get cannotDeletePhoto => 'Não é possível excluir esta foto';

  @override
  String get deletePhotoTitle => 'Excluir foto';

  @override
  String get deletePhotoConfirm => 'Deseja realmente excluir esta foto?';

  @override
  String get deleteGroupTitle => 'Excluir Grupo';

  @override
  String get share => 'Compartilhar';

  @override
  String get home => 'Início';

  @override
  String get groups => 'Grupos';

  @override
  String get imageCopiedBase64 =>
      'Imagem copiada para a área de transferência (base64)';

  @override
  String get newGroup => 'Novo Grupo';

  @override
  String get editGroup => 'Editar Grupo';

  @override
  String get chooseIcon => 'Escolher ícone';

  @override
  String groupDeleteWarning(Object count) {
    return 'Este grupo tem $count história(s) vinculada(s). Se excluído, essas histórias voltarão para a tela inicial (sem grupo). Continuar?';
  }

  @override
  String get unarchive => 'Desarquivar';

  @override
  String get group => 'Grupo';

  @override
  String get selectGroup => 'Selecionar Grupo';

  @override
  String get existingGroups => 'Grupos Existentes';

  @override
  String get createNewGroup => 'Criar Novo Grupo';

  @override
  String get groupNameLabel => 'Nome do Grupo';

  @override
  String get createAndSelect => 'Criar e Selecionar';

  @override
  String get manageBackups => 'Gerenciar Backup';

  @override
  String get createAndShareBackup => 'Criar e Compartilhar Backup';

  @override
  String get restoreFromFile => 'Restaurar de Arquivo';

  @override
  String get backupNotAvailableWeb => 'Backup não disponível na versão web';

  @override
  String get backupComplete => 'Backup Completo';

  @override
  String get notifications => 'Notificações';

  @override
  String get entryNotifications => 'Notificações de Entradas';

  @override
  String get entryNotificationsInfo =>
      'Entradas com data pelo menos 2 horas à frente podem ter notificações agendadas.';

  @override
  String get defaultAdvanceTitle => 'Antecedência Padrão';

  @override
  String get notificationAdvanceTitle => 'Antecedência da Notificação';

  @override
  String get notificationAdvancePrompt =>
      'Com quanto tempo de antecedência você quer ser notificado?';

  @override
  String get notificationAdvanceDefault => 'Antecedência padrão';

  @override
  String get manageCompleteBackup => 'Gerenciar Backup Completo';

  @override
  String get backupWithVideosZip => 'Backup com vídeos em arquivo ZIP';

  @override
  String get backupOnLogoutDescription => 'Backup será criado ao fazer logout';

  @override
  String get automaticBackupInfo =>
      'Ao fazer logout, um backup será criado e você poderá escolher onde salvar (pasta local, Google Drive, etc).';

  @override
  String get biometricsNotAvailable => 'Não disponível neste dispositivo';

  @override
  String get biometricsDisabled => 'Biometria desabilitada';

  @override
  String get biometricConfiguredInfo =>
      'A biometria está configurada. Você pode fazer login usando sua digital ou reconhecimento facial.';

  @override
  String get biometricAuthFailed => 'Falha na autenticação biométrica';

  @override
  String get confirmIdentityToEnableBiometrics =>
      'Confirme sua identidade para habilitar a biometria';

  @override
  String get calendarTitle => 'Calendário';

  @override
  String get groupExists => 'Grupo já existe';

  @override
  String get enterGroupName => 'Digite um nome para o grupo';

  @override
  String get archivedTitle => 'Arquivados';

  @override
  String get toggleToIcons => 'Alternar para visualização de ícones';

  @override
  String get toggleToCards => 'Alternar para visualização em blocos';

  @override
  String get menu => 'Menu';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get editTip => 'Editar - toque duplo';

  @override
  String get exportPdf => 'Exportar PDF';

  @override
  String get close => 'Fechar';

  @override
  String get newStory => 'Nova História';

  @override
  String get noArchivedStories => 'Nenhuma história arquivada.';

  @override
  String get edit => 'Editar';

  @override
  String previewTitle(Object title) {
    return 'Visualização - $title';
  }

  @override
  String get archiveLabel => 'Arquivar';

  @override
  String get storyArchived => 'História arquivada';

  @override
  String get undo => 'Desfazer';

  @override
  String get ungroup => 'Desagrupar';

  @override
  String noStoriesInGroup(Object group) {
    return 'Nenhuma história no grupo $group';
  }

  @override
  String exportPdfError(Object error) {
    return 'Erro ao exportar PDF: $error';
  }

  @override
  String get titleRequired => 'Título é obrigatório!';

  @override
  String errorSavingStory(Object error) => 'Erro ao salvar história: $error';

  @override
  String get exportPdfFieldsRequired =>
      'Título e descrição são obrigatórios para exportar.';

  @override
  String get exportHistory => 'Exportar História';

  @override
  String get exportHistoryPrompt =>
      'Deseja salvar antes de exportar ou ver um preview?';

  @override
  String get preview => 'Preview';

  @override
  String get saveAndExport => 'Salvar e exportar';

  @override
  String get untitled => 'Sem título';

  @override
  String errorLoadingFile(Object error) => 'Erro ao carregar arquivo: $error';

  @override
  String get discard => 'Descartar';

  @override
  String get discardStoryTitle => 'Descartar história?';

  @override
  String get unsavedStoryPrompt =>
      'Você tem uma nova história não salva. Deseja sair sem salvar?';

  @override
  String get changeDateTooltip => 'Alterar Data';

  @override
  String get storyTitleLabel => 'Título';

  @override
  String get storyTitleHint => 'Digite o título';

  @override
  String get descriptionLabel => 'Descrição';

  @override
  String get descriptionHint => 'Escreva sua história...';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get photosSection => 'Fotos';

  @override
  String get audiosSection => 'Áudios';

  @override
  String get videosSection => 'Vídeos';

  @override
  String get importTxtTooltip => 'Importar .txt';

  @override
  String get expandTooltip => 'Expandir';
}
