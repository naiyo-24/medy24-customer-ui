import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_url.dart';

class OrderService {
  WebSocketChannel? _channel;
  String? _lastCustomerId;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  bool get isConnected => _channel != null;

  void connect(String customerId) {
    _lastCustomerId = customerId;
    _connectInternal();
  }

  void _connectInternal() {
    if (_lastCustomerId == null) return;
    disconnect();

    final url = ApiUrl.orderWebSocket(_lastCustomerId!);
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        (data) {
          try {
            final decoded = json.decode(data as String) as Map<String, dynamic>;
            _messageController.add(decoded);
          } catch (e) {
            if (kDebugMode) {
              print("WebSocket parse error: $e");
            }
          }
        },
        onDone: () {
          if (kDebugMode) {
            print("WebSocket disconnected");
          }
          _channel = null;
          // Optionally, broadcast an error so UI knows we disconnected
          _messageController.add({
            "type": "error",
            "message": "Connection lost",
          });
        },
        onError: (error) {
          if (kDebugMode) {
            print("WebSocket error: $error");
          }
          _channel = null;
          _messageController.add({
            "type": "error",
            "message": "Connection error",
          });
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("Failed to initiate WebSocket connection: $e");
      }
      _channel = null;
      _messageController.add({"type": "error", "message": "Connection failed"});
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel == null && _lastCustomerId != null) {
      // Try to reconnect if dropped
      _connectInternal();
    }

    if (_channel != null) {
      _channel!.sink.add(json.encode(message));
    } else {
      if (kDebugMode) {
        print("WebSocket not connected. Cannot send message.");
      }
      throw Exception("Cannot connect to server.");
    }
  }

  void approveQuote(String orderId, String quoteId, String paymentMode) {
    sendMessage({
      "type": "approve_quote",
      "order_id": orderId,
      "quote_id": quoteId,
      "payment_mode": paymentMode,
    });
  }

  void rejectQuote(String orderId, String quoteId) {
    sendMessage({
      "type": "reject_quote",
      "order_id": orderId,
      "quote_id": quoteId,
    });
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
