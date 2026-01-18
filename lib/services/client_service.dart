import 'dart:async';
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
      final uri = Uri.parse('ws://$address');
      _channel = WebSocketChannel.connect(uri);
      
      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final message = BridgeMessage.fromJson(data as String);
            _messageController.add(message);
          } catch (e) {
            print('Error parsing message from server: $e');
          }
        },
        onDone: () {
          _connectionController.add(false);
          print('Disconnected from server');
        },
        onError: (error) {
          _connectionController.add(false);
          print('WebSocket error: $error');
        },
      );
      
      _connectionController.add(true);
      return true;
    } catch (e) {
      print('Connection error: $e');
      _connectionController.add(false);
      return false;
    }
  }

  void sendMessage(BridgeMessage message) {
    if (_channel != null) {
      _channel!.sink.add(message.toJson());
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _connectionController.add(false);
  }
}
