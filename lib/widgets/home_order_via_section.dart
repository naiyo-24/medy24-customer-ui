import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../theme/app_theme.dart';

/// "OR YOU CAN ORDER VIA" row — WhatsApp, Prescription, Call
class HomeOrderViaSection extends StatelessWidget {
  final VoidCallback onWhatsAppTap;
  final VoidCallback onPrescriptionTap;
  final VoidCallback onCallTap;

  const HomeOrderViaSection({
    super.key,
    required this.onWhatsAppTap,
    required this.onPrescriptionTap,
    required this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with divider lines
          Row(
            children: [
              Expanded(child: Container(height: 1, color: AppColors.divider)),
              const SizedBox(width: 10),
              const Text(
                'OR YOU CAN ORDER VIA',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 1, color: AppColors.divider)),
            ],
          ),

          const SizedBox(height: 12),

          // Buttons row
          Row(
            children: [
              // WhatsApp
              Expanded(
                child: _OrderViaButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded,
                      size: 18, color: Color(0xFF25D366)),
                  label: 'WhatsApp',
                  onTap: onWhatsAppTap,
                ),
              ),
              const SizedBox(width: 10),
              // Prescription
              Expanded(
                child: _OrderViaButton(
                  icon: const Icon(Iconsax.document_upload,
                      size: 18, color: AppColors.primary),
                  label: 'Prescription',
                  onTap: onPrescriptionTap,
                ),
              ),
              const SizedBox(width: 10),
              // Call
              Expanded(
                child: _OrderViaButton(
                  icon: const Icon(Iconsax.call,
                      size: 18, color: AppColors.info),
                  label: 'Call Us',
                  onTap: onCallTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderViaButton extends StatefulWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _OrderViaButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_OrderViaButton> createState() => _OrderViaButtonState();
}

class _OrderViaButtonState extends State<_OrderViaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon,
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
