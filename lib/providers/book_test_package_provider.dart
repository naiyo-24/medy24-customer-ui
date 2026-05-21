import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/book_test_package_notifier.dart';
import '../services/book_test_package_services.dart';
import '../services/lab_test_services.dart';

final bookTestPackageServiceProvider =
    Provider((ref) => BookTestPackageService());

final bookTestPackageProvider =
    StateNotifierProvider<BookTestPackageNotifier, BookTestPackageState>((ref) {
  final bookingService = ref.watch(bookTestPackageServiceProvider);
  final labTestService = LabTestService();
  return BookTestPackageNotifier(bookingService, labTestService);
});
