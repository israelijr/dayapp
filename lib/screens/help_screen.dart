import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.help),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Introdução
          _buildSection(
            context,
            loc.helpAboutTitle,
            loc.helpAboutDescription,
            Icons.info_outline,
          ),

          const SizedBox(height: 24),

          // Navegação Principal
          _buildSection(
            context,
            loc.helpNavigationTitle,
            '',
            Icons.navigation,
            children: [
              _buildHelpItem(loc.home, loc.helpHomeItemDesc),
              _buildHelpItem(loc.groups, loc.helpGroupsNavDesc),
              _buildHelpItem(loc.search, loc.helpSearchItemDesc),
            ],
          ),

          const SizedBox(height: 24),

          // Criando Histórias
          _buildSection(
            context,
            loc.helpCreatingTitle,
            '',
            Icons.create,
            children: [
              _buildHelpItem(loc.newStory, loc.helpNewStoryDesc),
              _buildHelpItem(loc.helpTextEditorTitle, loc.helpTextEditorDesc),
              _buildHelpItem(loc.mediaLabel, loc.helpMediaDesc),
              _buildHelpItem(loc.groups, loc.helpGroupsAssocDesc),
            ],
          ),

          const SizedBox(height: 24),

          // Calendário
          _buildSection(
            context,
            loc.calendarTitle,
            loc.helpCalendarDesc,
            Icons.calendar_today,
          ),

          const SizedBox(height: 24),

          // Grupos
          _buildSection(
            context,
            loc.manageGroups,
            '',
            Icons.group,
            children: [
              _buildHelpItem(loc.helpCreateGroupTitle, loc.helpCreateGroupDesc),
              _buildHelpItem(loc.helpEditGroupTitle, loc.helpEditGroupDesc),
              _buildHelpItem(loc.helpGroupsAssocDesc, loc.helpGroupsAssocDesc),
            ],
          ),

          const SizedBox(height: 24),

          // Backup e Segurança
          _buildSection(
            context,
            loc.helpBackupSecurityTitle,
            '',
            Icons.security,
            children: [
              _buildHelpItem(
                loc.helpAutomaticBackupTitle,
                loc.helpAutomaticBackupDesc,
              ),
              _buildHelpItem(
                loc.helpManualBackupTitle,
                loc.helpManualBackupDesc,
              ),
              _buildHelpItem(loc.helpRestoreTitle, loc.helpRestoreDesc),
              _buildHelpItem(loc.helpPinSecurityTitle, loc.helpPinSecurityDesc),
              _buildHelpItem(loc.biometrics, loc.helpBiometricsDesc),
              _buildHelpItem(
                loc.helpPasswordUnlockTitle,
                loc.helpPasswordUnlockDesc,
              ),
              _buildHelpItem(loc.backgroundLock, loc.helpBackgroundLockDesc),
              _buildHelpItem(
                loc.helpLockExceptionsTitle,
                loc.helpLockExceptionsDesc,
              ),
              _buildHelpItem(loc.helpPinRecoveryTitle, loc.helpPinRecoveryDesc),
            ],
          ),

          const SizedBox(height: 24),

          // Configurações
          _buildSection(
            context,
            loc.settings,
            '',
            Icons.settings,
            children: [
              _buildHelpItem(loc.theme, loc.helpThemeDesc),
              _buildHelpItem(
                loc.notifications,
                loc.helpNotificationsSettingsDesc,
              ),
              _buildHelpItem(
                loc.backgroundLock,
                loc.helpBackgroundLockSettingsDesc,
              ),
              _buildHelpItem(
                loc.helpBackupSettingTitle,
                loc.helpBackupSettingDesc,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Lixeira
          _buildSection(
            context,
            loc.trash,
            loc.helpTrashDesc,
            Icons.delete_outline,
          ),

          const SizedBox(height: 24),

          // Estatísticas
          _buildSection(
            context,
            loc.statistics,
            loc.helpStatisticsDesc,
            Icons.analytics,
          ),

          const SizedBox(height: 24),

          // Dicas de Uso
          _buildSection(
            context,
            loc.helpTipsTitle,
            '',
            Icons.lightbulb,
            children: [
              _buildHelpItem(
                loc.helpOrganizationTipTitle,
                loc.helpOrganizationTipDesc,
              ),
              _buildHelpItem(loc.helpSearchTipTitle, loc.helpSearchTipDesc),
              _buildHelpItem(loc.helpBackupTipTitle, loc.helpBackupTipDesc),
              _buildHelpItem(loc.helpPrivacyTipTitle, loc.helpPrivacyTipDesc),
            ],
          ),

          const SizedBox(height: 24),

          // Suporte
          _buildSection(
            context,
            loc.helpSupportTitle,
            loc.helpSupportDesc,
            Icons.support,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    IconData icon, {
    List<Widget>? children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                ),
              ),
            ],
            if (children != null) ...[const SizedBox(height: 16), ...children],
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
