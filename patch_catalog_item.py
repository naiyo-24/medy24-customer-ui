import re

with open("lib/screens/b2b/manufacturer/manufacturer_catalog_screen.dart", "r") as f:
    content = f.read()

new_widget_code = """
class CatalogItemCard extends StatefulWidget {
  final ManufacturerMedicineModel med;
  final int currentQty;
  final ManufacturerCartNotifier cartNotifier;

  const CatalogItemCard({
    Key? key,
    required this.med,
    required this.currentQty,
    required this.cartNotifier,
  }) : super(key: key);

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
"""

# Replace the _buildCatalogItem method with nothing, and add the new class at the bottom
content = re.sub(r"  Widget _buildCatalogItem\(.*?\}\n", "", content, flags=re.DOTALL)

# In the ListView.builder, change _buildCatalogItem(...) to CatalogItemCard(...)
content = content.replace("return _buildCatalogItem(med, currentQty, cartNotifier);", "return CatalogItemCard(med: med, currentQty: currentQty, cartNotifier: cartNotifier);")

content += "\n" + new_widget_code

with open("lib/screens/b2b/manufacturer/manufacturer_catalog_screen.dart", "w") as f:
    f.write(content)

print("Patched!")
