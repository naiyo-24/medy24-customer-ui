import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_url.dart';
import 'package:url_launcher/url_launcher.dart';

final distributorProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user?.token == null) throw Exception('No auth token');
  
  final dio = Dio();
  final response = await dio.get(
    '${ApiUrl.baseUrl}/api/v1/distributor/profile',
    options: Options(headers: {'Authorization': 'Bearer ${user!.token}'}),
  );
  
  if (response.statusCode == 200) {
    return response.data;
  } else {
    throw Exception('Failed to load profile');
  }
});

class DistributorProfileScreen extends ConsumerWidget {
  const DistributorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(distributorProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: AppTextStyles.cardTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        data: (profile) {
          final isVerified = profile['is_verified'] == true;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          (profile['company_name'] ?? 'D').toString().substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 40, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            profile['company_name'] ?? 'Company Name',
                            style: AppTextStyles.header.copyWith(fontSize: 24),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.verified, color: AppColors.success, size: 24),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isVerified ? AppColors.success.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          (profile['status'] ?? 'Pending').toString().toUpperCase(),
                          style: TextStyle(
                            color: isVerified ? AppColors.success : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildSectionTitle('Contact Details'),
                _buildInfoCard([
                  _buildInfoRow(Icons.person, 'Owner Name', profile['owner_name'] ?? 'N/A'),
                  _buildInfoRow(Icons.phone, 'Phone Number', profile['phone'] ?? 'N/A'),
                  _buildInfoRow(Icons.email, 'Email Address', profile['email'] ?? 'N/A'),
                  _buildInfoRow(Icons.location_on, 'Address', profile['address'] ?? 'N/A'),
                ]),
                
                const SizedBox(height: 24),
                _buildSectionTitle('Business & Tax Details'),
                _buildInfoCard([
                  _buildInfoRow(Icons.assignment, 'GSTIN', profile['gstin_no'] ?? 'N/A'),
                  _buildInfoRow(Icons.credit_card, 'PAN Number', profile['pan_number'] ?? 'N/A'),
                ]),

                const SizedBox(height: 24),
                _buildSectionTitle('Licenses & Documents'),
                _buildInfoCard([
                  _buildDocumentRow(context, Icons.description, 'Drug License 20B', profile['wholesale_drug_license_20b']),
                  _buildDocumentRow(context, Icons.description, 'Drug License 21B', profile['wholesale_drug_license_21b']),
                ]),

                const SizedBox(height: 24),
                _buildSectionTitle('Banking Details'),
                _buildInfoCard([
                  _buildInfoRow(Icons.account_balance, 'Account Number', profile['bank_account_no'] ?? 'Not added'),
                  _buildInfoRow(Icons.account_balance_wallet, 'IFSC Code', profile['bank_ifsc_code'] ?? 'Not added'),
                ]),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(BuildContext context, IconData icon, String label, String? url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          if (url != null && url.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                final fullUrl = url.startsWith('http') 
                    ? url 
                    : url.startsWith('/') 
                        ? '${ApiUrl.baseUrl}$url' 
                        : '${ApiUrl.baseUrl}/$url';
                
                final isImage = fullUrl.toLowerCase().endsWith('.jpg') || 
                               fullUrl.toLowerCase().endsWith('.jpeg') || 
                               fullUrl.toLowerCase().endsWith('.png');

                if (isImage) {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          InteractiveViewer(
                            child: Image.network(
                              fullUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text('Failed to load image'),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black54),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  );
                  return;
                }

                final uri = Uri.parse(fullUrl);
                try {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open document')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error opening document: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.remove_red_eye, size: 16),
              label: const Text('View'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            )
          else
            const Text('Missing', style: TextStyle(fontSize: 12, color: Colors.red)),
        ],
      ),
    );
  }
}
