import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/tag_helper.dart';
import '../models/historia.dart';
import '../models/tag.dart';

class CompactHistoriaCard extends StatelessWidget {
  final Historia historia;
  final String localeName;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final bool showMood;

  const CompactHistoriaCard({
    required this.historia,
    required this.localeName,
    this.trailing,
    this.onTap,
    this.margin = const EdgeInsets.only(bottom: 12),
    this.showMood = true,
    super.key,
  });

  String? _convertLegacyEmoticon(String emoticon) {
    switch (emoticon) {
      case 'Feliz':
        return '😊';
      case 'Tranquilo':
        return '😌';
      case 'Aliviado':
        return '😮‍💨';
      case 'Pensativo':
        return '🤔';
      case 'Sono':
        return '😴';
      case 'Preocupado':
        return '😟';
      case 'Assustado':
        return '😨';
      case 'Bravo':
        return '😠';
      case 'Triste':
        return '😢';
      case 'Muito Triste':
        return '😭';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: margin,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Builder(
                    builder: (context) {
                      if (historia.emoticon != null &&
                          historia.emoticon!.isNotEmpty) {
                        final converted = _convertLegacyEmoticon(
                          historia.emoticon!,
                        );
                        final display = converted ?? historia.emoticon!;
                        return Text(
                          display,
                          style: const TextStyle(fontSize: 20, height: 1),
                        );
                      }
                      return Icon(
                        Icons.auto_stories_outlined,
                        color: Theme.of(context).iconTheme.color,
                        size: 24,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      historia.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          DateFormat(
                            'dd/MM/yyyy',
                            localeName,
                          ).format(historia.data),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        if (showMood) ...[
                          const SizedBox(width: 8),
                          _MoodDot(mood: historia.humor),
                        ],
                      ],
                    ),
                    if (historia.id != null) ...[
                      const SizedBox(height: 6),
                      FutureBuilder<List<Tag>>(
                        future: TagHelper().getTagsByHistoria(historia.id!),
                        builder: (context, snapshot) {
                          final newTags = snapshot.data ?? const <Tag>[];
                          final legacyTag = historia.tag;
                          final tagNames = newTags.isNotEmpty
                              ? newTags
                                    .map((tag) => tag.nome)
                                    .toList(growable: false)
                              : (legacyTag != null && legacyTag.isNotEmpty
                                    ? <String>[legacyTag]
                                    : const <String>[]);

                          if (tagNames.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: tagNames
                                .map(
                                  (name) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? colorScheme.primaryContainer
                                          : colorScheme.primaryContainer
                                                .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? colorScheme.onPrimaryContainer
                                            : colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 48),
                  child: trailing!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Bolinha colorida indicando o humor da história (escala 1-5).
class _MoodDot extends StatelessWidget {
  final int mood;
  const _MoodDot({required this.mood});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fraction = ((mood - 1) / 4).clamp(0.0, 1.0);

    final Color color;
    if (fraction < 0.33) {
      color = colorScheme.error;
    } else if (fraction < 0.66) {
      color = colorScheme.tertiary;
    } else {
      color = colorScheme.primary;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
