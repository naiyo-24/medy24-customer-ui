import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_bar.dart';
import '../../../services/auth_services.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/shop_profile_provider.dart';
import '../../../services/api_url.dart';

class RetailerDocumentsScreen extends ConsumerStatefulWidget {
  const RetailerDocumentsScreen({super.key});

  @override
  ConsumerState<RetailerDocumentsScreen> createState() => _RetailerDocumentsScreenState();
}

class _RetailerDocumentsScreenState extends ConsumerState<RetailerDocumentsScreen> {
  final ImagePicker _picker = ImagePicker();
  
  File? _drugLicenseFile;
  File? _panCardFile;
  File? _regCertFile;
  
  bool _isLoading = false;

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (type == 'drug') {
          _drugLicenseFile = File(image.path);
        } else if (type == 'pan') {
          _panCardFile = File(image.path);
        } else if (type == 'reg') {
          _regCertFile = File(image.path);
        }
      });
    }
  }

  Future<void> _uploadDocuments() async {
    if (_drugLicenseFile == null && _panCardFile == null && _regCertFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No new documents selected to upload.'))
      );
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).user;
      if (user?.customerId == null) throw Exception("User not logged in");

      await AuthService().uploadShopDocuments(
        shopId: user!.customerId!, 
        drugLicense: _drugLicenseFile,
        panCard: _panCardFile,
        registrationCert: _regCertFile,
      );

      ref.invalidate(shopProfileProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documents uploaded successfully!'), backgroundColor: AppColors.success)
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDocSection(String title, String? existingUrl, File? newFile, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => _pickImage(type),
              child: const Text('Change'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (newFile != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(newFile, height: 150, width: double.infinity, fit: BoxFit.cover),
          )
        else if (existingUrl != null && existingUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              existingUrl.startsWith('http') ? existingUrl : '${ApiUrl.baseUrl}$existingUrl',
              height: 150, 
              width: double.infinity, 
              fit: BoxFit.cover,
              errorBuilder: (c,e,s) => Container(
                height: 150, 
                color: Colors.grey[200], 
                child: const Center(child: Text('Error loading image'))
              )
            ),
          )
        else
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Center(
              child: Text('No document uploaded', style: TextStyle(color: Colors.red)),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopProfileAsync = ref.watch(shopProfileProvider);

    return PopScope(
      canPop: !_isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please wait while we save your documents...')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Document Uploads',
        showBackButton: true,
      ),
      body: shopProfileAsync.when(
        data: (shopData) {
          if (shopData == null) return const Center(child: Text('Shop data not available'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDocSection('Drug License', shopData['drugLicenseUpload'], _drugLicenseFile, 'drug'),
                const SizedBox(height: 24),
                _buildDocSection('PAN Card', shopData['panCardUpload'], _panCardFile, 'pan'),
                const SizedBox(height: 24),
                _buildDocSection('Registration Certificate', shopData['registrationCertificateUpload'], _regCertFile, 'reg'),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _uploadDocuments,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isLoading ? const CircularProgressIndicator() : const Text('Upload Changes', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
