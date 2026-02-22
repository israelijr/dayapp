import 'package:flutter/material.dart';

import '../services/battery_optimization_service.dart';

/// Dialog que informa o usuário sobre as configurações de bateria necessárias
/// para o funcionamento correto do app.
class BatteryOptimizationDialog extends StatefulWidget {
  const BatteryOptimizationDialog({super.key});

  /// Mostra o dialog de otimização de bateria
  ///
  /// Retorna true se o usuário configurou, false se dispensou, null se fechou
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const BatteryOptimizationDialog(),
    );
  }

  @override
  State<BatteryOptimizationDialog> createState() =>
      _BatteryOptimizationDialogState();
}

class _BatteryOptimizationDialogState extends State<BatteryOptimizationDialog> {
  final _batteryService = BatteryOptimizationService();
  bool _isLoading = false;
  bool? _isOptimizationDisabled;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final status = await _batteryService.isBatteryOptimizationDisabled();
    if (mounted) {
      setState(() {
        _isOptimizationDisabled = status;
      });
    }
  }

  Future<void> _openSettings() async {
    setState(() => _isLoading = true);

    await _batteryService.requestDisableBatteryOptimization();

    // Aguarda um pouco para o usuário configurar
    await Future.delayed(const Duration(milliseconds: 500));

    // Verifica novamente o status
    await _checkStatus();

    if (mounted) {
      setState(() => _isLoading = false);

      // Se o usuário configurou, fecha o dialog
      if (_isOptimizationDisabled == true) {
        await _batteryService.markBatteryDialogAsShown();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    }
  }

  Future<void> _dismiss() async {
    await _batteryService.dismissBatteryDialog();
    if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _later() async {
    await _batteryService.markBatteryDialogAsShown();
    if (mounted) {
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      icon: Icon(
        _isOptimizationDisabled == true
            ? Icons.check_circle
            : Icons.battery_alert,
        size: 48,
        color: _isOptimizationDisabled == true
            ? colorScheme.primary
            : colorScheme.error,
      ),
      title: Text(
        _isOptimizationDisabled == true
            ? 'Configuração concluída!'
            : 'Configuração necessária',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isOptimizationDisabled == true) ...[
              const Text(
                'O DayApp está configurado para enviar lembretes corretamente.',
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const Text(
                'Para receber lembretes de registrar suas histórias, '
                'o DayApp precisa de permissão para rodar em segundo plano.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sem esta configuração:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.close, size: 16, color: colorScheme.error),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Lembretes de reflexão não serão enviados',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.close, size: 16, color: colorScheme.error),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Notificações de histórias podem falhar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Toque em "Configurar" para abrir as configurações do sistema.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_isOptimizationDisabled == true)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continuar'),
          )
        else ...[
          TextButton(
            onPressed: _dismiss,
            child: const Text('Não mostrar novamente'),
          ),
          TextButton(onPressed: _later, child: const Text('Depois')),
          FilledButton(
            onPressed: _isLoading ? null : _openSettings,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Configurar'),
          ),
        ],
      ],
      actionsAlignment: MainAxisAlignment.end,
    );
  }
}
