import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_service.dart';

/// Serviço de backup automático ao fazer logout
///
/// Gerencia as configurações e executa a criação do backup
/// usando o BackupService existente. O compartilhamento/salvamento
/// é feito pela camada de UI via share_plus.
class AutoBackupService {
  static final AutoBackupService _instance = AutoBackupService._internal();
  factory AutoBackupService() => _instance;
  AutoBackupService._internal();

  // Chaves do SharedPreferences
  static const String _keyEnabled = 'auto_backup_enabled';
  static const String _keyLastBackup = 'auto_backup_last_backup';

  final BackupService _backupService = BackupService();

  /// Verifica se o backup automático está habilitado
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? false;
  }

  /// Habilita ou desabilita o backup automático
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, enabled);
  }

  /// Retorna a data/hora do último backup automático
  Future<DateTime?> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBackupStr = prefs.getString(_keyLastBackup);
    if (lastBackupStr != null) {
      return DateTime.tryParse(lastBackupStr);
    }
    return null;
  }

  /// Salva a data/hora do último backup
  Future<void> _setLastBackupTime(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastBackup, dateTime.toIso8601String());
  }

  /// Verifica se a configuração está completa (habilitado)
  Future<bool> isConfigured() async {
    return await isEnabled();
  }

  /// Cria o arquivo ZIP de backup e retorna o caminho.
  ///
  /// O arquivo é criado no diretório temporário do app.
  /// A camada de UI deve usar share_plus para permitir
  /// que o usuário escolha onde salvar.
  /// Chama [onProgress] para atualizar a UI.
  /// Retorna o caminho do ZIP ou null em caso de erro.
  Future<String?> executeBackup({void Function(String)? onProgress}) async {
    try {
      final enabled = await isEnabled();
      if (!enabled) return null;

      onProgress?.call('Criando backup...');
      final zipPath = await _backupService.createBackupZipFile(
        onProgress: onProgress,
      );

      // Registra o horário do backup
      await _setLastBackupTime(DateTime.now());
      onProgress?.call('Backup criado! Escolha onde salvar...');
      return zipPath;
    } catch (e) {
      debugPrint('Erro no backup automático: $e');
      onProgress?.call('Erro ao criar backup: $e');
      return null;
    }
  }

  /// Limpa todas as configurações do backup automático
  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEnabled);
    await prefs.remove(_keyLastBackup);
  }
}
