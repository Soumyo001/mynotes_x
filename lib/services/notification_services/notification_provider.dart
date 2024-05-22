import 'package:rxdart/rxdart.dart';

abstract class CustomNotificationProvider {
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  });
  Future<void> showNotificationDaily({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  });
  Future<void> showNotificationWeekly({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
    required List<int> days,
  });
  Future<void> initNotification({
    bool isScheduled = false,
  });
  BehaviorSubject<String?> get onClick;
}
