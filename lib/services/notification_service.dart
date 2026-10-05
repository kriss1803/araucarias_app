import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        // Aquí podremos manejar la notificación cuando el usuario la toque.
      },
    );

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final androidPermission =
        await androidImplementation?.requestNotificationsPermission();

    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    final iosPermission = await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return androidPermission ?? iosPermission ?? true;
  }

  NotificationDetails _notificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'reservas_channel',
      'Recordatorios de reservas',
      channelDescription:
          'Notificaciones relacionadas con las reservas de Araucarias.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  Future<void> showTestNotification() async {
    await initialize();

    await _notifications.show(
      id: 100,
      title: 'Araucarias',
      body: 'Esta es una notificación de prueba.',
      notificationDetails: _notificationDetails(),
    );
  }

  Future<void> scheduleReservationReminder({
    required int id,
    required String reservationName,
    required DateTime reservationDate,
  }) async {
    await initialize();

    final scheduledDate = tz.TZDateTime.from(
      reservationDate,
      tz.local,
    );

    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      throw ArgumentError(
        'La fecha del recordatorio debe estar en el futuro.',
      );
    }

    await _notifications.zonedSchedule(
      id: id,
      title: 'Recordatorio de reserva',
      body: 'Tienes una reserva: $reservationName',
      scheduledDate: scheduledDate,
      notificationDetails: _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(int id) async {
    await initialize();
    await _notifications.cancel(id: id);
  }
}