import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init(Function(String?) onSelectNotification) async {
    // Inicializa timezones
    tz.initializeTimeZones();
    
    // CRÍTICO: Define o timezone local para São Paulo (Brasil)
    // Sem isso, notificações são agendadas em UTC causando erro de 3h
    final brazilLocation = tz.getLocation('America/Sao_Paulo');
    tz.setLocalLocation(brazilLocation);
    
    debugPrint('NotificationService: Timezone configurado para ${tz.local.name}');

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          linux: initializationSettingsLinux,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onSelectNotification(response.payload);
      },
    );

    // Solicitar permissões
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    
    if (androidImplementation != null) {
      // Solicita permissão de notificações
      await androidImplementation.requestNotificationsPermission();
      
      // Android 12+ requer permissão específica para alarmes exatos
      debugPrint('NotificationService: Solicitando permissão de alarmes exatos...');
      final permissionGranted = await androidImplementation.requestExactAlarmsPermission();
      debugPrint('NotificationService: Permissão de alarmes exatos concedida: $permissionGranted');
      
      // Verifica se a permissão está realmente ativa
      final canScheduleExact = await androidImplementation.canScheduleExactNotifications();
      debugPrint('NotificationService: Pode agendar alarmes exatos: $canScheduleExact');
      
      if (canScheduleExact == false) {
        debugPrint('⚠️ AVISO: Permissão de alarmes exatos NÃO está ativa!');
        debugPrint('⚠️ Vá em Configurações > Apps > DayApp > Alarmes e lembretes');
      }
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    debugPrint(
      'NotificationService: Agendando notificação ID $id para $scheduledDate',
    );
    final notificationDetails = const NotificationDetails(
      android: AndroidNotificationDetails(
        'historia_channel',
        'Histórias',
        channelDescription: 'Notificações para histórias',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
    );

    if (Platform.isWindows) {
      // Para Windows, notificações agendadas podem não ser suportadas
      // Vamos mostrar uma notificação imediata para teste
      debugPrint(
        'NotificationService: Windows - mostrando notificação imediata',
      );
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } else {
      // Para outras plataformas, usar zonedSchedule
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
        debugPrint('NotificationService: Notificação agendada com sucesso');
        
        // Lista notificações pendentes para debug
        await listPendingNotifications();
      } catch (e) {
        debugPrint('NotificationService: Erro ao agendar notificação: $e');
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
  
  /// Lista todas as notificações pendentes (para debug)
  Future<void> listPendingNotifications() async {
    final pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    debugPrint('📋 Notificações pendentes no sistema: ${pending.length}');
    for (var notification in pending) {
      debugPrint('  - ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
    }
    if (pending.isEmpty) {
      debugPrint('  ⚠️ Nenhuma notificação pendente encontrada!');
    }
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'historia_channel',
        'Histórias',
        channelDescription: 'Notificações para histórias',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
