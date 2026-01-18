import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:network_info_plus/network_info_plus.dart';
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

        // Immediate handshake
        try {
          webSocket.sink.add(BridgeMessage(
            type: MessageType.auth,
            data: {'status': 'connected', 'version': '1.0.0'},
          ).toJson());
        } catch (e) {
          debugPrint('Error sending handshake: $e');
        }

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
          },
          cancelOnError: true,
        );
      });

      // Try to serve on 8080, or let the OS pick a port if 8080 is busy
      try {
        _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
      } catch (e) {
        debugPrint('Port 8080 busy, trying random port...');
        _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
      }
      
      final port = _server!.port;
      
      // Use NetworkInfo for more reliable IP discovery on most platforms
      final info = NetworkInfo();
      String? ip = await info.getWifiIP();
      
      if (ip == null || ip == '127.0.0.1' || ip.isEmpty) {
        // Fallback to manual interface scanning
        final interfaces = await NetworkInterface.list();
        for (var interface in interfaces) {
          if (interface.name.toLowerCase().contains('virtual') || 
              interface.name.toLowerCase().contains('vbox') ||
              interface.name.toLowerCase().contains('vmnet') ||
              interface.name.toLowerCase().contains('wsl')) continue;
              
          for (var addr in interface.addresses) {
            if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
              ip = addr.address;
              if (ip.startsWith('192.168.') || ip.startsWith('10.')) break;
            }
          }
          if (ip != null && (ip.startsWith('192.168.') || ip.startsWith('10.'))) break;
        }
      }
      
      final finalIp = ip ?? '127.0.0.1';
      final fullAddress = '$finalIp:$port';
      debugPrint('Server started at $fullAddress');
      return fullAddress;
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

      debugPrint('Desktop received: ${message.type}');
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
