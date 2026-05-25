import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../providers/order_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/charges_provider.dart';

class OrderWithPrescriptionScreen extends ConsumerStatefulWidget {
  const OrderWithPrescriptionScreen({super.key});

  @override
  ConsumerState<OrderWithPrescriptionScreen> createState() =>
      _OrderWithPrescriptionScreenState();
}

class _OrderWithPrescriptionScreenState
    extends ConsumerState<OrderWithPrescriptionScreen> {
  bool _isOrderingForMyself = true;
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _selectedSavedAddress;

  // Controllers for "Ordering for others"
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _altPhoneController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final List<XFile> pickedFiles = [];
    if (source == ImageSource.gallery) {
      final List<XFile> images = await _picker.pickMultiImage();
      pickedFiles.addAll(images);
    } else {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) pickedFiles.add(image);
    }

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _altPhoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(profileProvider).user;
      if (user != null) {
        _nameController.text = user.fullName ?? '';
        _phoneController.text = user.phoneNumber ?? '';
      }
      ref
          .read(chargesProvider.notifier)
          .fetchChargeByServiceType('medicine_delivery');
    });
  }

  bool _isProcessing = false;

  void _placePrescriptionOrder() async {
    if (_selectedImages.isEmpty) return;

    if (_isOrderingForMyself) {
      if (_selectedSavedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a delivery address')),
        );
        return;
      }
    } else {
      if (_addressController.text.isEmpty ||
          _nameController.text.isEmpty ||
          _phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all patient details')),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      final chargesState = ref.read(chargesProvider);
      final charges = chargesState.selectedCharge;
      final platformFee = charges?.platformCommission ?? 30.0;
      final deliveryFee = charges?.baseFare ?? 40.0;
      final taxes = 0.0; // Assume 0 taxes until items are added by pharmacy

      String receiverName = 'Myself';
      String receiverPhone = 'N/A';
      Map<String, dynamic> deliveryAddress = {};

      if (_isOrderingForMyself) {
        final user = ref.read(profileProvider).user;
        receiverName = user?.fullName ?? 'Myself';
        receiverPhone = user?.phoneNumber ?? 'N/A';
        final addressString = [
          _selectedSavedAddress?['address_1'],
          _selectedSavedAddress?['street_address'],
        ].where((e) => e != null).join(', ');
        deliveryAddress = {
          'address': addressString,
          'lat': _selectedSavedAddress?['lat'] ?? 0.0,
          'lng': _selectedSavedAddress?['lng'] ?? 0.0,
        };
      } else {
        receiverName = _nameController.text.isNotEmpty
            ? _nameController.text
            : 'Myself';
        receiverPhone = _phoneController.text.isNotEmpty
            ? _phoneController.text
            : 'N/A';
        deliveryAddress = {
          'address': _addressController.text,
          'lat': 0.0,
          'lng': 0.0,
        };
      }

      final order = await ref
          .read(orderProvider.notifier)
          .placeOrderFromPrescription(
            prescriptionFile:
                _selectedImages.first, // API currently takes single file
            receiverName: receiverName,
            receiverPhone: receiverPhone,
            deliveryAddress: deliveryAddress,
            platformFee: platformFee,
            deliveryFee: deliveryFee,
            taxes: taxes,
            paymentMode:
                'cod', // Defaulting to cod for prescription orders as total is unknown
          );

      setState(() => _isProcessing = false);

      if (order != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescription Order placed successfully!'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Upload Prescription',
        subtitle: 'Quick Medicine Order',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle Bar
            _buildToggleBar(),
            const SizedBox(height: 24),

            if (_isOrderingForMyself) ...[
              _buildSectionTitle('Select Delivery Address'),
              const SizedBox(height: 16),
              _buildSavedAddressesList(),
              const SizedBox(height: 32),
            ] else ...[
              _buildSectionTitle('Patient Details'),
              const SizedBox(height: 16),
              _buildTextField(_nameController, 'Full Name', Iconsax.user),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _ageController,
                      'Age',
                      Iconsax.calendar,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      _phoneController,
                      'Phone No',
                      Iconsax.mobile,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _addressController,
                'Full Address',
                Iconsax.location,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _altPhoneController,
                'Alt Phone No (Optional)',
                Iconsax.call,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
            ],

            _buildSectionTitle('Attach Prescription'),
            const SizedBox(height: 8),
            Text(
              'Please upload a clear image of your prescription',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            _buildImageUploadArea(),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedImages.isEmpty || _isProcessing
                    ? null
                    : _placePrescriptionOrder,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm Order'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withAlpha(100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleItem(
              title: 'Myself',
              isActive: _isOrderingForMyself,
              onTap: () => setState(() => _isOrderingForMyself = true),
            ),
          ),
          Expanded(
            child: _buildToggleItem(
              title: 'Others',
              isActive: !_isOrderingForMyself,
              onTap: () => setState(() => _isOrderingForMyself = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isActive ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 16));
  }

  Widget _buildSavedAddressesList() {
    final user = ref.read(profileProvider).user;
    final addresses = user?.savedAddresses ?? [];

    if (addresses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: AppCardStyles.sleekCard,
        child: const Text(
          'No saved addresses. Please add one in your profile.',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }

    return Column(
      children: addresses.map((address) {
        final isSelected = _selectedSavedAddress == address;
        return InkWell(
          onTap: () => setState(
            () => _selectedSavedAddress = address as Map<String, dynamic>?,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? AppColors.primary.withAlpha(25)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Iconsax.location_tick : Iconsax.location,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address['address_1'] ?? 'Address',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (address['street_address'] != null)
                        Text(
                          address['street_address'],
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textTertiary),
      ),
    );
  }

  Widget _buildImageUploadArea() {
    return Column(
      children: [
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImages[index],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildUploadButton(
                icon: Iconsax.camera,
                label: 'Camera',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildUploadButton(
                icon: Iconsax.image,
                label: 'Gallery',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withAlpha(150)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
