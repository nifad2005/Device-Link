import 'dart:convert';

enum MessageType {
  auth,
  mouseMove,
  mouseClick,
  mediaCommand,
  powerCommand,
  keyboardInput,
  statusUpdate
}

class BridgeMessage {
  final MessageType type;
  final Map<String, dynamic> data;
  final String? timestamp;

  BridgeMessage({
    required this.type,
    required this.data,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'data': data,
      'timestamp': timestamp ?? DateTime.now().toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory BridgeMessage.fromJson(String source) {
    final map = json.decode(source) as Map<String, dynamic>;
    return BridgeMessage(
      type: MessageType.values.firstWhere((e) => e.name == map['type']),
      data: map['data'] as Map<String, dynamic>,
      timestamp: map['timestamp'] as String?,
    );
  }
}
