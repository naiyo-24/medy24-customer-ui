import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/profile_provider.dart';

class AddSavedAddressBottomSheet extends ConsumerStatefulWidget {
  const AddSavedAddressBottomSheet({super.key});

  @override
  ConsumerState<AddSavedAddressBottomSheet> createState() => _AddSavedAddressBottomSheetState();
}

class _AddSavedAddressBottomSheetState extends ConsumerState<AddSavedAddressBottomSheet> {
  final _address1Controller = TextEditingController();
  final _streetController = TextEditingController();
  double? _lat;
  double? _lng;
  bool _isLoading = false;

  @override
  void dispose() {
    _address1Controller.dispose();
    _streetController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_address1Controller.text.isEmpty || _streetController.text.isEmpty || _lat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all details and select location on map')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(profileProvider.notifier).addAddress(
          address1: _address1Controller.text,
          streetAddress: _streetController.text,
          latitude: _lat!,
          longitude: _lng!,
        );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Add New Address',
                style: AppTextStyles.header.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 24),
              _buildInputLabel('Address Name (e.g. Home, Office)'),
              const SizedBox(height: 8),
              TextField(
                controller: _address1Controller,
                decoration: const InputDecoration(
                  hintText: 'Home',
                  prefixIcon: Icon(Iconsax.tag, size: 20),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputLabel('Street Address'),
              const SizedBox(height: 8),
              TextField(
                controller: _streetController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'House no, Apartment, Street name...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Iconsax.location, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await context.push<Map<String, double>>('/map-picker');
                  if (result != null) {
                    setState(() {
                      _lat = result['lat'];
                      _lng = result['lng'];
                    });
                  }
                },
                icon: const Icon(Iconsax.map_1),
                label: Text(_lat == null ? 'Pick location from map' : 'Location Selected'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: BorderSide(
                    color: _lat != null ? AppColors.success : AppColors.primary,
                  ),
                  foregroundColor: _lat != null ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Address'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.tagline.copyWith(fontSize: 12, color: AppColors.textSecondary),
    );
  }
}
