import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/insight.dart';
import '../theme/animation_durations.dart';
import '../widgets/mood_energy_selectors.dart';

/// Card que exibe um insight gerado automaticamente no feed da Home.
///
/// Layout:
/// ```
/// [ícone] [título]
/// [descrição]
/// [ Ver histórias ]  ← opcional
/// ```
class InsightCard extends StatelessWidget {
  final Insight insight;

  /// Chamado quando o usuário toca em "Ver histórias" (apenas para insights
  /// com tag associada). Recebe o nome da tag como argumento.
  final void Function(String tag)? onSeeStories;

  const InsightCard({required this.insight, this.onSeeStories, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final title = _resolveTitle(l10n);
    final description = _resolveDescription(l10n);
    final tag = insight.metadata?['tag'] as String?;
    final showButton = onSeeStories != null && tag != null && tag.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: AnimatedContainer(
        duration: AppDurations.short,
        child: Card(
          elevation: 0,
          color: colorScheme.secondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.secondary.withValues(alpha: 0.25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cabeçalho: ícone + título
                Row(
                  children: [
                    Text(insight.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                // Botão de ação opcional
                if (showButton) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => onSeeStories!(tag),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.secondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      child: Text(l10n.insightSeeStories),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Resolução de título a partir da chave l10n
  // ---------------------------------------------------------------------------

  String _resolveTitle(AppLocalizations l10n) {
    switch (insight.type) {
      case InsightType.bestWeekday:
        return l10n.insightDiscovery;
      case InsightType.positiveTag:
        return l10n.insightPattern;
      case InsightType.trend:
        return l10n.insightTrend;
      case InsightType.monthlySummary:
        return l10n.insightMonthlySummary;
    }
  }

  // ---------------------------------------------------------------------------
  // Resolução de descrição a partir dos metadados e chaves l10n
  // ---------------------------------------------------------------------------

  String _resolveDescription(AppLocalizations l10n) {
    switch (insight.type) {
      case InsightType.bestWeekday:
        return _resolveBestWeekday(l10n);
      case InsightType.positiveTag:
        return _resolvePositiveTag(l10n);
      case InsightType.trend:
        return l10n.insightTrendPositive;
      case InsightType.monthlySummary:
        return _resolveMonthlySummary(l10n);
    }
  }

  String _resolveBestWeekday(AppLocalizations l10n) {
    final index = insight.metadata?['weekday_index'] as int? ?? 0;
    final weekday = _weekdayName(l10n, index);
    return l10n.insightBestWeekday(weekday);
  }

  String _resolvePositiveTag(AppLocalizations l10n) {
    final tag = insight.metadata?['tag'] as String? ?? '';
    return l10n.insightPositiveTag(tag);
  }

  String _resolveMonthlySummary(AppLocalizations l10n) {
    final total = insight.metadata?['total'] as int? ?? 0;
    final humorMedio =
        (insight.metadata?['humor_medio'] as num?)?.toDouble() ?? 0.0;
    final energiaMedia =
        (insight.metadata?['energia_media'] as num?)?.toDouble() ?? 0.0;
    final topTag = insight.metadata?['top_tag'] as String?;

    // Converte médias numéricas para emojis representativos
    final moodStr = moodEmoji(humorMedio.round().clamp(1, 5));
    final energyStr = _energyEmoji(energiaMedia.round().clamp(1, 3));

    if (topTag != null && topTag.isNotEmpty) {
      return l10n.insightMonthlySummaryWithTag(
        total,
        moodStr,
        energyStr,
        topTag,
      );
    }
    return l10n.insightMonthlySummaryText(total, moodStr, energyStr);
  }

  /// Mapeia índice do SQLite strftime('%w') para nome localizado do dia.
  String _weekdayName(AppLocalizations l10n, int index) {
    switch (index) {
      case 0:
        return l10n.weekdaySunday;
      case 1:
        return l10n.weekdayMonday;
      case 2:
        return l10n.weekdayTuesday;
      case 3:
        return l10n.weekdayWednesday;
      case 4:
        return l10n.weekdayThursday;
      case 5:
        return l10n.weekdayFriday;
      case 6:
        return l10n.weekdaySaturday;
      default:
        return '';
    }
  }

  /// Converte valor numérico de energia (1–3) para emojis de bateria.
  String _energyEmoji(int value) {
    switch (value) {
      case 1:
        return '🔋';
      case 2:
        return '🔋🔋';
      case 3:
        return '🔋🔋🔋';
      default:
        return '🔋🔋';
    }
  }
}
