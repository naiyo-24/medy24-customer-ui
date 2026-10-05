import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/manufacturer_models.dart';

class ManufacturerCartState {
  final Map<String, int> quantities; 
  
  ManufacturerCartState({this.quantities = const {}});

  ManufacturerCartState copyWith({Map<String, int>? quantities}) {
    return ManufacturerCartState(
      quantities: quantities ?? this.quantities,
    );
  }

  int get totalItems => quantities.values.fold(0, (sum, q) => sum + q);

  double calculateTotalValue(List<ManufacturerMedicineModel> availableCatalog) {
    double total = 0;
    quantities.forEach((id, qty) {
      try {
        final med = availableCatalog.firstWhere((m) => m.id == id);
        total += (med.ptr * qty);
      } catch (e) {
        // Item not in catalog, ignore
      }
    });
    return total;
  }
}

class ManufacturerCartNotifier extends Notifier<ManufacturerCartState> {
  @override
  ManufacturerCartState build() {
    return ManufacturerCartState();
  }

  void updateQuantity(ManufacturerMedicineModel med, int quantity) {
    final updatedQuantities = Map<String, int>.from(state.quantities);
    if (quantity <= 0) {
      updatedQuantities.remove(med.id);
    } else {
      updatedQuantities[med.id] = quantity < med.moq ? med.moq : quantity;
    }
    state = state.copyWith(quantities: updatedQuantities);
  }

  void clearCart() {
    state = ManufacturerCartState();
  }
}

final manufacturerCartProvider = NotifierProvider<ManufacturerCartNotifier, ManufacturerCartState>(() {
  return ManufacturerCartNotifier();
});
