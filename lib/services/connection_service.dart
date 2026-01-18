import 'dart:async';
import 'package:flutter/foundation.dart';
import 'platform_service.dart';
import 'server_service.dart';
import 'client_service.dart';
import 'file_transfer_service.dart';
import 'settings_service.dart';
import '../core/models/bridge_message.dart';

enum ConnectionStatus { idle, searching, connecting, connected, error }

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  final ServerService _serverService = ServerService();
  final ClientService _clientService = ClientService();
  final FileTransferService _fileTransferService = FileTransferService();
  final SettingsService _settings = SettingsService();

  final ValueNotifier<ConnectionStatus> status = ValueNotifier(ConnectionStatus.idle);
  final ValueNotifier<String?> serverAddress = ValueNotifier(null);
  
  ValueListenable<int> get connectedClientsCount => _serverService.connectedClients;

  bool get isDesktop => PlatformService.isDesktop;

  Future<void> init() async {
    if (isDesktop) {
      final ip = await _serverService.startServer();
      if (ip != null) {
        serverAddress.value = ip;
        status.value = ConnectionStatus.idle;
      } else {
        status.value = ConnectionStatus.error;
      }
    } else {
      // Mobile: listen for messages from the client
      _clientService.messages.listen((message) {
        _handleIncomingMessage(message);
      });
      
      _clientService.connectionStatus.listen((isConnected) {
        status.value = isConnected ? ConnectionStatus.connected : ConnectionStatus.idle;
      });

      // Attempt Auto-connect if enabled
      if (_settings.autoConnect.value && _settings.lastConnectedAddress.value != null) {
        debugPrint('ConnectionService: Attempting auto-connect to ${_settings.lastConnectedAddress.value}');
        connectToDevice(_settings.lastConnectedAddress.value!);
      }
    }
  }

  void _handleIncomingMessage(BridgeMessage message) {
    if (message.type.name.startsWith('fileTransfer')) {
      _fileTransferService.handleIncomingMessage(message);
    } else {
      debugPrint('Mobile received message: ${message.type}');
    }
  }

  Future<bool> connectToDevice(String address) async {
    status.value = ConnectionStatus.connecting;
    final success = await _clientService.connect(address);
    if (success) {
      status.value = ConnectionStatus.connected;
      // Save for auto-connect
      await _settings.setLastConnectedAddress(address);
      return true;
    } else {
      status.value = ConnectionStatus.error;
      return false;
    }
  }

  void sendMessage(BridgeMessage message) {
    if (isDesktop) {
      _serverService.broadcastMessage(message);
    } else {
      _clientService.sendMessage(message);
    }
  }

  void disconnect() {
    if (isDesktop) {
      _serverService.stopServer();
    } else {
      _clientService.disconnect();
    }
    status.value = ConnectionStatus.idle;
  }

  Future<void> forgetAndDisconnect() async {
    disconnect();
    await _settings.forgetDevice();
  }
}
