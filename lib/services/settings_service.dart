import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  late SharedPreferences _prefs;
  
  // Global Toggles
  final ValueNotifier<bool> globalNotifications = ValueNotifier(true);
  final ValueNotifier<bool> globalVibration = ValueNotifier(true);

  // Specific Notification Toggles
  final ValueNotifier<bool> notifyFileTransfers = ValueNotifier(true);
  final ValueNotifier<bool> notifyConnections = ValueNotifier(true);
  final ValueNotifier<bool> notifyPowerCommands = ValueNotifier(false);

  // Connection Settings
  final ValueNotifier<String?> lastConnectedAddress = ValueNotifier(null);
  final ValueNotifier<bool> autoConnect = ValueNotifier(true);

  // Other Settings
  final ValueNotifier<bool> startOnBoot = ValueNotifier(false);
  final ValueNotifier<double> trackpadSensitivity = ValueNotifier(1.0);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    globalNotifications.value = _prefs.getBool('globalNotifications') ?? true;
    globalVibration.value = _prefs.getBool('globalVibration') ?? true;
    
    notifyFileTransfers.value = _prefs.getBool('notifyFileTransfers') ?? true;
    notifyConnections.value = _prefs.getBool('notifyConnections') ?? true;
    notifyPowerCommands.value = _prefs.getBool('notifyPowerCommands') ?? false;
    
    lastConnectedAddress.value = _prefs.getString('lastConnectedAddress');
    autoConnect.value = _prefs.getBool('autoConnect') ?? true;
    
    startOnBoot.value = _prefs.getBool('startOnBoot') ?? false;
    trackpadSensitivity.value = _prefs.getDouble('trackpadSensitivity') ?? 1.0;
  }

  Future<void> setGlobalNotifications(bool value) async {
    globalNotifications.value = value;
    await _prefs.setBool('globalNotifications', value);
  }

  Future<void> setGlobalVibration(bool value) async {
    globalVibration.value = value;
    await _prefs.setBool('globalVibration', value);
  }

  Future<void> setNotifyFileTransfers(bool value) async {
    notifyFileTransfers.value = value;
    await _prefs.setBool('notifyFileTransfers', value);
  }

  Future<void> setNotifyConnections(bool value) async {
    notifyConnections.value = value;
    await _prefs.setBool('notifyConnections', value);
  }

  Future<void> setNotifyPowerCommands(bool value) async {
    notifyPowerCommands.value = value;
    await _prefs.setBool('notifyPowerCommands', value);
  }

  Future<void> setLastConnectedAddress(String? value) async {
    lastConnectedAddress.value = value;
    if (value == null) {
      await _prefs.remove('lastConnectedAddress');
    } else {
      await _prefs.setString('lastConnectedAddress', value);
    }
  }

  Future<void> setAutoConnect(bool value) async {
    autoConnect.value = value;
    await _prefs.setBool('autoConnect', value);
  }

  Future<void> setStartOnBoot(bool value) async {
    startOnBoot.value = value;
    await _prefs.setBool('startOnBoot', value);
  }

  Future<void> setTrackpadSensitivity(double value) async {
    trackpadSensitivity.value = value;
    await _prefs.setDouble('trackpadSensitivity', value);
  }

  Future<void> forgetDevice() async {
    await setLastConnectedAddress(null);
  }
}
