import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:mynotes_x/services/notification_services/notification_provider.dart';
import 'package:mynotes_x/services/notification_services/notification_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart' as tz;

class FlutterNotificationProvider implements CustomNotificationProvider {
  final _notifications = FlutterLocalNotificationsPlugin();
  final _onClick = BehaviorSubject<String?>();
  String _currentZone = '';

  static void _onNotificationTap(NotificationResponse notificationResponse) {
    try {
      NotificationService.getInstance()
          .onClick
          .add(notificationResponse.payload!);
    } catch (e) {
      //do nothing
    }
  }

  Future<NotificationDetails> _notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'Push Notification',
        channelDescription: 'channel description',
        priority: Priority.high,
        importance: Importance.max,
        icon: '@mipmap/app_logo_main',
        enableLights: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
      ),
    );
  }

  @override
  Future<void> initNotification({bool isScheduled = false}) async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestExactAlarmsPermission();
    const android = AndroidInitializationSettings('@mipmap/app_logo_main');
    final iOS = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {
        try {
          NotificationService.getInstance().onClick.add(payload!);
        } catch (e) {
          //do nothing
        }
      },
    );
    final initializationSettings = InitializationSettings(
      android: android,
      iOS: iOS,
    );
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
    );
    if (isScheduled) {
      tz.initializeTimeZones();
      _currentZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(_currentZone));
    }
  }

  @override
  BehaviorSubject<String?> get onClick => _onClick;

  @override
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) async {
    final now = tz.TZDateTime.now(tz.getLocation(_currentZone));
    final scheduledTime =
        tz.TZDateTime.from(scheduledDate, tz.getLocation(_currentZone));
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      (scheduledTime.isBefore(now)
          ? scheduledTime.add(const Duration(days: 1))
          : scheduledTime),
      await _notificationDetails(),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> showNotificationDaily({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) async =>
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        _scheduleDaily(
          scheduledDate,
        ),
        await _notificationDetails(),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

  @override
  Future<void> showNotificationWeekly({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
    required List<int> days,
  }) async =>
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        _scheduleWeekly(
          scheduledDate,
          days: days,
        ),
        await _notificationDetails(),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

  tz.TZDateTime _scheduleDaily(DateTime dateTime) {
    final now = TZDateTime.now(tz.getLocation(_currentZone));
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.getLocation(_currentZone),
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(
        const Duration(
          days: 1,
        ),
      );
    }
    return scheduledDate;
  }

  tz.TZDateTime _scheduleWeekly(
    DateTime dateTime, {
    required List<int> days,
  }) {
    tz.TZDateTime scheduledDate = _scheduleDaily(dateTime);
    while (!days.contains(scheduledDate.weekday)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  @override
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}
