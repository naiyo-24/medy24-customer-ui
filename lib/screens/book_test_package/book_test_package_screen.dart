import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/test_package_booking.dart';
import '../../notifiers/book_test_package_notifier.dart';
import '../../notifiers/charges_notifier.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_test_package_provider.dart';
import '../../providers/charges_provider.dart';
import '../../providers/lab_test_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

class BookTestPackageScreen extends ConsumerStatefulWidget {
  final String bookingType;
  final String itemId;

  const BookTestPackageScreen({
    super.key,
    required this.bookingType,
    required this.itemId,
  });

  @override
  ConsumerState<BookTestPackageScreen> createState() =>
      _BookTestPackageScreenState();
}

class _BookTestPackageScreenState extends ConsumerState<BookTestPackageScreen> {
  static const _genders = ['Male', 'Female', 'Other'];
  static const _relations = [
    'Self',
    'Spouse',
    'Parent',
    'Child',
    'Sibling',
    'Friend',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(_initializeBooking);
  }

  Future<void> _initializeBooking() async {
    await Future.wait([
      ref.read(profileProvider.notifier).fetchProfile(),
      ref.read(chargesProvider.notifier).fetchChargeByServiceType(
            ChargesNotifier.labBookingServiceType,
          ),
    ]);
    if (!mounted) return;

    final profileUser = ref.read(profileProvider).user;
    final authUser = ref.read(authProvider).user;
    final user = profileUser ?? authUser;
    final addresses = user?.savedAddresses;
    final charges = ref.read(chargesProvider).selectedCharge;

    final notifier = ref.read(bookTestPackageProvider.notifier);
    final labTestState = ref.read(labTestProvider);
    if (widget.bookingType == 'package') {
      await notifier.initPackageBooking(
        packageId: widget.itemId,
        package: labTestState.selectedPackage,
        user: user,
        savedAddresses: addresses,
        charges: charges,
      );
    } else {
      await notifier.initLabTestBooking(
        testId: widget.itemId,
        test: labTestState.selectedTest,
        user: user,
        savedAddresses: addresses,
        charges: charges,
      );
    }
  }

  Future<void> _onPayNow() async {
    final user = ref.read(profileProvider).user ?? ref.read(authProvider).user;
    final addresses = user?.savedAddresses;
    final booking = await ref.read(bookTestPackageProvider.notifier).submitBooking(
      customerId: user?.customerId,
      savedAddresses: addresses,
    );

    if (!mounted) return;

    final error = ref.read(bookTestPackageProvider).error;
    if (booking == null) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
      return;
    }

