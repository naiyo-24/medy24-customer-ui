import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/charges_notifier.dart';
import '../services/charges_services.dart';

final chargesServiceProvider = Provider((ref) => ChargesService());

final chargesProvider =
    StateNotifierProvider<ChargesNotifier, ChargesState>((ref) {
  final service = ref.watch(chargesServiceProvider);
  return ChargesNotifier(service);
});
