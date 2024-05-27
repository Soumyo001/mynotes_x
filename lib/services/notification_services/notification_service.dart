import 'package:mynotes_x/services/notification_services/flutter_notification_provider.dart';
import 'package:mynotes_x/services/notification_services/notification_provider.dart';
import 'package:rxdart/rxdart.dart';

class NotificationService implements CustomNotificationProvider {
  final CustomNotificationProvider notificationProvider;

  const NotificationService({required this.notificationProvider});
  static final NotificationService _shared =
      NotificationService(notificationProvider: FlutterNotificationProvider());

  factory NotificationService.getInstance() => _shared;

  @override
  Future<void> initNotification({bool isScheduled = false}) =>
      notificationProvider.initNotification(
        isScheduled: isScheduled,
      );

  @override
  BehaviorSubject<String?> get onClick => notificationProvider.onClick;

  @override
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) =>
      notificationProvider.showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
        scheduledDate: scheduledDate,
      );

  @override
  Future<void> showNotificationDaily({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) =>
      notificationProvider.showNotificationDaily(
        id: id,
        title: title,
        body: body,
        payload: payload,
        scheduledDate: scheduledDate,
      );

  @override
  Future<void> showNotificationWeekly({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
    required List<int> days,
  }) =>
      notificationProvider.showNotificationWeekly(
        id: id,
        title: title,
        body: body,
        payload: payload,
        scheduledDate: scheduledDate,
        days: days,
      );

  @override
  Future<void> cancel(int id) => notificationProvider.cancel(id);
}
