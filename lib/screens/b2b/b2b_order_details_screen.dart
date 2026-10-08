import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/b2b_order.dart';
import '../../theme/app_theme.dart';
import '../../services/api_url.dart';

class B2BOrderDetailsScreen extends StatelessWidget {
  final B2BOrderModel order;

  const B2BOrderDetailsScreen({super.key, required this.order});

  Future<void> _downloadInvoice(BuildContext context) async {
    final url = Uri.parse(
      '${ApiUrl.baseUrl}/api/v1/b2b/invoices/${order.poId}/download',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open invoice.',
              style: AppTextStyles.caption.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return AppColors.info;
      case 'accepted':
        return AppColors.primary;
      case 'dispatched':
        return Colors.indigo;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsedDate = DateTime.tryParse(order.createdAt);
    final formattedDate = parsedDate != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate)
        : order.createdAt;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Container(
              decoration: AppCardStyles.sleekCard,
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'PO: ${order.poId}',
                          style: AppTextStyles.cardTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.poStatus).withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.poStatus.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: _getStatusColor(order.poStatus),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Supplier: ${order.distributorName}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Placed on: $formattedDate',
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    'Payment: ${order.paymentTerms.toUpperCase()}',
                    style: AppTextStyles.caption,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: AppColors.divider),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Invoice',
                            style: AppTextStyles.caption,
                          ),
                          Text(
                            '₹${order.totalInvoiceAmount.toStringAsFixed(2)}',
                            style: AppTextStyles.cardTitle.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.primaryAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.borderRadius,
                            ),
                            side: const BorderSide(
                              color: AppColors.primaryAccent,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onPressed: () => _downloadInvoice(context),
                        icon: const Icon(
                          Iconsax.document_download,
                          size: 18,
                        ),
                        label: const Text('Invoice'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Items Section
            Text(
              'Order Items',
              style: AppTextStyles.subHeader,
            ),
            const SizedBox(height: 12),
            if (order.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No items found for this order.'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  final totalItemPrice = item.ptr * item.qtyBoxes;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: AppCardStyles.sleekCard,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.infoLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Iconsax.box, color: AppColors.info, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.medicineName?.isNotEmpty == true 
                                  ? item.medicineName! 
                                  : 'Medicine ID: ${item.medicineId}',
                                style: AppTextStyles.cardTitle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Batch: ${item.batchNumber}',
                                style: AppTextStyles.caption,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${item.qtyBoxes} boxes × ₹${item.ptr}',
                                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹${totalItemPrice.toStringAsFixed(2)}',
                                    style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
