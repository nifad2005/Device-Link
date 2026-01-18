import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/models/bridge_message.dart';
import 'file_transfer_service.dart';

class ServerService {
  HttpServer? _server;
  final List<WebSocketChannel> _clients = [];
  
  final ValueNotifier<int> connectedClients = ValueNotifier(0);
  final FileTransferService _fileTransferService = FileTransferService();

  Future<String?> startServer() async {
    try {
      final handler = webSocketHandler((WebSocketChannel webSocket) {
        _clients.add(webSocket);
        connectedClients.value = _clients.length;
        debugPrint('Desktop: [WS] New connection attempt...');

        // Shake hands immediately
        try {
          webSocket.sink.add(BridgeMessage(
            type: MessageType.auth,
            data: {'status': 'connected'},
          ).toJson());
          debugPrint('Desktop: [WS] Auth message sent.');
        } catch (e) {
          debugPrint('Desktop: [WS] Failed to send auth: $e');
        }

        webSocket.stream.listen(
          (message) {
            _handleMessage(message, webSocket);
          },
          onDone: () {
            _clients.remove(webSocket);
            connectedClients.value = _clients.length;
            debugPrint('Desktop: [WS] Client disconnected.');
          },
          onError: (e) {
            _clients.remove(webSocket);
            connectedClients.value = _clients.length;
            debugPrint('Desktop: [WS] Stream error: $e');
          },
        );
      });

      // Bind to all interfaces (0.0.0.0) on port 8080
      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
      debugPrint('Desktop: [Server] Listening on 0.0.0.0:8080');

      // Find the correct local network IP
      String? localIp;
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      // 1. Look for common Wi-Fi/Ethernet patterns
      for (var interface in interfaces) {
        final name = interface.name.toLowerCase();
        // Skip virtual/bridge adapters
        if (name.contains('virtual') || name.contains('vbox') || 
            name.contains('vmnet') || name.contains('wsl') || 
            name.contains('docker') || name.contains('vpn')) continue;

        for (var addr in interface.addresses) {
          final ip = addr.address;
          if (ip.startsWith('192.168.') || ip.startsWith('10.') || ip.startsWith('172.16.')) {
            localIp = ip;
            debugPrint('Desktop: [Network] Found preferred IP: $localIp on interface ${interface.name}');
            break;
          }
        }
        if (localIp != null) break;
      }

      // 2. Fallback to any non-loopback IP
      if (localIp == null && interfaces.isNotEmpty) {
        localIp = interfaces.first.addresses.first.address;
        debugPrint('Desktop: [Network] Fallback IP: $localIp');
      }

      final address = '${localIp ?? '127.0.0.1'}:8080';
      return address;
    } catch (e) {
      debugPrint('Desktop: [Fatal] Server failed to start: $e');
      return null;
    }
  }

  void _handleMessage(dynamic rawMessage, WebSocketChannel source) {
    try {
      final message = BridgeMessage.fromJson(rawMessage as String);
      if (message.type.name.startsWith('fileTransfer')) {
        _fileTransferService.handleIncomingMessage(message);
        return;
      }
      debugPrint('Desktop: [Received] ${message.type}');
    } catch (e) {
      debugPrint('Desktop: [Error] Parsing message: $e');
    }
  }

  void broadcastMessage(BridgeMessage message) {
    final jsonMsg = message.toJson();
    for (var client in _clients) {
      try {
        client.sink.add(jsonMsg);
      } catch (e) {
        debugPrint('Desktop: [Error] Broadcast failed: $e');
      }
    }
  }

  Future<void> stopServer() async {
    await _server?.close(force: true);
    for (var client in _clients) {
      client.sink.close();
    }
    _clients.clear();
    connectedClients.value = 0;
  }
}
