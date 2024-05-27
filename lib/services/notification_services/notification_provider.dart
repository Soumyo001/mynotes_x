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
  Future<void> cancel(int id);
  BehaviorSubject<String?> get onClick;
}
