import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../models/manufacturer_models.dart';
import '../../../providers/manufacturer_provider.dart';
import '../../../notifiers/manufacturer_cart_notifier.dart';
import 'manufacturer_checkout_screen.dart';

class ManufacturerCatalogScreen extends ConsumerStatefulWidget {
  final ManufacturerModel manufacturer;
  
  const ManufacturerCatalogScreen({super.key, required this.manufacturer});

  @override
  ConsumerState<ManufacturerCatalogScreen> createState() => _ManufacturerCatalogScreenState();
}

class _ManufacturerCatalogScreenState extends ConsumerState<ManufacturerCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalogRequest = CatalogRequest(
      manufacturerId: widget.manufacturer.id,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
    );
    final catalogAsyncValue = ref.watch(manufacturerCatalogProvider(catalogRequest));
    final cartState = ref.watch(manufacturerCartProvider);
    final cartNotifier = ref.read(manufacturerCartProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.manufacturer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show terms/details
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: const Icon(Iconsax.search_normal),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: catalogAsyncValue.when(
              data: (catalog) {
                if (catalog.isEmpty) return const Center(child: Text('No medicines found.'));
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  itemCount: catalog.length,
                  itemBuilder: (context, index) {
                    final med = catalog[index];
                    final currentQty = cartState.quantities[med.id] ?? 0;
                    return CatalogItemCard(med: med, currentQty: currentQty, cartNotifier: cartNotifier);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: cartState.totalItems > 0 
          ? _buildBottomCheckoutBar(cartState, catalogAsyncValue.value ?? []) 
          : null,
    );
  }


  Widget _buildBottomCheckoutBar(ManufacturerCartState cartState, List<ManufacturerMedicineModel> catalog) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${cartState.totalItems} boxes selected', style: AppTextStyles.caption),
                Text('Total: ₹${cartState.calculateTotalValue(catalog).toStringAsFixed(2)}', style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary)),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManufacturerCheckoutScreen(
                      manufacturer: widget.manufacturer,
                      catalog: catalog, // NOTE: this might only contain searched items, but the cart handles it based on IDs correctly usually.
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Review Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}


class CatalogItemCard extends StatefulWidget {
  final ManufacturerMedicineModel med;
  final int currentQty;
  final ManufacturerCartNotifier cartNotifier;

  const CatalogItemCard({
    super.key,
    required this.med,
    required this.currentQty,
    required this.cartNotifier,
  });

  @override
  State<CatalogItemCard> createState() => _CatalogItemCardState();
}

class _CatalogItemCardState extends State<CatalogItemCard> {
  late TextEditingController _qtyController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: widget.currentQty.toString());
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _commitQuantity();
      }
    });
  }

  @override
  void didUpdateWidget(CatalogItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentQty != widget.currentQty && !_focusNode.hasFocus) {
      _qtyController.text = widget.currentQty.toString();
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commitQuantity() {
    int? newQty = int.tryParse(_qtyController.text);
    if (newQty == null || newQty < widget.med.moq) {
      if (newQty != null && newQty == 0) {
        widget.cartNotifier.updateQuantity(widget.med, 0);
      } else if (widget.currentQty == 0) {
        _qtyController.text = '0';
      } else {
        _qtyController.text = widget.currentQty.toString();
      }
      return;
    }
    widget.cartNotifier.updateQuantity(widget.med, newQty);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.med.name, style: AppTextStyles.cardTitle),
            const SizedBox(height: 4),
            Text('Pack Size: ${widget.med.packSize}', style: AppTextStyles.caption),
            Text('Batch: ${widget.med.batchNumber}', style: AppTextStyles.caption),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PTR: ₹${widget.med.ptr.toStringAsFixed(2)}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text('MRP: ₹${widget.med.mrp.toStringAsFixed(2)}', style: AppTextStyles.caption.copyWith(decoration: TextDecoration.lineThrough)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    'MOQ: ${widget.med.moq} boxes', 
                    style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            widget.currentQty == 0 
              ? SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => widget.cartNotifier.updateQuantity(widget.med, widget.med.moq),
                    child: Text('Add ${widget.med.moq} Boxes (MOQ)'),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                      onPressed: () {
                        int current = widget.currentQty;
                        if (current <= widget.med.moq) {
                          widget.cartNotifier.updateQuantity(widget.med, 0);
                        } else {
                          widget.cartNotifier.updateQuantity(widget.med, current - 100);
                        }
                      },
                    ),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _qtyController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.header.copyWith(fontSize: 18),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _commitQuantity(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      onPressed: () => widget.cartNotifier.updateQuantity(widget.med, widget.currentQty + 100),
                    ),
                  ],
                )
          ],
        ),
      ),
    );
  }
}
