import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../services/api_url.dart';
import '../../notifiers/b2b_order_notifier.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import 'b2b_order_details_screen.dart'; // Add this import

class B2BOrderHistoryScreen extends ConsumerStatefulWidget {
  final String shopId;
  const B2BOrderHistoryScreen({super.key, required this.shopId});

  @override
  ConsumerState<B2BOrderHistoryScreen> createState() =>
      _B2BOrderHistoryScreenState();
}

class _B2BOrderHistoryScreenState extends ConsumerState<B2BOrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(b2bOrderProvider.notifier).fetchOrders(widget.shopId);
    });
  }

  Future<void> _downloadInvoice(String poId) async {
    final url = Uri.parse(
      '${ApiUrl.baseUrl}/api/v1/b2b/invoices/$poId/download',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
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
    final state = ref.watch(b2bOrderProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Wholesale Orders', style: AppTextStyles.cardTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : state.error != null
          ? EmptyStateWidget(
              title: 'Failed to load orders',
              icon: Iconsax.warning_2,
              subtitle: state.error,
            )
          : state.orders.isEmpty
          ? const EmptyStateWidget(
              title: 'No Orders',
              icon: Iconsax.box,
              subtitle: 'No wholesale orders placed yet.',
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => ref
                  .read(b2bOrderProvider.notifier)
                  .fetchOrders(widget.shopId),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  final parsedDate = DateTime.tryParse(order.createdAt);
                  final formattedDate = parsedDate != null
                      ? DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate)
                      : order.createdAt;

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => B2BOrderDetailsScreen(order: order),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                                color: _getStatusColor(
                                  order.poStatus,
                                ).withAlpha(30),
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
                              onPressed: () => _downloadInvoice(order.poId),
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
                  ));
                },
              ),
            ),
    );
  }
}
