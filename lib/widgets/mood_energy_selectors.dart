import 'package:dayapp/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Seletor de humor com quatro opções: Difícil, Neutro, Bom, Muito bom
class MoodSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const MoodSelector({required this.value, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final options = [
      (1, '😞', loc.moodDifficult),
      (2, '😐', loc.moodNeutral),
      (3, '🙂', loc.moodGood),
      (4, '😄', loc.moodVeryGood),
    ];
    return SegmentedOptions<int>(
      options: options,
      selected: value,
      onChanged: onChanged,
    );
  }
}

/// Seletor de energia com três opções: Baixa, Normal, Alta
class EnergySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const EnergySelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final options = [
      (1, '🔋', loc.energyLow),
      (2, '🔋🔋', loc.energyNormal),
      (3, '🔋🔋🔋', loc.energyHigh),
    ];
    return SegmentedOptions<int>(
      options: options,
      selected: value,
      onChanged: onChanged,
    );
  }
}

/// Widget genérico de seleção segmentada com emoji + rótulo
class SegmentedOptions<T> extends StatelessWidget {
  final List<(T, String, String)> options; // (valor, emoji, rótulo)
  final T selected;
  final ValueChanged<T> onChanged;

  const SegmentedOptions({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: options.map((opt) {
        final (val, emoji, label) = opt;
        final isSelected = val == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: () => onChanged(val),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
