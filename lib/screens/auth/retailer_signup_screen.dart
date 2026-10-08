import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class RetailerSignupScreen extends ConsumerStatefulWidget {
  const RetailerSignupScreen({super.key});

  @override
  ConsumerState<RetailerSignupScreen> createState() => _RetailerSignupScreenState();
}

class _RetailerSignupScreenState extends ConsumerState<RetailerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _shopController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _licenseController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _gstinController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankIfscController = TextEditingController();
  final _bankNameController = TextEditingController();

  File? _drugLicenseFile;
  File? _panCardFile;
  File? _regCertFile;


  bool _obscurePassword = true;

  double? _latitude;
  double? _longitude;
  bool _isFetchingLocation = false;


  @override
  void dispose() {
    _shopController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _licenseController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _altPhoneController.dispose();
    _gstinController.dispose();
    _bankAccountController.dispose();
    _bankIfscController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fetch your location automatically first.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    FocusScope.of(context).unfocus();

    final success = await ref.read(authProvider.notifier).registerRetailer(
      phone: '+91${_phoneController.text.trim()}',
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      ownerName: _ownerController.text.trim(),
      shopName: _shopController.text.trim(),
      address: _addressController.text.trim(),
      latitude: _latitude ?? 0.0,
      longitude: _longitude ?? 0.0,
      licenseNumber: _licenseController.text.trim(),
      password: _passwordController.text,
      whatsappNumber: _whatsappController.text.trim().isNotEmpty ? '+91${_whatsappController.text.trim()}' : null,
      alternativePhone: _altPhoneController.text.trim().isNotEmpty ? '+91${_altPhoneController.text.trim()}' : null,
      gstinNo: _gstinController.text.trim().isNotEmpty ? _gstinController.text.trim() : null,
      bankAccountNo: _bankAccountController.text.trim().isNotEmpty ? _bankAccountController.text.trim() : null,
      bankIfscCode: _bankIfscController.text.trim().isNotEmpty ? _bankIfscController.text.trim() : null,
      bankName: _bankNameController.text.trim().isNotEmpty ? _bankNameController.text.trim() : null,
      drugLicenseFile: _drugLicenseFile,
      panCardFile: _panCardFile,
      regCertFile: _regCertFile,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! You can now upload documents from your dashboard or wait for approval.'), backgroundColor: Colors.green),
      );
      context.go('/retailer-login');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(authProvider).error ?? 'Registration failed', style: const TextStyle(color: Colors.white)),
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
        title: Text('Pharmacy Registration', style: AppTextStyles.cardTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Text('Shop Details', style: AppTextStyles.header),
              const SizedBox(height: 16),
              _buildTextField('Pharmacy Name', _shopController, Iconsax.shop, isRequired: true),
              const SizedBox(height: 12),
              _buildTextField('Owner Name', _ownerController, Iconsax.user, isRequired: true),
              const SizedBox(height: 12),
              _buildTextField('Phone Number', _phoneController, Iconsax.mobile, isPhone: true, isRequired: true),
              const SizedBox(height: 12),
              _buildTextField('Password', _passwordController, Iconsax.lock, isPassword: true, isRequired: true),
              const SizedBox(height: 12),
              _buildTextField('Email Address (Optional)', _emailController, Iconsax.sms),
              const SizedBox(height: 12),
              _buildTextField('WhatsApp Number (Optional)', _whatsappController, Iconsax.message, isPhone: true),
              const SizedBox(height: 12),
              _buildTextField('Alternative Phone (Optional)', _altPhoneController, Iconsax.call, isPhone: true),
              const SizedBox(height: 12),
              
              Text('Location Details', style: AppTextStyles.header),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isFetchingLocation ? null : _fetchLocation,
                  icon: _isFetchingLocation 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(_latitude != null ? Icons.check_circle : Icons.my_location, color: _latitude != null ? Colors.green : AppColors.primary),
                  label: Text(_latitude != null ? 'Location Captured' : 'Fetch Location Automatically'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: _latitude != null ? Colors.green : AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                ),
              ),
              if (_latitude == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text('Location is required for customers to find your pharmacy.', style: TextStyle(color: Colors.red.shade300, fontSize: 12)),
                ),
              const SizedBox(height: 12),
              
              _buildTextField('Complete Address', _addressController, Iconsax.location, isRequired: true, maxLines: 3),
              
              const SizedBox(height: 32),
              Text('License Information', style: AppTextStyles.header),
              const SizedBox(height: 16),
              _buildTextField('Drug License Number', _licenseController, Iconsax.document, isRequired: true),
              const SizedBox(height: 12),
              _buildTextField('GSTIN (Optional)', _gstinController, Iconsax.bank),
              
              const SizedBox(height: 32),
              Text('Bank Details', style: AppTextStyles.header),
              const SizedBox(height: 16),
              _buildTextField('Bank Name (Optional)', _bankNameController, Iconsax.bank),
              const SizedBox(height: 12),
              _buildTextField('Account Number (Optional)', _bankAccountController, Iconsax.card),
              const SizedBox(height: 12),
              _buildTextField('IFSC Code (Optional)', _bankIfscController, Iconsax.code),

              const SizedBox(height: 32),
              Text('Document Uploads', style: AppTextStyles.header),
              const SizedBox(height: 16),
              _buildFilePicker('Drug License Image', _drugLicenseFile, 'drug'),
              const SizedBox(height: 12),
              _buildFilePicker('PAN Card Image', _panCardFile, 'pan'),
              const SizedBox(height: 12),
              _buildFilePicker('Registration Certificate Image', _regCertFile, 'reg'),
              
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: authState.isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Register Pharmacy', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      } 

      Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location fetched successfully!'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching location: $e'), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _pickFile(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (type == 'drug') _drugLicenseFile = File(pickedFile.path);
        if (type == 'pan') _panCardFile = File(pickedFile.path);
        if (type == 'reg') _regCertFile = File(pickedFile.path);
      });
    }
  }

  Widget _buildFilePicker(String label, File? file, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickFile(type),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(file != null ? Iconsax.document_1 : Iconsax.document_upload, color: file != null ? Colors.green : AppColors.textTertiary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    file != null ? file.path.split('/').last : 'Upload Image',
                    style: TextStyle(color: file != null ? AppColors.textPrimary : AppColors.textTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    IconData icon, {
    bool isRequired = false, 
    bool isPhone = false,
    bool isPassword = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          maxLength: isPhone ? 10 : null,
          obscureText: isPassword && _obscurePassword,
          maxLines: isPassword ? 1 : maxLines,
          validator: isRequired ? (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            if (isPhone && value.length != 10) return 'Enter 10 digit number';
            return null;
          } : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            prefixText: isPhone ? '+91 ' : null,
            counterText: '',
            suffixIcon: isPassword ? IconButton(
              icon: Icon(_obscurePassword ? Iconsax.eye_slash : Iconsax.eye),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
