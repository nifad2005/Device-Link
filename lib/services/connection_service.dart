import 'dart:async';
import 'package:flutter/foundation.dart';
import 'platform_service.dart';
import 'server_service.dart';
import 'client_service.dart';
import '../core/models/bridge_message.dart';

enum ConnectionStatus { idle, searching, connecting, connected, error }

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  final ServerService _serverService = ServerService();
  final ClientService _clientService = ClientService();

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
    }
  }

  Future<bool> connectToDevice(String address) async {
    status.value = ConnectionStatus.connecting;
    final success = await _clientService.connect(address);
    if (success) {
      status.value = ConnectionStatus.connected;
      return true;
    } else {
      status.value = ConnectionStatus.error;
      return false;
    }
  }

  void sendMessage(BridgeMessage message) {
    if (!isDesktop) {
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
}
