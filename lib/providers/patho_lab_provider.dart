import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/patho_lab_notifier.dart';
import '../services/patho_lab_services.dart';

final pathoLabServiceProvider = Provider((ref) => PathoLabService());

final pathoLabProvider = StateNotifierProvider<PathoLabNotifier, PathoLabState>(
  (ref) {
    final service = ref.watch(pathoLabServiceProvider);
    return PathoLabNotifier(service);
  },
);
