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
        debugPrint('New client connected. Total: ${_clients.length}');

        webSocket.sink.add(BridgeMessage(
          type: MessageType.auth,
          data: {'status': 'connected', 'version': '1.0.0'},
        ).toJson());

        webSocket.stream.listen(
          (message) {
            _handleMessage(message, webSocket);
          },
          onDone: () {
            _clients.remove(webSocket);
            connectedClients.value = _clients.length;
            debugPrint('Client disconnected. Remaining: ${_clients.length}');
          },
          onError: (e) {
            _clients.remove(webSocket);
            connectedClients.value = _clients.length;
            debugPrint('Client error: $e');
          }
        );
      });

      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
      
      // Try to find the most likely local IP
      final interfaces = await NetworkInterface.list();
      String? bestIp;
      
      for (var interface in interfaces) {
        // Skip virtual interfaces often used by Docker/VMs
        if (interface.name.toLowerCase().contains('virtual') || 
            interface.name.toLowerCase().contains('vbox') ||
            interface.name.toLowerCase().contains('vmnet')) continue;
            
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            bestIp = addr.address;
            // If we find one that starts with 192 or 10, it's likely the right one
            if (bestIp.startsWith('192.168.') || bestIp.startsWith('10.')) {
              break;
            }
          }
        }
        if (bestIp != null && (bestIp.startsWith('192.168.') || bestIp.startsWith('10.'))) break;
      }
      
      final finalIp = bestIp ?? '127.0.0.1';
      debugPrint('Server started at $finalIp:8080');
      return '$finalIp:8080';
    } catch (e) {
      debugPrint('Failed to start server: $e');
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

      // Relay mouse/media commands to listeners or execute locally
      debugPrint('Desktop received: ${message.type}');
      
      // OPTIONAL: Relay message to all OTHER clients
      // final jsonMsg = message.toJson();
      // for (var client in _clients) {
      //   if (client != source) client.sink.add(jsonMsg);
      // }
      
    } catch (e) {
      debugPrint('Error parsing message: $e');
    }
  }

  void broadcastMessage(BridgeMessage message) {
    final jsonMsg = message.toJson();
    for (var client in _clients) {
      try {
        client.sink.add(jsonMsg);
      } catch (e) {
        debugPrint('Error broadcasting: $e');
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
