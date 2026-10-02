import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../providers/auth_provider.dart';
import '../services/api_url.dart';

final distributorOrdersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.user?.token == null || authState.user?.role != 'distributor') return [];

  try {
    final dio = Dio();
    final response = await dio.get(
      '${ApiUrl.baseUrl}/api/v1/distributor/orders',
      options: Options(
        headers: {'Authorization': 'Bearer ${authState.user?.token}'},
      ),
    );
    return response.data as List<dynamic>;
  } catch (e) {
    throw Exception('Failed to load orders: $e');
  }
});

class DistributorOrderService {
  final String token;
  DistributorOrderService(this.token);

  Future<void> updateOrderStatus(String poId, String newStatus) async {
    final dio = Dio();
    await dio.put(
      '${ApiUrl.baseUrl}/api/v1/distributor/orders/$poId/status',
      data: {'new_status': newStatus},
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }
}

final distributorOrderServiceProvider = Provider<DistributorOrderService?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState.user?.token == null) return null;
  return DistributorOrderService(authState.user!.token!);
});
