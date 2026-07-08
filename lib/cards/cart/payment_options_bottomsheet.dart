import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../theme/app_theme.dart';

class PaymentMethodOption {
  final String title;
  final String? subtitle;
  final Widget icon;
  final String actionType; // 'arrow' or 'add'
  final bool isDisabled;
  final String? disabledMessage;
  final String backendMethod; // 'online' or 'cod'

  PaymentMethodOption({
    required this.title,
    this.subtitle,
    required this.icon,
    this.actionType = 'arrow',
    this.isDisabled = false,
    this.disabledMessage,
    this.backendMethod = 'online',
  });
}

class PaymentOptionsBottomSheet extends StatelessWidget {
  final double totalAmount;
  final String currentSelectedMethod;
  final String currentSelectedUI;

  const PaymentOptionsBottomSheet({
    super.key,
    required this.totalAmount,
    required this.currentSelectedMethod,
    required this.currentSelectedUI,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: AppColors.divider.withAlpha(128))),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                Text(
                  'Bill total: ₹${totalAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
          
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Recommended', [
                    PaymentMethodOption(
                      title: 'Google Pay UPI',
                      icon: _buildBrandIcon(Colors.blue, 'G'),
                    ),
                    PaymentMethodOption(
                      title: 'Paytm UPI',
                      icon: _buildBrandIcon(Colors.lightBlue, 'P'),
                    ),
                    PaymentMethodOption(
                      title: 'PhonePe UPI',
                      icon: _buildBrandIcon(Colors.deepPurple, 'Pe'),
                    ),
                  ], context),
                  
                  _buildSection('Cards', [
                    PaymentMethodOption(
                      title: 'Add credit or debit cards',
                      icon: const Icon(Iconsax.card, color: Colors.grey),
                      actionType: 'add',
                    ),
                    PaymentMethodOption(
                      title: 'Pluxee',
                      icon: _buildBrandIcon(Colors.grey, 'px'),
                      isDisabled: true,
                      disabledMessage: 'This payment method is not applicable on orders containing non-food items',
                    ),
                  ], context),

                  _buildSection('Pay by any UPI app', [
                    PaymentMethodOption(
                      title: 'Amazon Pay UPI',
                      icon: _buildBrandIcon(Colors.orange, 'A'),
                    ),
                  ], context),

                  _buildSection('Wallets', [
                    PaymentMethodOption(
                      title: 'Medy24 Wallet',
                      subtitle: 'Balance: ₹0',
                      icon: const Icon(Iconsax.wallet_2, color: AppColors.primary),
                      actionType: 'arrow',
                    ),
                    PaymentMethodOption(
                      title: 'Amazon Pay Balance',
                      subtitle: 'Link your Amazon Pay Balance wallet',
                      icon: _buildBrandIcon(Colors.orange, 'A'),
                      actionType: 'add',
                    ),
                  ], context),

                  _buildSection('Netbanking', [
                    PaymentMethodOption(
                      title: 'Netbanking',
                      icon: const Icon(Iconsax.bank, color: Colors.grey),
                      actionType: 'add',
                    ),
                  ], context),

                  _buildSection('Pay On Delivery', [
                    PaymentMethodOption(
                      title: 'Cash on Delivery',
                      icon: const Icon(Iconsax.money_2, color: Colors.grey),
                      backendMethod: 'cod',
                    ),
                  ], context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandIcon(Color color, String text) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withAlpha(50)),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildSection(String title, List<PaymentMethodOption> options, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider.withAlpha(128)),
            ),
            child: Column(
              children: options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isLast = index == options.length - 1;

                return Column(
                  children: [
                    InkWell(
                      onTap: option.isDisabled
                          ? null
                          : () {
                              Navigator.pop(context, {
                                'method': option.backendMethod,
                                'uiName': option.title,
                              });
                            },
                      borderRadius: BorderRadius.vertical(
                        top: index == 0 ? const Radius.circular(16) : Radius.zero,
                        bottom: isLast ? const Radius.circular(16) : Radius.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.divider.withAlpha(128)),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              alignment: Alignment.center,
                              child: option.icon,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.title,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: option.isDisabled ? AppColors.textTertiary : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (option.subtitle != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      option.subtitle!,
                                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            if (option.actionType == 'add')
                              Text(
                                'ADD',
                                style: TextStyle(
                                  color: option.isDisabled ? AppColors.textTertiary : Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              )
                            else
                              Icon(
                                Icons.chevron_right,
                                color: option.isDisabled ? AppColors.textTertiary : AppColors.textSecondary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (option.isDisabled && option.disabledMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(15),
                          border: const Border(
                            top: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        child: Text(
                          option.disabledMessage!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.error),
                        ),
                      ),
                    if (!isLast)
                      Divider(height: 1, color: AppColors.divider.withAlpha(128), indent: 72),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
