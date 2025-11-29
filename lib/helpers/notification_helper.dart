import 'dart:io';

import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../services/notification_preferences_service.dart';
import '../services/notification_service.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final NotificationService _notificationService = NotificationService();
  final NotificationPreferencesService _prefsService =
      NotificationPreferencesService();

  /// Verifica se uma data permite agendar notificação (mínimo 2h de antecedência)
  bool shouldScheduleNotification(DateTime entryDate) {
    final now = DateTime.now();
    final difference = entryDate.difference(now);
    return difference.inHours >= 2;
  }

  /// Calcula o horário da notificação baseado na antecedência
  DateTime? calculateNotificationTime(
    DateTime entryDate,
    int advanceMinutes,
  ) {
    // Notificação ANTES da data da entrada
    final notificationTime = entryDate.subtract(Duration(minutes: advanceMinutes));
    
    // Verifica se a notificação não seria no passado
    if (notificationTime.isBefore(DateTime.now())) {
      return null;
    }
    
    return notificationTime;
  }

  /// Mostra o dialog de seleção de antecedência para notificação
  Future<void> showNotificationDialog(
    BuildContext context,
    int historiaId,
    DateTime entryDate,
    String title,
    String? description,
  ) async {
    // Verifica se notificações estão habilitadas
    final enabled = await _prefsService.isNotificationEnabled();
    if (!enabled) return;

    // Verifica se a data permite notificação
    if (!shouldScheduleNotification(entryDate)) {
      return; // Data muito próxima (menos de 2 horas)
    }

    // Obtém a antecedência padrão
    final defaultAdvance = await _prefsService.getDefaultNotificationAdvance();
    
    if (!context.mounted) return;

    int? selectedAdvanceMinutes;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Agendar Notificação'),
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Quando você gostaria de ser notificado sobre esta entrada?',
              ),
            ),
            ...NotificationPreferencesService.advanceOptions.map(
              (minutes) {
                final notificationTime =
                    calculateNotificationTime(entryDate, minutes);
                final isDefault = minutes == defaultAdvance;
                
                // Desabilita opção se resultar em notificação no passado
                final isEnabled = notificationTime != null;
                
                return SimpleDialogOption(
                  onPressed: isEnabled
                      ? () {
                          selectedAdvanceMinutes = minutes;
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          NotificationPreferencesService.getAdvanceLabel(
                            minutes,
                          ),
                          style: TextStyle(
                            color: isEnabled ? null : Colors.grey,
                          ),
                        ),
                      ),
                      if (isDefault)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Chip(
                            label: Text('Padrão', style: TextStyle(fontSize: 10)),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );

    if (selectedAdvanceMinutes != null) {
      await scheduleEntryNotification(
        historiaId,
        entryDate,
        title,
        description,
        selectedAdvanceMinutes!,
      );
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificação agendada com sucesso')),
      );
    }
  }

  /// Agenda uma notificação para uma entrada
  Future<void> scheduleEntryNotification(
    int historiaId,
    DateTime entryDate,
    String title,
    String? description,
    int advanceMinutes,
  ) async {
    // Calcula o horário da notificação
    final notificationTime = calculateNotificationTime(
      entryDate,
      advanceMinutes,
    );

    if (notificationTime == null) {

      return;
    }

    // Cancela notificação antiga se existir
    await cancelEntryNotification(historiaId);

    // Agenda a nova notificação
    final notificationId = historiaId;
    
    if (Platform.isWindows) {

    } else {
      await _notificationService.scheduleNotification(
        id: notificationId,
        title: 'Lembrete: $title',
        body: description ?? 'Você tem uma entrada agendada',
        scheduledDate: notificationTime,
        payload: historiaId.toString(),
      );

      // Salva no banco de dados
      await DatabaseHelper().scheduleNotificationForHistoria(
        historiaId,
notificationId,
        notificationTime,
      );
    }
  }

  /// Cancela a notificação de uma entrada
  Future<void> cancelEntryNotification(int historiaId) async {
    final scheduled = await DatabaseHelper().getScheduledNotification(
      historiaId,
    );

    if (scheduled != null) {
      final notificationId = scheduled['notification_id'] as int;
      await _notificationService.cancelNotification(notificationId);
      await DatabaseHelper().cancelScheduledNotification(historiaId);
    }
  }

  /// Reagenda notificação quando a data da entrada muda
  Future<void> rescheduleEntryNotification(
    int historiaId,
    DateTime oldDate,
    DateTime newDate,
    String title,
    String? description,
  ) async {
    // Cancela a notificação antiga
    await cancelEntryNotification(historiaId);

    // Se a nova data permitir, agenda novamente
    if (shouldScheduleNotification(newDate)) {
      final defaultAdvance = await _prefsService.getDefaultNotificationAdvance();
      await scheduleEntryNotification(
        historiaId,
        newDate,
        title,
        description,
        defaultAdvance,
      );
    }
  }
}
