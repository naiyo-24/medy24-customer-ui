import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class RetailerLoginScreen extends ConsumerStatefulWidget {
  const RetailerLoginScreen({super.key});

  @override
  ConsumerState<RetailerLoginScreen> createState() => _RetailerLoginScreenState();
}

class _RetailerLoginScreenState extends ConsumerState<RetailerLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (_phoneController.text.length != 10 || _passwordController.text.isEmpty) return;

    FocusScope.of(context).unfocus();

    final success = await ref.read(authProvider.notifier).loginRetailer(
      '+91${_phoneController.text}',
      _passwordController.text,
    );

    if (success && mounted) {
      context.go('/retailer-live-orders');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(authProvider).error ?? 'Login Failed', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Pharmacy Login', style: AppTextStyles.cardTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.shop, size: 64, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Welcome Back', style: AppTextStyles.header),
                const SizedBox(height: 8),
                Text('Login to manage your pharmacy shop', style: AppTextStyles.description),
                const SizedBox(height: 32),
                
                // Phone Field
                Text('Mobile Number', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.mobile),
                    prefixText: '+91 ',
                    counterText: '',
                    hintText: 'Enter 10-digit number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Password Field
                Text('Password', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.lock),
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Iconsax.eye_slash : Iconsax.eye),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: authState.isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Login to Dashboard', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/retailer-signup'),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium,
                        children: const [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(text: "Register Shop", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
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
