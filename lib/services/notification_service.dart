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
    tz.initializeTimeZones();

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
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
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
      debugPrint('NotificationService: Agendando zonedSchedule');
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
        debugPrint('NotificationService: Notificação agendada com sucesso');
      } catch (e) {
        debugPrint('NotificationService: Erro ao agendar notificação: $e');
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
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
