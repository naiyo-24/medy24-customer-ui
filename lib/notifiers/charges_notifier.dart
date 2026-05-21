import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/charges.dart';
import '../services/charges_services.dart';

class ChargesState {
  final List<ChargesModel> charges;
  final ChargesModel? selectedCharge;
  final bool isLoading;
  final String? error;

  const ChargesState({
    this.charges = const [],
    this.selectedCharge,
    this.isLoading = false,
    this.error,
  });

  ChargesState copyWith({
    List<ChargesModel>? charges,
    ChargesModel? selectedCharge,
    bool? isLoading,
    String? error,
    bool clearSelectedCharge = false,
  }) {
    return ChargesState(
      charges: charges ?? this.charges,
      selectedCharge: clearSelectedCharge
          ? null
          : (selectedCharge ?? this.selectedCharge),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChargesNotifier extends StateNotifier<ChargesState> {
  static const String labBookingServiceType = 'car_xl';

  final ChargesService _service;

  ChargesNotifier(this._service) : super(const ChargesState());

  Future<ChargesModel?> fetchChargeByServiceType(
    String serviceType, {
    bool? isPeakTime,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final charges = await _service.fetchPlatformFees();
      final charge = _resolveCharge(
        charges,
        serviceType: serviceType,
        isPeakTime: isPeakTime,
      );

      if (charge == null) {
        state = state.copyWith(
          charges: charges,
          isLoading: false,
          error: 'No charges found for $serviceType',
          clearSelectedCharge: true,
        );
        return null;
      }

      state = state.copyWith(
        charges: charges,
        selectedCharge: charge,
        isLoading: false,
      );
      return charge;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  ChargesModel? _resolveCharge(
    List<ChargesModel> charges, {
    required String serviceType,
    bool? isPeakTime,
  }) {
    final matches =
        charges.where((c) => c.serviceType == serviceType).toList();
    if (matches.isEmpty) return null;

    if (isPeakTime != null) {
      return matches.where((c) => c.isPeakTime == isPeakTime).firstOrNull ??
          matches.firstOrNull;
    }

    return matches.where((c) => !c.isPeakTime).firstOrNull ??
        matches.firstOrNull;
  }
}
