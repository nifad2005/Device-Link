import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'settings_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final SettingsService _settings = SettingsService();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _notifications.initialize(initSettings);
  }

  Future<void> showFileTransferComplete(String fileName) async {
    if (!_settings.globalNotifications.value || !_settings.notifyFileTransfers.value) return;

    const androidDetails = AndroidNotificationDetails(
      'file_transfers',
      'File Transfers',
      channelDescription: 'Notifications for completed file transfers',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      'File Received',
      '$fileName is ready to open.',
      notificationDetails,
    );
  }

  Future<void> showConnectionStatus(String deviceName, bool isConnected) async {
    if (!_settings.globalNotifications.value || !_settings.notifyConnections.value) return;

    final androidDetails = AndroidNotificationDetails(
      'connections',
      'Device Connections',
      channelDescription: 'Notifications for device link status',
      importance: Importance.low,
      priority: Priority.low,
    );
    
    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1,
      isConnected ? 'Device Linked' : 'Device Disconnected',
      isConnected ? 'Connected to $deviceName' : '$deviceName is no longer active',
      notificationDetails,
    );
  }
  
  Future<void> showPowerCommandAlert(String action) async {
    if (!_settings.globalNotifications.value || !_settings.notifyPowerCommands.value) return;

    const androidDetails = AndroidNotificationDetails(
      'power_commands',
      'Power Commands',
      channelDescription: 'Alerts for remote power actions',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      2,
      'System Alert',
      'Remote $action command received.',
      notificationDetails,
    );
  }
}
