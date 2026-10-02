import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_bar.dart';
import '../../../services/auth_services.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/shop_profile_provider.dart';

class RetailerBankDetailsScreen extends ConsumerStatefulWidget {
  const RetailerBankDetailsScreen({super.key});

  @override
  ConsumerState<RetailerBankDetailsScreen> createState() => _RetailerBankDetailsScreenState();
}

class _RetailerBankDetailsScreenState extends ConsumerState<RetailerBankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bankNameCtrl;
  late TextEditingController _bankAccountCtrl;
  late TextEditingController _bankIfscCtrl;
  bool _isLoading = false;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _bankNameCtrl = TextEditingController();
    _bankAccountCtrl = TextEditingController();
    _bankIfscCtrl = TextEditingController();

      }

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _bankAccountCtrl.dispose();
    _bankIfscCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateBankDetails() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).user;
      if (user?.customerId == null) throw Exception("User not logged in");

      await AuthService().updateShopProfile(
        user!.customerId!, 
        {
          "bank_name": _bankNameCtrl.text,
          "bank_account_no": _bankAccountCtrl.text,
          "bank_ifsc_code": _bankIfscCtrl.text,
        }
      );

      ref.invalidate(shopProfileProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank Details updated successfully!'), backgroundColor: AppColors.success)
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
        _bankNameCtrl.text = shopData['bankName'] ?? '';
        _bankAccountCtrl.text = shopData['bankAccountNo'] ?? '';
        _bankIfscCtrl.text = shopData['bankIfscCode'] ?? '';
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
        title: 'Bank Details',
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
                controller: _bankNameCtrl,
                decoration: const InputDecoration(labelText: 'Bank Name', hintText: 'e.g. State Bank of India'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bankAccountCtrl,
                decoration: const InputDecoration(labelText: 'Account Number', hintText: 'Enter Account Number'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bankIfscCtrl,
                decoration: const InputDecoration(labelText: 'IFSC Code', hintText: 'Enter IFSC Code'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateBankDetails,
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
