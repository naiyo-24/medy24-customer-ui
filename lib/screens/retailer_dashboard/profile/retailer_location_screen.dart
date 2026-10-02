import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_bar.dart';
import '../../../services/auth_services.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/shop_profile_provider.dart';

class RetailerLocationScreen extends ConsumerStatefulWidget {
  const RetailerLocationScreen({super.key});

  @override
  ConsumerState<RetailerLocationScreen> createState() => _RetailerLocationScreenState();
}

class _RetailerLocationScreenState extends ConsumerState<RetailerLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressCtrl;
  late TextEditingController _gstinCtrl;
  bool _isLoading = false;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _addressCtrl = TextEditingController();
    _gstinCtrl = TextEditingController();

      }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _gstinCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateLocation() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).user;
      if (user?.customerId == null) throw Exception("User not logged in");

      await AuthService().updateShopProfile(
        user!.customerId!, 
        {
          "address": _addressCtrl.text,
          "gstin_no": _gstinCtrl.text,
        }
      );

      // Refresh the provider
      ref.invalidate(shopProfileProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details updated successfully!'), backgroundColor: AppColors.success)
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

  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(shopProfileProvider);
    shopAsync.whenData((shopData) {
      if (!_isInitialized && shopData != null) {
        _addressCtrl.text = shopData['address'] ?? '';
        _gstinCtrl.text = shopData['gstinNo'] ?? '';
        _isInitialized = true;
      }
    });

    return PopScope(
      canPop: !_isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please wait while we save your details...')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Pharmacy Location & Details',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Full Address', hintText: 'Enter your pharmacy address'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gstinCtrl,
                decoration: const InputDecoration(labelText: 'GSTIN', hintText: 'Enter GSTIN (Optional)'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateLocation,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Save Details', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
