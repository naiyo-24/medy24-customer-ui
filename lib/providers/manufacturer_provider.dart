import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/manufacturer_service.dart';
import '../models/manufacturer_models.dart';

final _dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final manufacturerServiceProvider = Provider<ManufacturerService>((ref) {
  final dio = ref.watch(_dioProvider);
  return ManufacturerService(dio);
});

final manufacturersProvider = FutureProvider<List<ManufacturerModel>>((ref) async {
  final service = ref.watch(manufacturerServiceProvider);
  return service.fetchManufacturers();
});

final manufacturerCatalogProvider = FutureProvider.family<List<ManufacturerMedicineModel>, String>((ref, manufacturerId) async {
  final service = ref.watch(manufacturerServiceProvider);
  return service.fetchManufacturerCatalog(manufacturerId);
});
