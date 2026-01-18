import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/models/bridge_message.dart';

class ClientService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  
  final _messageController = StreamController<BridgeMessage>.broadcast();
  Stream<BridgeMessage> get messages => _messageController.stream;

  final _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionController.stream;

  Future<bool> connect(String address) async {
    try {
      // Clear old connection if any
      await _subscription?.cancel();
      await _channel?.sink.close();

      final uri = Uri.parse('ws://$address');
      debugPrint('Connecting to $uri...');
      
      _channel = WebSocketChannel.connect(uri);
      
      // Wait for the connection to be established
      try {
        await _channel!.ready.timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Connection timeout or failed: $e');
        _connectionController.add(false);
        return false;
      }

      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final message = BridgeMessage.fromJson(data as String);
            _messageController.add(message);
          } catch (e) {
            debugPrint('Error parsing message from server: $e');
          }
        },
        onDone: () {
          _connectionController.add(false);
          debugPrint('Disconnected from server (Stream closed)');
        },
        onError: (error) {
          _connectionController.add(false);
          debugPrint('WebSocket stream error: $error');
        },
        cancelOnError: true,
      );
      
      _connectionController.add(true);
      debugPrint('Connected successfully to $address');
      return true;
    } catch (e) {
      debugPrint('Fatal connection error: $e');
      _connectionController.add(false);
      return false;
    }
  }

  void sendMessage(BridgeMessage message) {
    if (_channel != null) {
      try {
        _channel!.sink.add(message.toJson());
      } catch (e) {
        debugPrint('Error sending message: $e');
      }
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _connectionController.add(false);
  }
}
