import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/order_provider.dart';
import '../../cards/medicine_orders/order_card.dart';
import '../../theme/app_theme.dart';
// import 'order_details_screen.dart'; // Create later if needed

class MyOrderScreen extends ConsumerStatefulWidget {
  const MyOrderScreen({super.key});

  @override
  ConsumerState<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends ConsumerState<MyOrderScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(orderProvider.notifier).fetchOrders(refresh: true));
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(orderProvider.notifier).fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Medicine Orders'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: orderState.isLoading && orderState.orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : orderState.error != null && orderState.orders.isEmpty
              ? Center(child: Text(orderState.error!, style: const TextStyle(color: AppColors.error)))
              : orderState.orders.isEmpty
                  ? const Center(child: Text('No orders found.'))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(orderProvider.notifier).fetchOrders(refresh: true),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: orderState.orders.length + (orderState.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == orderState.orders.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final order = orderState.orders[index];
                          return OrderCard(
                            order: order,
                            onTap: () {
                              // Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailsScreen(orderId: order.orderId!)));
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}
