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
  String get defaultLabel => 'Default';

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
  String get backgroundLockDialogPrompt =>
      'Após quanto tempo em segundo plano o app deve ser bloqueado?';

  @override
  String get backgroundLockTimeLabel => 'Tempo';

  @override
  String get backgroundLockDialogResult => 'Resultado:';

  @override
  String get backgroundLockSuggestions => 'Sugestões:';

  @override
  String get backgroundLockImmediateHint => '0 = imediato';

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
  String get birthDate => 'Data de nascimento';

  @override
  String get almostReady => 'quase pronto...';

  @override
  String get optionalData => 'Os dados abaixo são opcionais';

  @override
  String get birthDateFormat => 'Data de nascimento (DD/MM/AAAA)';

  @override
  String get invalidBirthDate => 'Data de nascimento inválida (use DD/MM/AAAA)';

  @override
  String get userNotFound => 'Usuário não encontrado.';

  @override
  String get create => 'Criar';

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
  String get usePin => 'Usar PIN';

  @override
  String get useBiometrics => 'Usar biometria';

  @override
  String get unlockWithBiometrics => 'Desbloquear com biometria';

  @override
  String get useAccountPassword => 'Usar senha da conta';

  @override
  String get forgotPin => 'Esqueci meu PIN';

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
  String get record => 'record';

  @override
  String get records => 'records';

  @override
  String get filterText => 'Text';

  @override
  String get filterTag => 'Tag';

  @override
  String get filterEmoticon => 'Emoticon';

  @override
  String get searchHintTag => 'Type a tag...';

  @override
  String get searchHintText => 'Search in title or description...';

  @override
  String get clearSearchTooltip => 'Clear search';

  @override
  String get clear => 'Clear';

  @override
  String get tapToSelectEmoji => 'Tap to select an emoji:';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get recordVideoLabel => 'Record a video';

  @override
  String get recordAudioLabel => 'Record audio';

  @override
  String get continueLabel => 'Continue';

  @override
  String get dontShowAgain => 'Don\'t show again';

  @override
  String get laterLabel => 'Later';

  @override
  String get configureLabel => 'Configure';

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
  String get backupNotAvailableDetail =>
      'The backup feature requires file system access, available only on Android, iOS and desktop versions.';

  @override
  String get backupInfoTitle => 'About Backup';

  @override
  String get backupInfoDetails =>
      'The complete backup includes:\n• Database (stories, texts, photos, audios)\n• Video files\n\nA ZIP file will be created and you can save it wherever you want:\n• OneDrive\n• Google Drive\n• Email\n• Any other location';

  @override
  String get backupComplete => 'Backup Completo';

  @override
  String get backupZipSubtitle => 'ZIP file with all your data';

  @override
  String get backupZipExplanation =>
      'Generates a ZIP file that you can save to OneDrive, Google Drive, email or any other location.';

  @override
  String get restoreSectionTitle => 'Restore Backup';

  @override
  String get restoreSectionDescription =>
      'Select a backup file (ZIP) previously created to restore all your data.';

  @override
  String get processing => 'Processing...';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get backupStarting => 'Starting backup...';

  @override
  String get backupCreatedSuccess =>
      'Backup file created! Use the share menu to save it.';

  @override
  String backupError(Object message) {
    return 'Error creating backup: $message';
  }

  @override
  String get restoreStarting => 'Starting restore...';

  @override
  String get restoreSuccess => 'Restore completed successfully!';

  @override
  String restoreError(Object message) {
    return 'Error restoring: $message';
  }

  @override
  String get restoreConfirmTitle => '⚠️ Confirm Restore';

  @override
  String get restoreConfirmContent =>
      'All current data will be replaced by the backup.\n\nThis action cannot be undone. Do you wish to continue?';

  @override
  String get restoreSuccessTitle => '✅ Restore Completed';

  @override
  String get restoreSuccessContent =>
      'The backup was restored successfully!\n\nAll your stories have been restored to the backup state.\n\nYou need to log in again to complete the process.';

  @override
  String get helpAboutTitle => 'About DayApp';

  @override
  String get helpAboutDescription =>
      'DayApp is a personal diary app that lets you record your stories, memories and thoughts in an organized and secure way.';

  @override
  String get helpNavigationTitle => 'Main Navigation';

  @override
  String get helpHomeItemDesc =>
      'View your stories as cards or list. Tap a story to view, long press for options.';

  @override
  String get helpGroupsNavDesc =>
      'Organize your stories into thematic groups. Create custom groups to categorize your memories.';

  @override
  String get helpSearchItemDesc =>
      'Quickly find stories by title, content or date.';

  @override
  String get helpCreatingTitle => 'Creating Stories';

  @override
  String get helpNewStoryDesc =>
      'Tap the floating (+) button to create a new story. Add title, rich text, images, videos and audios.';

  @override
  String get helpTextEditorTitle => 'Text Editor';

  @override
  String get helpTextEditorDesc =>
      'Use rich formatting: bold, italic, lists, links and more.';

  @override
  String get helpMediaDesc =>
      'Add photos from the gallery or camera, record videos and audios directly in the app.';

  @override
  String get helpGroupsAssocDesc =>
      'Associate each story with one or more groups for better organization.';

  @override
  String get helpCalendarDesc =>
      'View your stories organized by date. Tap a date to see all stories for that day.';

  @override
  String get helpCreateGroupTitle => 'Create Group';

  @override
  String get helpCreateGroupDesc =>
      'Go to \"Manage Groups\" in the side menu to create new groups with custom colors.';

  @override
  String get helpEditGroupTitle => 'Edit Group';

  @override
  String get helpEditGroupDesc =>
      'Long press a group to edit its name, color or delete it.';

  @override
  String get helpBackupSecurityTitle => 'Backup & Security';

  @override
  String get helpAutomaticBackupTitle => 'Automatic Backup';

  @override
  String get helpAutomaticBackupDesc =>
      'Configure automatic backup on logout in Settings. A backup will be created and you can choose where to save it.';

  @override
  String get helpManualBackupTitle => 'Manual Backup';

  @override
  String get helpManualBackupDesc =>
      'Go to \"Manage Backup\" in Settings to create a full backup with all media.';

  @override
  String get helpRestoreTitle => 'Restore';

  @override
  String get helpRestoreDesc =>
      'Use \"Restore from File\" to recover data from a previous backup.';

  @override
  String get helpPinSecurityTitle => 'Security PIN';

  @override
  String get helpPinSecurityDesc =>
      'Set a 4- to 8-digit PIN to protect app access.';

  @override
  String get helpBiometricsDesc =>
      'Use fingerprint or facial recognition to unlock the app quickly, if available on your device.';

  @override
  String get helpPasswordUnlockTitle => 'Password Unlock';

  @override
  String get helpPasswordUnlockDesc =>
      'In addition to PIN and biometrics, you can unlock the app using your account password. Useful if you forget the PIN or biometrics fail.';

  @override
  String get helpBackgroundLockDesc =>
      'When the app is minimized or you switch to another app, it locks automatically after the configured time. You can set the time freely in settings (seconds, minutes or hours).';

  @override
  String get helpLockExceptionsTitle => 'Lock Exceptions';

  @override
  String get helpLockExceptionsDesc =>
      'The app does not lock when you use internal features that open other apps—such as picking photos from the gallery, recording videos, choosing backup location or sharing stories.';

  @override
  String get helpPinRecoveryTitle => 'PIN Recovery';

  @override
  String get helpPinRecoveryDesc =>
      'Forgot your PIN? Use the \"Forgot my PIN\" option on the lock screen. A recovery code will be sent to the registered email.';

  @override
  String get helpThemeDesc => 'Toggle between light, dark or automatic theme.';

  @override
  String get helpNotificationsSettingsDesc =>
      'Set reminders to write in the diary.';

  @override
  String get helpBackgroundLockSettingsDesc =>
      'Define how long the app can stay in the background before being locked. You may use values in seconds, minutes or hours, with full freedom.';

  @override
  String get helpBackupSettingTitle => 'Backup';

  @override
  String get helpBackupSettingDesc => 'Manage backup and restore settings.';

  @override
  String get helpTrashDesc =>
      'Deleted stories stay in the trash for 30 days. Access \"Trash\" in the side menu to recover or permanently delete.';

  @override
  String get helpStatisticsDesc =>
      'View statistics about your diary usage: number of stories, words written, top groups, etc.';

  @override
  String get helpTipsTitle => 'Usage Tips';

  @override
  String get helpOrganizationTipTitle => 'Organization';

  @override
  String get helpOrganizationTipDesc =>
      'Use groups to categorize your stories by themes, feelings or life periods.';

  @override
  String get helpSearchTipTitle => 'Search';

  @override
  String get helpSearchTipDesc =>
      'Use the search function to quickly find old stories.';

  @override
  String get helpBackupTipTitle => 'Regular Backup';

  @override
  String get helpBackupTipDesc =>
      'Back up regularly, especially before updates or device changes.';

  @override
  String get helpPrivacyTipTitle => 'Privacy';

  @override
  String get helpPrivacyTipDesc =>
      'Your stories are stored locally and encrypted. Set a PIN for additional protection.';

  @override
  String get helpSupportTitle => 'Support';

  @override
  String get helpSupportDesc =>
      'For questions or issues, contact us via support email or check app updates.';

  @override
  String get errorCreateAccount => 'Error creating account. Please try again.';

  @override
  String get errorShare => 'Error sharing';

  @override
  String errorPlayAudio(Object message) {
    return 'Error playing audio: $message';
  }

  @override
  String errorSelectVideos(Object message) {
    return 'Error selecting videos: $message';
  }

  @override
  String errorSelectFile(Object message) {
    return 'Error selecting file: $message';
  }

  @override
  String errorRecordVideo(Object message) {
    return 'Error recording video: $message';
  }

  @override
  String errorStartRecording(Object message) {
    return 'Error starting recording: $message';
  }

  @override
  String errorPauseRecording(Object message) {
    return 'Error pausing recording: $message';
  }

  @override
  String errorResumeRecording(Object message) {
    return 'Error resuming recording: $message';
  }

  @override
  String errorStopRecording(Object message) {
    return 'Error stopping recording: $message';
  }

  @override
  String errorSelectAudios(Object message) {
    return 'Error selecting audios: $message';
  }

  @override
  String get errorLoadVideo => 'Error loading video';

  @override
  String get errorSelectImage => 'Error selecting image';

  @override
  String get imagePickerTitleMultiple => 'Adicionar Fotos';

  @override
  String get imagePickerTitleSingle => 'Adicionar Foto';

  @override
  String get imagePickerChooseOptionMultiple =>
      'Escolha uma opção (galeria permite múltiplas fotos):';

  @override
  String get imagePickerChooseOptionSingle => 'Escolha uma opção:';

  @override
  String get imagePickerGalleryMultiple => 'Selecionar da galeria';

  @override
  String get imagePickerGallerySingle => 'Buscar na galeria';

  @override
  String get imagePickerTakePhoto => 'Tirar uma foto';

  @override
  String get audioPickerTitleMultiple => 'Adicionar Áudios';

  @override
  String get audioPickerTitleSingle => 'Adicionar Áudio';

  @override
  String get audioPickerChooseOptionMultiple =>
      'Escolha uma opção (arquivos permite múltiplos áudios):';

  @override
  String get audioPickerChooseOptionSingle => 'Escolha uma opção:';

  @override
  String get audioPickerSelectFilesMultiple => 'Selecionar arquivos de áudio';

  @override
  String get audioPickerSelectFilesSingle => 'Buscar arquivo de áudio';

  @override
  String get audioPickerRecord => 'Gravar um áudio';

  @override
  String get videoPickerTitleMultiple => 'Adicionar Vídeos';

  @override
  String get videoPickerTitleSingle => 'Adicionar Vídeo';

  @override
  String get videoPickerChooseOptionMultiple =>
      'Escolha uma opção (arquivos permite múltiplos vídeos):';

  @override
  String get videoPickerChooseOptionSingle => 'Escolha uma opção:';

  @override
  String get videoPickerSelectFilesMultiple => 'Selecionar arquivos de vídeo';

  @override
  String get videoPickerSelectFilesSingle => 'Buscar arquivo de vídeo';

  @override
  String get videoPickerRecord => 'Gravar um vídeo';

  @override
  String get successVideoAdded => 'Vídeo adicionado com sucesso!';

  @override
  String successVideosAdded(Object count) {
    return '$count vídeos adicionados com sucesso!';
  }

  @override
  String get startRecording => 'Iniciar Gravação';

  @override
  String get recordingPaused => 'Gravação Pausada';

  @override
  String get recording => 'Gravando...';

  @override
  String get readyToRecord => 'Pronto para Gravar';

  @override
  String get notificationDialogTitle => 'Schedule Notification';

  @override
  String get notificationDialogPrompt =>
      'When would you like to be notified about this entry?';

  @override
  String get emailAlreadyRegistered => 'E-mail already registered.';

  @override
  String get successNotificationScheduled =>
      'Notification scheduled successfully';

  @override
  String notificationReminderTitle(Object title) {
    return 'Reminder: $title';
  }

  @override
  String get successImageAdded => 'Image added successfully!';

  @override
  String successImagesAdded(Object count) {
    return '$count images added successfully!';
  }

  @override
  String errorSearch(Object message) {
    return 'Error during search: $message';
  }

  @override
  String get successStoryRestored => 'Story restored successfully';

  @override
  String get successStoryDeletedPermanently => 'Story permanently deleted';

  @override
  String get trashAlreadyEmpty => 'Trash is already empty';

  @override
  String get successVideoRecorded => 'Video recorded successfully!';

  @override
  String get permissionMicrophoneDenied => 'Microphone permission not granted';

  @override
  String errorSelectImages(Object message) {
    return 'Error selecting images: $message';
  }

  @override
  String get successPhotoCaptured => 'Photo captured successfully!';

  @override
  String get restoreStoriesTitle => 'Restore stories';

  @override
  String restoreStoriesConfirm(Object count) {
    return 'Do you want to restore $count selected story(ies)?';
  }

  @override
  String get restoreLabel => 'Restore';

  @override
  String get permanentlyDeleteTitle => 'Permanently delete';

  @override
  String get permanentlyDeleteConfirm =>
      'This action cannot be undone. Do you really want to permanently delete this story?';

  @override
  String get permanentlyDeleteLabel => 'Permanently delete';

  @override
  String deleteGroupConfirm(Object name) {
    return 'Do you want to remove the group \"$name\" from your stories?';
  }

  @override
  String get recoverPinDescription =>
      'We will send a recovery code to your registered email.';

  @override
  String get emptyTrashTitle => 'Empty trash';

  @override
  String emptyTrashConfirm(Object count) {
    return 'Do you want to permanently delete all $count story(ies) in the trash? This action cannot be undone.';
  }

  @override
  String get emptyTrashLabel => 'Empty trash';

  @override
  String errorTakePhoto(Object message) {
    return 'Error taking photo: $message';
  }

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
  String get titleRequired => 'Title is required!';

  @override
  String errorSavingStory(Object error) {
    return 'Error saving story: $error';
  }

  @override
  String get exportPdfFieldsRequired =>
      'Title and description are required to export.';

  @override
  String get exportHistory => 'Export Story';

  @override
  String get exportHistoryPrompt =>
      'Do you want to save before exporting or just preview?';

  @override
  String get preview => 'Preview';

  @override
  String get saveAndExport => 'Save and export';

  @override
  String get untitled => 'Untitled';

  @override
  String errorLoadingFile(Object error) {
    return 'Error loading file: $error';
  }

  @override
  String get discard => 'Discard';

  @override
  String get discardStoryTitle => 'Discard story?';

  @override
  String get unsavedStoryPrompt =>
      'You have a new unsaved story. Leave without saving?';

  @override
  String get changeDateTooltip => 'Change date';

  @override
  String get storyTitleLabel => 'Title';

  @override
  String get storyTitleHint => 'Enter the title';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint => 'Write your story...';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get photosSection => 'Photos';

  @override
  String get audiosSection => 'Audios';

  @override
  String get videosSection => 'Videos';

  @override
  String get importTxtTooltip => 'Import .txt';

  @override
  String get expandTooltip => 'Expand';

  @override
  String get photoTooltip => 'Photo';

  @override
  String get videoTooltip => 'Video';

  @override
  String get audioTooltip => 'Audio';

  @override
  String get emojiTooltip => 'Emoji';

  @override
  String get editDescription => 'Edit Description';

  @override
  String get editStory => 'Edit Story';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesPrompt =>
      'You have unsaved changes. Leave without saving?';

  @override
  String get archivedStateLabel => 'Archived';

  @override
  String get archiveSubtitle => 'Hide from home screen';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
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
  String get defaultLabel => 'Padrão';

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
  String get backgroundLockDialogPrompt =>
      'Após quanto tempo em segundo plano o app deve ser bloqueado?';

  @override
  String get backgroundLockTimeLabel => 'Tempo';

  @override
  String get backgroundLockDialogResult => 'Resultado:';

  @override
  String get backgroundLockSuggestions => 'Sugestões:';

  @override
  String get backgroundLockImmediateHint => '0 = imediato';

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
  String get birthDate => 'Data de nascimento';

  @override
  String get almostReady => 'quase pronto...';

  @override
  String get optionalData => 'Os dados abaixo são opcionais';

  @override
  String get birthDateFormat => 'Data de nascimento (DD/MM/AAAA)';

  @override
  String get invalidBirthDate => 'Data de nascimento inválida (use DD/MM/AAAA)';

  @override
  String get userNotFound => 'Usuário não encontrado.';

  @override
  String get create => 'Criar';

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
  String get usePin => 'Usar PIN';

  @override
  String get useBiometrics => 'Usar biometria';

  @override
  String get unlockWithBiometrics => 'Desbloquear com biometria';

  @override
  String get useAccountPassword => 'Usar senha da conta';

  @override
  String get forgotPin => 'Esqueci meu PIN';

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
  String get backupNotAvailableDetail =>
      'O recurso de backup requer acesso ao sistema de arquivos, disponível apenas nas versões Android, iOS e Desktop.';

  @override
  String get backupInfoTitle => 'Sobre o Backup';

  @override
  String get backupInfoDetails =>
      'O backup completo inclui:\n• Banco de dados (histórias, textos, fotos, áudios)\n• Arquivos de vídeo\n\nUm arquivo ZIP será criado e você pode salvá-lo onde quiser:\n• OneDrive\n• Google Drive\n• Email\n• Qualquer outro local';

  @override
  String get backupComplete => 'Backup Completo';

  @override
  String get backupZipSubtitle => 'Arquivo ZIP com todos os seus dados';

  @override
  String get backupZipExplanation =>
      'Gera um arquivo ZIP que você pode salvar no OneDrive, Google Drive, email ou qualquer outro local.';

  @override
  String get restoreSectionTitle => 'Restaurar Backup';

  @override
  String get restoreSectionDescription =>
      'Selecione um arquivo de backup (ZIP) anteriormente criado para restaurar todos os seus dados.';

  @override
  String get processing => 'Processando...';

  @override
  String get pleaseWait => 'Por favor, aguarde...';

  @override
  String get backupStarting => 'Iniciando backup...';

  @override
  String get backupCreatedSuccess =>
      'Arquivo de backup criado! Use o menu de compartilhamento para salvá-lo.';

  @override
  String backupError(Object message) {
    return 'Erro ao criar backup: $message';
  }

  @override
  String get restoreStarting => 'Iniciando restauração...';

  @override
  String get restoreSuccess => 'Restauração concluída com sucesso!';

  @override
  String restoreError(Object message) {
    return 'Erro ao restaurar: $message';
  }

  @override
  String get restoreConfirmTitle => '⚠️ Confirmar Restauração';

  @override
  String get restoreConfirmContent =>
      'Todos os dados atuais serão substituídos pelo backup.\n\nEsta ação não pode ser desfeita. Deseja continuar?';

  @override
  String get restoreSuccessTitle => '✅ Restauração Concluída';

  @override
  String get restoreSuccessContent =>
      'O backup foi restaurado com sucesso!\n\nTodas as suas histórias foram restauradas ao estado do backup.\n\nÉ necessário fazer login novamente para completar o processo.';

  @override
  String get helpAboutTitle => 'Sobre o DayApp';

  @override
  String get helpAboutDescription =>
      'O DayApp é um aplicativo de diário pessoal que permite registrar suas histórias, memórias e pensamentos de forma organizada e segura.';

  @override
  String get helpNavigationTitle => 'Navegação Principal';

  @override
  String get helpHomeItemDesc =>
      'Visualize suas histórias em cards ou lista. Toque em uma história para visualizar, mantenha pressionado para opções.';

  @override
  String get helpGroupsNavDesc =>
      'Organize suas histórias em grupos temáticos. Crie grupos personalizados para categorizar suas memórias.';

  @override
  String get helpSearchItemDesc =>
      'Encontre histórias rapidamente por título, conteúdo ou data.';

  @override
  String get helpCreatingTitle => 'Criando Histórias';

  @override
  String get helpNewStoryDesc =>
      'Toque no botão flutuante (+) para criar uma nova história. Adicione título, texto rico, imagens, vídeos e áudios.';

  @override
  String get helpTextEditorTitle => 'Editor de Texto';

  @override
  String get helpTextEditorDesc =>
      'Use formatação rica: negrito, itálico, listas, links e muito mais.';

  @override
  String get helpMediaDesc =>
      'Adicione fotos da galeria ou câmera, grave vídeos e áudios diretamente no app.';

  @override
  String get helpGroupsAssocDesc =>
      'Associe cada história a um ou mais grupos para melhor organização.';

  @override
  String get helpCalendarDesc =>
      'Visualize suas histórias organizadas por data. Toque em uma data para ver todas as histórias daquele dia.';

  @override
  String get helpCreateGroupTitle => 'Criar Grupo';

  @override
  String get helpCreateGroupDesc =>
      'Acesse \"Gerenciar Grupos\" no menu lateral para criar novos grupos com cores personalizadas.';

  @override
  String get helpEditGroupTitle => 'Editar Grupo';

  @override
  String get helpEditGroupDesc =>
      'Mantenha pressionado em um grupo para editar nome, cor ou excluir.';

  @override
  String get helpBackupSecurityTitle => 'Backup e Segurança';

  @override
  String get helpAutomaticBackupTitle => 'Backup Automático';

  @override
  String get helpAutomaticBackupDesc =>
      'Configure backup automático no logout nas Configurações. O backup será criado e você poderá escolher onde salvar.';

  @override
  String get helpManualBackupTitle => 'Backup Manual';

  @override
  String get helpManualBackupDesc =>
      'Acesse \"Gerenciar Backup\" nas Configurações para criar backup completo com todas as mídias.';

  @override
  String get helpRestoreTitle => 'Restauração';

  @override
  String get helpRestoreDesc =>
      'Use \"Restaurar de Arquivo\" para recuperar dados de um backup anterior.';

  @override
  String get helpPinSecurityTitle => 'PIN de Segurança';

  @override
  String get helpPinSecurityDesc =>
      'Configure um PIN de 4 a 8 dígitos para proteger o acesso ao app.';

  @override
  String get helpBiometricsDesc =>
      'Use digital ou reconhecimento facial para desbloquear o app rapidamente, se disponível no dispositivo.';

  @override
  String get helpPasswordUnlockTitle => 'Desbloqueio por Senha';

  @override
  String get helpPasswordUnlockDesc =>
      'Além de PIN e biometria, você pode desbloquear o app usando a senha da sua conta. Útil caso esqueça o PIN ou a biometria falhe.';

  @override
  String get helpBackgroundLockDesc =>
      'Quando o app é minimizado ou você troca para outro app, ele é bloqueado automaticamente após o tempo configurado. Você pode definir o tempo livremente nas configurações (segundos, minutos ou horas).';

  @override
  String get helpLockExceptionsTitle => 'Exceções de Bloqueio';

  @override
  String get helpLockExceptionsDesc =>
      'O app não bloqueia quando você usa recursos internos que abrem outros apps — como selecionar fotos da galeria, gravar vídeos, escolher local de backup ou compartilhar histórias.';

  @override
  String get helpPinRecoveryTitle => 'Recuperação de PIN';

  @override
  String get helpPinRecoveryDesc =>
      'Esqueceu o PIN? Use a opção \"Esqueci meu PIN\" na tela de bloqueio. Um código de recuperação será enviado para o e-mail cadastrado.';

  @override
  String get helpThemeDesc => 'Alterne entre tema claro, escuro ou automático.';

  @override
  String get helpNotificationsSettingsDesc =>
      'Configure lembretes para escrever no diário.';

  @override
  String get helpBackgroundLockSettingsDesc =>
      'Defina por quanto tempo o app pode ficar em segundo plano antes de ser bloqueado. Você pode usar valores em segundos, minutos ou horas, com total liberdade.';

  @override
  String get helpBackupSettingTitle => 'Backup';

  @override
  String get helpBackupSettingDesc =>
      'Gerencie configurações de backup e restauração.';

  @override
  String get helpTrashDesc =>
      'Histórias excluídas ficam na lixeira por 30 dias. Acesse \"Lixeira\" no menu lateral para recuperar ou excluir permanentemente.';

  @override
  String get helpStatisticsDesc =>
      'Visualize estatísticas sobre seu uso do diário: número de histórias, palavras escritas, grupos mais usados, etc.';

  @override
  String get helpTipsTitle => 'Dicas de Uso';

  @override
  String get helpOrganizationTipTitle => 'Organização';

  @override
  String get helpOrganizationTipDesc =>
      'Use grupos para categorizar suas histórias por temas, sentimentos ou períodos da vida.';

  @override
  String get helpSearchTipTitle => 'Pesquisa';

  @override
  String get helpSearchTipDesc =>
      'Use a função de pesquisa para encontrar histórias antigas rapidamente.';

  @override
  String get helpBackupTipTitle => 'Backup Regular';

  @override
  String get helpBackupTipDesc =>
      'Faça backup regularmente, especialmente antes de atualizações ou mudanças no dispositivo.';

  @override
  String get helpPrivacyTipTitle => 'Privacidade';

  @override
  String get helpPrivacyTipDesc =>
      'Suas histórias são armazenadas localmente e criptografadas. Configure PIN para proteção adicional.';

  @override
  String get helpSupportTitle => 'Suporte';

  @override
  String get helpSupportDesc =>
      'Para dúvidas ou problemas, entre em contato conosco através do email de suporte ou verifique as atualizações do app.';

  @override
  String get errorCreateAccount => 'Erro ao criar conta. Tente novamente.';

  @override
  String get errorShare => 'Erro ao compartilhar';

  @override
  String errorPlayAudio(Object message) {
    return 'Erro ao reproduzir áudio: $message';
  }

  @override
  String errorSelectVideos(Object message) {
    return 'Erro ao selecionar vídeos: $message';
  }

  @override
  String errorSelectFile(Object message) {
    return 'Erro ao selecionar arquivo: $message';
  }

  @override
  String errorRecordVideo(Object message) {
    return 'Erro ao gravar vídeo: $message';
  }

  @override
  String errorStartRecording(Object message) {
    return 'Erro ao iniciar gravação: $message';
  }

  @override
  String errorPauseRecording(Object message) {
    return 'Erro ao pausar gravação: $message';
  }

  @override
  String errorResumeRecording(Object message) {
    return 'Erro ao retomar gravação: $message';
  }

  @override
  String errorStopRecording(Object message) {
    return 'Erro ao parar gravação: $message';
  }

  @override
  String errorSelectAudios(Object message) {
    return 'Erro ao selecionar áudios: $message';
  }

  @override
  String get errorLoadVideo => 'Erro ao carregar vídeo';

  @override
  String get errorSelectImage => 'Erro ao selecionar imagem';

  @override
  String get imagePickerTitleMultiple => 'Adicionar Fotos';

  @override
  String get imagePickerTitleSingle => 'Adicionar Foto';

  @override
  String get imagePickerChooseOptionMultiple =>
      'Escolha uma opção (galeria permite múltiplas fotos):';

  @override
  String get imagePickerChooseOptionSingle => 'Escolha uma opção:';

  @override
  String get imagePickerGalleryMultiple => 'Selecionar da galeria';

  @override
  String get imagePickerGallerySingle => 'Buscar na galeria';

  @override
  String get imagePickerTakePhoto => 'Tirar uma foto';

  @override
  String get audioPickerTitleMultiple => 'Adicionar Áudios';

  @override
  String get audioPickerTitleSingle => 'Adicionar Áudio';

  @override
  String get audioPickerChooseOptionMultiple =>
      'Escolha uma opção (arquivos permite múltiplos áudios):';

  @override
  String get audioPickerChooseOptionSingle => 'Escolha uma opção:';

  @override
  String get audioPickerSelectFilesMultiple => 'Selecionar arquivos de áudio';

  @override
  String get audioPickerSelectFilesSingle => 'Buscar arquivo de áudio';

  @override
  String get audioPickerRecord => 'Gravar um áudio';

  @override
  String get videoPickerTitleMultiple => 'Adicionar Vídeos';

  @override
  String get videoPickerTitleSingle => 'Adicionar Vídeo';

  @override
  String get videoPickerChooseOptionMultiple =>
      'Escolha uma opção (arquivos permite múltiplos vídeos):';

  @override
  String get videoPickerChooseOptionSingle => 'Escolha uma opção:';

  @override
  String get videoPickerSelectFilesMultiple => 'Selecionar arquivos de vídeo';

  @override
  String get videoPickerSelectFilesSingle => 'Buscar arquivo de vídeo';

  @override
  String get videoPickerRecord => 'Gravar um vídeo';

  @override
  String get successVideoAdded => 'Vídeo adicionado com sucesso!';

  @override
  String successVideosAdded(Object count) {
    return '$count vídeos adicionados com sucesso!';
  }

  @override
  String get startRecording => 'Iniciar Gravação';

  @override
  String get recordingPaused => 'Gravação Pausada';

  @override
  String get recording => 'Gravando...';

  @override
  String get readyToRecord => 'Pronto para Gravar';

  @override
  String get notificationDialogTitle => 'Agendar Notificação';

  @override
  String get notificationDialogPrompt =>
      'Quando você gostaria de ser notificado sobre esta entrada?';

  @override
  String get emailAlreadyRegistered => 'E-mail já cadastrado.';

  @override
  String get successNotificationScheduled => 'Notificação agendada com sucesso';

  @override
  String notificationReminderTitle(Object title) {
    return 'Lembrete: $title';
  }

  @override
  String get successImageAdded => 'Imagem adicionada com sucesso!';

  @override
  String successImagesAdded(Object count) {
    return '$count imagens adicionadas com sucesso!';
  }

  @override
  String errorSearch(Object message) {
    return 'Erro na pesquisa: $message';
  }

  @override
  String get successStoryRestored => 'História restaurada com sucesso';

  @override
  String get successStoryDeletedPermanently =>
      'História excluída permanentemente';

  @override
  String get trashAlreadyEmpty => 'A lixeira já está vazia';

  @override
  String get successVideoRecorded => 'Vídeo gravado com sucesso!';

  @override
  String get permissionMicrophoneDenied =>
      'Permissão de microfone não concedida';

  @override
  String errorSelectImages(Object message) {
    return 'Erro ao selecionar imagens: $message';
  }

  @override
  String get successPhotoCaptured => 'Foto capturada com sucesso!';

  @override
  String get restoreStoriesTitle => 'Restaurar histórias';

  @override
  String restoreStoriesConfirm(Object count) {
    return 'Deseja restaurar $count história(s) selecionada(s)?';
  }

  @override
  String get restoreLabel => 'Restaurar';

  @override
  String get permanentlyDeleteTitle => 'Excluir permanentemente';

  @override
  String get permanentlyDeleteConfirm =>
      'Esta ação não pode ser desfeita. Deseja realmente excluir esta história permanentemente?';

  @override
  String get permanentlyDeleteLabel => 'Excluir permanentemente';

  @override
  String deleteGroupConfirm(Object name) {
    return 'Deseja remover o grupo \"$name\" das suas histórias?';
  }

  @override
  String get recoverPinDescription =>
      'Enviaremos um código de recuperação para o seu e-mail cadastrado.';

  @override
  String errorTakePhoto(Object message) {
    return 'Erro ao tirar foto: $message';
  }

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
  String errorSavingStory(Object error) {
    return 'Erro ao salvar história: $error';
  }

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
  String errorLoadingFile(Object error) {
    return 'Erro ao carregar arquivo: $error';
  }

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

  @override
  String get photoTooltip => 'Foto';

  @override
  String get videoTooltip => 'Vídeo';

  @override
  String get audioTooltip => 'Áudio';

  @override
  String get emojiTooltip => 'Emoji';

  @override
  String get editDescription => 'Editar Descrição';

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
