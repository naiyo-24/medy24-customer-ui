import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../providers/profile_provider.dart';
import '../../services/api_url.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _altPhoneController;
  File? _imageFile;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileProvider).user;
    _nameController = TextEditingController(text: user?.fullName);
    _phoneController = TextEditingController(text: user?.phoneNumber);
    _altPhoneController = TextEditingController(text: user?.alternativePhoneNo);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    final success = await ref.read(profileProvider.notifier).updateProfile(
          fullName: _nameController.text,
          alternativePhoneNo: _altPhoneController.text,
          profilePhoto: _imageFile,
        );

    setState(() => _isUpdating = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(profileProvider).error ?? 'Update failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(profileProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        showBackButton: true,
        title: 'Update Profile',
        subtitle: 'Keep your details up to date',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                        image: _imageFile != null
                            ? DecorationImage(
                                image: FileImage(_imageFile!),
                                fit: BoxFit.cover,
                              )
                            : (user?.profilePhoto != null
                                ? DecorationImage(
                                    image: NetworkImage(ApiUrl.imageUrl(user!.profilePhoto)),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                      ),
                      child: (_imageFile == null && user?.profilePhoto == null)
                          ? const Icon(Iconsax.user, size: 50, color: AppColors.primary)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Iconsax.camera, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Iconsax.user,
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter phone number',
                icon: Iconsax.call,
                enabled: false, // Phone number usually fixed
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _altPhoneController,
                label: 'Alternative Phone',
                hint: 'Enter alternative phone',
                icon: Iconsax.mobile,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : _handleUpdate,
                  child: _isUpdating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Update Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.tagline.copyWith(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            filled: !enabled,
            fillColor: enabled ? null : AppColors.divider.withAlpha(30),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
