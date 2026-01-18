import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/models/bridge_message.dart';

class ServerService {
  HttpServer? _server;
  final List<WebSocketChannel> _clients = [];
  
  final ValueNotifier<int> connectedClients = ValueNotifier(0);

  Future<String?> startServer() async {
    try {
      final handler = webSocketHandler((WebSocketChannel webSocket) {
        _clients.add(webSocket);
        connectedClients.value = _clients.length;
        print('New client connected');

        webSocket.stream.listen(
          (message) {
            _handleMessage(message, webSocket);
          },
          onDone: () {
            _clients.remove(webSocket);
            connectedClients.value = _clients.length;
            print('Client disconnected');
          },
        );
      });

      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
      
      final interfaces = await NetworkInterface.list();
      String? ip;
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            ip = addr.address;
            break;
          }
        }
      }
      
      return ip != null ? '$ip:8080' : null;
    } catch (e) {
      return null;
    }
  }

  void _handleMessage(dynamic rawMessage, WebSocketChannel source) {
    try {
      final message = BridgeMessage.fromJson(rawMessage as String);
      // Logic to handle commands like mouse move, volume, etc.
      // In a real implementation, we would use something like 'robotjs' (for Node) 
      // or Win32 APIs (for Flutter/Windows) to control the PC.
      debugPrint('Desktop received command: ${message.type} with data: ${message.data}');
    } catch (e) {
      debugPrint('Error parsing message: $e');
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
