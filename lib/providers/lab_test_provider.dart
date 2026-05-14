import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/lab_test_notifier.dart';
import '../services/lab_test_services.dart';

final labTestServiceProvider = Provider((ref) => LabTestService());

final labTestProvider = StateNotifierProvider<LabTestNotifier, LabTestState>((
  ref,
) {
  final service = ref.watch(labTestServiceProvider);
  return LabTestNotifier(service);
});
