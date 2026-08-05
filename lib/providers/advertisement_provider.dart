import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/advertisement.dart';
import '../services/api_url.dart';

final advertisementProvider = FutureProvider<List<AdvertisementModel>>((ref) async {
  final dio = Dio();
  try {
    final response = await dio.get(ApiUrl.advertisements);
    final data = response.data as List<dynamic>;
    return data.map((json) => AdvertisementModel.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Failed to load advertisements: $e');
  }
});
