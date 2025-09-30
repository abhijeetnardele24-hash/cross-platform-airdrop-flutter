import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    _isInitialized = true;
  }

  Future<void> showTransferNotification(
    String transferId,
    String title,
    String body,
    double progress,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      'transfer_channel',
      'File Transfers',
      channelDescription: 'Notifications for file transfer progress',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: (progress * 100).toInt(),
      ongoing: true,
      autoCancel: false,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      transferId.hashCode,
      title,
      body,
      details,
    );
  }

  Future<void> showCompletionNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'transfer_channel',
      'File Transfers',
      channelDescription: 'Notifications for file transfer progress',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> init(Function? onSelectNotification) async {
    await initialize();
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await showCompletionNotification(title, body);
  }
}
