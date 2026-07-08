import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';

class CartTipCard extends ConsumerStatefulWidget {
  const CartTipCard({super.key});

  @override
  ConsumerState<CartTipCard> createState() => _CartTipCardState();
}

class _CartTipCardState extends ConsumerState<CartTipCard> {
  final TextEditingController _customTipController = TextEditingController();
  bool _isCustomTipMode = false;

  final List<Map<String, dynamic>> tipOptions = [
    {'amount': 20.0, 'emoji': '🤩'},
    {'amount': 30.0, 'emoji': '🤩'},
    {'amount': 50.0, 'emoji': '😍'},
  ];

  @override
  void dispose() {
    _customTipController.dispose();
    super.dispose();
  }

  void _updateTip(double amount) {
    ref.read(cartProvider.notifier).setDeliveryTip(amount);
  }

  @override
  Widget build(BuildContext context) {
    final selectedTip = ref.watch(cartProvider).deliveryTip;

    return Container(
      decoration: AppCardStyles.sleekCard,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tip your delivery partner', style: AppTextStyles.cardTitle),
                    const SizedBox(height: 4),
                    Text(
                      'Your kindness means a lot! 100% of your tip will go directly to your delivery partner.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Simplified illustration representation (like screenshot)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.motorcycle, color: AppColors.primary, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isCustomTipMode)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...tipOptions.map((option) {
                    final amount = option['amount'] as double;
                    final isSelected = selectedTip == amount;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () {
                          // Toggle off if already selected
                          if (isSelected) {
                            _updateTip(0.0);
                          } else {
                            _updateTip(amount);
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withAlpha(25) : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.divider,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(option['emoji'] as String),
                              const SizedBox(width: 4),
                              Text(
                                '₹${amount.toInt()}',
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isCustomTipMode = true;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Text('👏'),
                          SizedBox(width: 4),
                          Text('Custom'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('👏 Custom', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 16),
                  const Text('₹', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _customTipController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter amount',
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) {
                        final amount = double.tryParse(val);
                        if (amount != null) {
                          _updateTip(amount);
                        } else {
                          _updateTip(0.0);
                        }
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isCustomTipMode = false;
                        _customTipController.clear();
                      });
                      if (!tipOptions.any((o) => o['amount'] == selectedTip)) {
                        _updateTip(0.0);
                      }
                    },
                    child: const Text('Close', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