    context.push('/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookTestPackageProvider);

    final chargesState = ref.watch(chargesProvider);

    if (bookingState.isLoading || chargesState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!bookingState.hasItem) {
      return Scaffold(
        appBar: const CustomAppBar(
          showBackButton: true,
          title: 'Book Test',
          subtitle: 'Complete your booking',
        ),
        body: Center(
          child: Text(bookingState.error ?? 'Unable to load booking details'),
        ),
      );
    }

    final isLabTest = bookingState.itemType == BookingItemType.labTest;
    final savedAddresses =
        ref.watch(profileProvider).user?.savedAddresses ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        showBackButton: true,
        title: isLabTest ? 'Book Lab Test' : 'Book Package',
        subtitle: bookingState.itemName ?? 'Complete your booking',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemSummary(bookingState),
            const SizedBox(height: 24),
            _buildToggleBar(bookingState),
            const SizedBox(height: 24),
            _buildSectionTitle('Patient Details'),
            const SizedBox(height: 16),
            _buildPatientForm(bookingState),
            const SizedBox(height: 28),
            _buildSectionTitle('Sample Collection Address'),
            const SizedBox(height: 16),
            if (savedAddresses.isNotEmpty) ...[
              _buildSavedAddresses(savedAddresses, bookingState),
              const SizedBox(height: 16),
            ],
            _buildAddressFields(bookingState),
            const SizedBox(height: 28),
            _buildSectionTitle('Order Summary'),
            const SizedBox(height: 16),
            _buildPriceSummary(bookingState.priceSummary!),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildPayBar(bookingState),
    );
  }

  Widget _buildItemSummary(BookTestPackageState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.itemName ?? '',
            style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
          ),
          if (state.itemSubtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              state.itemSubtitle!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleBar(BookTestPackageState state) {
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
              isActive: state.isBookingForSelf,
              onTap: () => _onToggleSelf(true),
            ),
          ),
          Expanded(
            child: _buildToggleItem(
              title: 'Someone else',
              isActive: !state.isBookingForSelf,
              onTap: () => _onToggleSelf(false),
            ),
          ),
        ],
      ),
    );
  }

  void _onToggleSelf(bool forSelf) {
    final user = ref.read(profileProvider).user ?? ref.read(authProvider).user;
    ref.read(bookTestPackageProvider.notifier).setBookingForSelf(forSelf, user: user);
  }

  Widget _buildToggleItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
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

  Widget _buildPatientForm(BookTestPackageState state) {
    final readOnly = state.isBookingForSelf;
    return Column(
      key: ValueKey(
        'patient-${state.isBookingForSelf}-${state.fullName}-${state.phoneNumber}-${state.gender}-${state.ageText}-${state.relation}',
      ),
      children: [
        _buildTextField(
          label: 'Full Name',
          icon: Iconsax.user,
          value: state.fullName,
          readOnly: readOnly,
          onChanged: ref.read(bookTestPackageProvider.notifier).updateFullName,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Phone No',
          icon: Iconsax.mobile,
          value: state.phoneNumber,
          readOnly: readOnly,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged:
              ref.read(bookTestPackageProvider.notifier).updatePhoneNumber,
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          label: 'Gender',
          icon: Iconsax.user_tag,
          value: state.gender.isEmpty ? null : state.gender,
          items: _genders,
          onChanged: ref.read(bookTestPackageProvider.notifier).updateGender,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Age',
                icon: Iconsax.calendar,
                value: state.ageText,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: ref.read(bookTestPackageProvider.notifier).updateAge,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                label: 'Relation',
                icon: Iconsax.people,
                value: state.relation.isEmpty ? null : state.relation,
                items: state.isBookingForSelf ? ['Self'] : _relations.where((r) => r != 'Self').toList(),
                onChanged: state.isBookingForSelf
                    ? (_) {}
                    : ref.read(bookTestPackageProvider.notifier).updateRelation,
                enabled: !state.isBookingForSelf,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSavedAddresses(
    List<dynamic> addresses,
    BookTestPackageState state,
  ) {
    return Column(
      children: List.generate(addresses.length, (index) {
        final address = addresses[index] as Map<String, dynamic>;
        final isSelected = state.selectedAddressIndex == index;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => ref
                .read(bookTestPackageProvider.notifier)
                .selectSavedAddress(index, address),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.divider.withAlpha(80),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Iconsax.tick_circle
                        : Iconsax.location,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address['address_1']?.toString() ?? 'Address',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          address['street_address']?.toString() ?? '',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAddressFields(BookTestPackageState state) {
    return Column(
      key: ValueKey(
        'address-${state.selectedAddressIndex}-${state.addressLine1}-${state.streetAddress}',
      ),
      children: [
        _buildTextField(
          label: 'Address line (House / Flat / Building)',
          icon: Iconsax.home,
          value: state.addressLine1,
          onChanged: ref.read(bookTestPackageProvider.notifier).updateAddressLine1,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Street / Area / Landmark',
          icon: Iconsax.location,
          value: state.streetAddress,
          maxLines: 2,
          onChanged:
              ref.read(bookTestPackageProvider.notifier).updateStreetAddress,
        ),
      ],
    );
  }

  Widget _buildPriceSummary(BookingPriceSummary summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        children: [
          _summaryRow('Subtotal', summary.subtotal),
          if (summary.discount > 0) ...[
            const SizedBox(height: 10),
            _summaryRow('Discount', summary.discount, isDiscount: true),
          ],
          const SizedBox(height: 10),
          _summaryRow('Platform commission', summary.platformFee),
          const SizedBox(height: 10),
          _summaryRow(
            'Tax charges (${ref.watch(chargesProvider).selectedCharge?.gstPercentage.toStringAsFixed(0) ?? '0'}%)',
            summary.taxCharges,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _summaryRow(
            'Total amount to pay',
            summary.totalAmount,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    double amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              fontSize: isTotal ? 14 : 13,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          isDiscount
              ? '- ₹${amount.toStringAsFixed(0)}'
              : '₹${amount.toStringAsFixed(0)}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: isTotal ? 18 : 14,
            color: isDiscount
                ? AppColors.error
                : isTotal
                    ? AppColors.primaryAccent
                    : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPayBar(BookTestPackageState state) {
    final total = state.priceSummary?.totalAmount ?? 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: state.isSubmitting ? null : _onPayNow,
            child: state.isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Pay Now · ₹${total.toStringAsFixed(0)}'),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 16));
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String value,
    required ValueChanged<String> onChanged,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: value,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textTertiary),
        filled: readOnly,
        fillColor: readOnly ? AppColors.background : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textTertiary),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: enabled
          ? (selected) {
              if (selected != null) onChanged(selected);
            }
          : null,
    );
  }
}
