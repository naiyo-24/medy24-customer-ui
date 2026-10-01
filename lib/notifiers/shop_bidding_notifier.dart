import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/api_url.dart';

class ShopBiddingState {
  final bool isConnected;
  final String? error;
  final List<Map<String, dynamic>> activeBids;

  ShopBiddingState({
    this.isConnected = false,
    this.error,
    this.activeBids = const [],
  });

  ShopBiddingState copyWith({
    bool? isConnected,
    String? error,
    List<Map<String, dynamic>>? activeBids,
  }) {
    return ShopBiddingState(
      isConnected: isConnected ?? this.isConnected,
      error: error,
      activeBids: activeBids ?? this.activeBids,
    );
  }
}

class ShopBiddingNotifier extends StateNotifier<ShopBiddingState> {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  String? _currentShopId;

  ShopBiddingNotifier() : super(ShopBiddingState());

  void connect(String shopId) {
    if (_currentShopId == shopId && _channel != null) return;
    _currentShopId = shopId;
    _connect();
  }

  void _connect() {
    if (_currentShopId == null) return;
    
    disconnect();
    
    try {
      final url = ApiUrl.shopBiddingWebSocket(_currentShopId!);
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      state = state.copyWith(isConnected: true, error: null);

      _subscription = _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          // Assuming data contains bidding events
          final currentBids = List<Map<String, dynamic>>.from(state.activeBids);
          
          if (data['type'] == 'new_bid') {
            currentBids.insert(0, data['payload']);
          } else if (data['type'] == 'remove_bid') {
            currentBids.removeWhere((bid) => bid['order_id'] == data['payload']['order_id']);
          }
          
          state = state.copyWith(activeBids: currentBids);
        },
        onError: (error) {
          state = state.copyWith(isConnected: false, error: error.toString());
          _reconnect();
        },
        onDone: () {
          state = state.copyWith(isConnected: false);
          _reconnect();
        },
      );
    } catch (e) {
      state = state.copyWith(isConnected: false, error: e.toString());
      _reconnect();
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_currentShopId != null && !state.isConnected) {
        _connect();
      }
    });
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _subscription = null;
    state = state.copyWith(isConnected: false);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

final shopBiddingProvider = StateNotifierProvider<ShopBiddingNotifier, ShopBiddingState>((ref) {
  return ShopBiddingNotifier();
});
