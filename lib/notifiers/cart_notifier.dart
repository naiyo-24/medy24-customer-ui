import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/cart.dart';
import '../models/medicine.dart';
import '../models/charges.dart';
import '../providers/cart_provider.dart';
import '../providers/profile_provider.dart';

class CartState {
  final List<CartItem> items;
  final dynamic selectedAddress;
  final bool isLoading;
  final String? error;

  CartState({
    this.items = const [],
    this.selectedAddress,
    this.isLoading = false,
    this.error,
  });

  CartState copyWith({
    List<CartItem>? items,
    dynamic selectedAddress,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  CartSummary getSummary(ChargesModel? charges) {
    double itemAmount = 0.0;
    double discount = 0.0;

    for (var item in items) {
      double mrp = item.medicine.mrp ?? 0.0;
      double finalPrice = item.medicine.finalPrice ?? mrp;

      itemAmount += mrp * item.quantity;
      discount += (mrp - finalPrice) * item.quantity;
    }

    double platformCharges = items.isEmpty
        ? 0.0
        : (charges?.platformCommission ?? 30.0);
    double deliveryFees = items.isEmpty ? 0.0 : (charges?.baseFare ?? 40.0);
    double subTotal = itemAmount - discount;
    double taxPercent = charges?.gstPercentage ?? 5.0;
    double taxes = subTotal * (taxPercent / 100);

    double totalToPay = items.isEmpty
        ? 0.0
        : subTotal + platformCharges + deliveryFees + taxes;

    return CartSummary(
      totalItemAmount: itemAmount,
      totalDiscount: discount,
      platformCharges: platformCharges,
      deliveryFees: deliveryFees,
      taxes: taxes,
      totalAmountToBePaid: totalToPay,
      totalSaved: discount,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final Ref ref;

  CartNotifier(this.ref) : super(CartState()) {
    Future.microtask(() => fetchCart());
  }

  String? get _customerId => ref.read(profileProvider).user?.customerId;

  void _updateStateFromResponse(Response response) {
    if (response.statusCode == 200 && response.data['cart'] != null) {
      final List items = response.data['cart']['items'] ?? [];
      final parsedItems = items.map((i) => CartItem.fromJson(i)).toList();
      state = state.copyWith(items: parsedItems, isLoading: false, error: null);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchCart() async {
    final cid = _customerId;
    if (cid == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ref.read(cartServiceProvider).getCart(cid);
      _updateStateFromResponse(response);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addItem(MedicineModel medicine, {int quantity = 1}) async {
    final cid = _customerId;
    if (cid == null) return;

    final existingIndex = state.items.indexWhere(
      (item) => item.medicine.medicineId == medicine.medicineId,
    );

    int newQuantity = quantity;
    if (existingIndex >= 0) {
      newQuantity = state.items[existingIndex].quantity + quantity;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ref.read(cartServiceProvider).addItem(cid, medicine.medicineId!, newQuantity);
      _updateStateFromResponse(response);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateQuantity(String medicineId, int newQuantity) async {
    final cid = _customerId;
    if (cid == null) return;

    if (newQuantity <= 0) {
      return removeItem(medicineId);
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ref.read(cartServiceProvider).updateItem(cid, medicineId, newQuantity);
      _updateStateFromResponse(response);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> removeItem(String medicineId) async {
    final cid = _customerId;
    if (cid == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ref.read(cartServiceProvider).removeItem(cid, medicineId);
      _updateStateFromResponse(response);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectAddress(dynamic address) {
    state = state.copyWith(selectedAddress: address);
  }

  Future<void> clearCart() async {
    final cid = _customerId;
    if (cid == null) {
      clearCartLocal();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ref.read(cartServiceProvider).clearCart(cid);
      _updateStateFromResponse(response);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearCartLocal() {
    state = CartState(selectedAddress: state.selectedAddress);
  }
}
