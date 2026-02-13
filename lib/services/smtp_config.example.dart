/// Configuração SMTP para envio de e-mails.
/// Este é um arquivo de EXEMPLO.
/// Copie para smtp_config.dart e preencha com suas credenciais reais.
/// NUNCA faça commit do arquivo smtp_config.dart no Git!
class SmtpConfig {
  /// Host do servidor SMTP
  /// Gmail: smtp.gmail.com
  /// Outlook: smtp-mail.outlook.com
  /// Yahoo: smtp.mail.yahoo.com
  static const String smtpHost = 'smtp.gmail.com';

  /// Porta do servidor SMTP (587 para STARTTLS, 465 para SSL)
  static const int smtpPort = 587;

  /// Usar SSL direto (porta 465) ou STARTTLS (porta 587)
  static const bool smtpSsl = false;

  /// E-mail remetente (conta que enviará os e-mails)
  static const String smtpUsername = 'SEU_EMAIL@gmail.com';

  /// Senha do e-mail ou "Senha de App" (para Gmail com 2FA)
  /// Para Gmail: gere em https://myaccount.google.com/apppasswords
  static const String smtpPassword = 'SUA_SENHA_DE_APP_AQUI';

  /// Nome exibido como remetente
  static const String senderName = 'DayApp';
}
