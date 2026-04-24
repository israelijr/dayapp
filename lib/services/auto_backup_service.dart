import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';
import 'backup_service.dart';

/// Serviço de backup automático ao fazer logout
///
/// Gerencia as configurações, executa a criação do backup e o armazena
/// usando o BackupService existente. O backup é salvo em pasta local do app
/// com retenção automática dos últimos 5 backups.
///
/// O compartilhamento/sincronização é feito manualmente pela camada de UI.
class AutoBackupService {
  static final AutoBackupService _instance = AutoBackupService._internal();
  factory AutoBackupService() => _instance;
  AutoBackupService._internal();

  // Chaves do SharedPreferences
  static const String _keyEnabled = 'auto_backup_enabled';
  static const String _keyLastBackup = 'auto_backup_last_backup';
  static const String _backupsDirName = 'auto_backups';
  static const int _maxBackupsRetention = 5;

  final BackupService _backupService = BackupService();

  /// Obtém o diretório onde os backups automáticos são armazenados
  Future<Directory> _getBackupsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupsDir = Directory(path.join(appDir.path, _backupsDirName));
    if (!await backupsDir.exists()) {
      await backupsDir.create(recursive: true);
    }
    return backupsDir;
  }

  /// Lista todos os backups automáticos locais ordenados por data (mais recentes primeiro)
  Future<List<File>> listLocalBackups() async {
    try {
      final backupsDir = await _getBackupsDirectory();
      final files = backupsDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.zip'))
          .toList();
      // Ordena por data de modificação (mais recentes primeiro)
      files.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );
      return files;
    } catch (e) {
      debugPrint('Erro ao listar backups locais: $e');
      return [];
    }
  }

  /// Remove backups antigos mantendo apenas os últimos [_maxBackupsRetention]
  Future<void> _applyRetention() async {
    try {
      final backups = await listLocalBackups();
      if (backups.length > _maxBackupsRetention) {
        // Remove os backups mais antigos
        for (int i = _maxBackupsRetention; i < backups.length; i++) {
          await backups[i].delete();
          debugPrint('Backup antigo deletado: ${backups[i].path}');
        }
      }
    } catch (e) {
      debugPrint('Erro ao aplicar retenção de backups: $e');
    }
  }

  /// Obtém tamanho total dos backups locais em bytes
  Future<int> getTotalBackupsSize() async {
    try {
      final backups = await listLocalBackups();
      int totalSize = 0;
      for (final file in backups) {
        if (await file.exists()) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('Erro ao calcular tamanho total dos backups: $e');
      return 0;
    }
  }

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

  /// Cria o arquivo ZIP de backup e o salva na pasta local do app.
  ///
  /// O arquivo é criado com timestamp no nome (backup_YYYY-MM-DDTHH-MM-SS.zip).
  /// A retenção de backups antigos é aplicada automaticamente (mantém últimos 5).
  /// Chama [onProgress] para atualizar a UI.
  /// Retorna o caminho do ZIP local ou null em caso de erro.
  Future<String?> executeBackup({
    required AppLocalizations l10n,
    void Function(String)? onProgress,
  }) async {
    try {
      final enabled = await isEnabled();
      if (!enabled) return null;

      onProgress?.call(l10n.backupStarting);

      final tempZipPath = await _backupService.createBackupZipFile(
        l10n: l10n,
        onProgress: onProgress,
      );

      // Move para pasta local com nome incluindo timestamp
      final backupsDir = await _getBackupsDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .substring(0, 19);
      final localZipPath = path.join(backupsDir.path, 'backup_$timestamp.zip');

      final tempFile = File(tempZipPath);
      final savedFile = await tempFile.rename(localZipPath);

      // Registra o horário do backup
      await _setLastBackupTime(DateTime.now());

      // Aplica retenção (remove backups antigos)
      await _applyRetention();

      onProgress?.call(l10n.autoBackupSavedLocal);
      return savedFile.path;
    } catch (e) {
      debugPrint('Erro no backup automático: $e');
      onProgress?.call(l10n.backupError(e.toString()));
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
