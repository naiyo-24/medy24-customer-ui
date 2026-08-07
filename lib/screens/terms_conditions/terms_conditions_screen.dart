import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Terms & Conditions',
        subtitle: 'LEGAL AGREEMENT',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Text(
            '''Terms and Conditions

Effective Date: August 5, 2026

Welcome to Medy24. These Terms and Conditions ("Terms") govern your access to and use of the Medy24 mobile application, website, and related services provided by Medy24 Private Limited ("Medy24", "we", "our", or "us").

By accessing or using Medy24, you agree to be bound by these Terms. If you do not agree, please do not use our services.

1. Eligibility

You must be at least 18 years of age or use the application under the supervision of a parent or legal guardian.
By registering an account, you confirm that the information you provide is accurate and complete.

2. Account Registration

To use certain features of Medy24, you must create an account using your mobile number.

You agree to:
• Provide accurate information.
• Keep your account information updated.
• Maintain the confidentiality of your account.
• Be responsible for all activities performed using your account.

Medy24 reserves the right to suspend or terminate accounts that contain false or misleading information.

3. OTP Authentication

Your mobile number is verified using a One-Time Password (OTP).
You are responsible for keeping your mobile number secure.
Do not share OTPs with anyone. Medy24 will never ask for your OTP by phone, email, or message.

4. Medicine Orders

Orders placed through Medy24 are subject to:
• Product availability.
• Pharmacy acceptance.
• Prescription verification (where applicable).
• Successful payment or Cash on Delivery availability.

Submitting an order does not guarantee acceptance. Orders may be cancelled if medicines are unavailable or legal requirements are not met.

5. Prescription Medicines

Certain medicines require a valid prescription.

By uploading a prescription, you confirm that:
• The prescription is genuine.
• It has been issued by a registered medical practitioner.
• The information provided is accurate.

Medy24 reserves the right to reject orders with invalid, incomplete, or expired prescriptions.

6. Pricing and Payments

Prices displayed in the application may change without prior notice.

Payments can be made using supported payment methods, including:
• UPI
• Debit/Credit Cards
• Net Banking
• Digital Wallets
• Cash on Delivery (where available)

All payments are processed securely through trusted payment partners.

7. Delivery

Delivery times are estimates and may vary due to:
• Traffic conditions
• Weather
• Pharmacy processing time
• Product availability
• Other unforeseen circumstances

Medy24 is not liable for delays caused by circumstances beyond our reasonable control.

8. Cancellation and Refunds

Orders may be cancelled before they are dispatched.
Prescription medicines and certain healthcare products may not be eligible for cancellation or return due to legal and safety regulations.
Approved refunds will be processed to the original payment method within the applicable processing period.

9. User Responsibilities

You agree not to:
• Use the application for unlawful purposes.
• Upload false or fraudulent prescriptions.
• Impersonate another person.
• Interfere with the operation or security of the application.
• Attempt unauthorized access to Medy24 systems.

Violation of these Terms may result in suspension or permanent termination of your account.

10. Intellectual Property

All content available on Medy24, including but not limited to:
• Logos
• Graphics
• Icons
• Images
• Text
• Software
• Designs
• Trademarks

is the property of Medy24 Private Limited and is protected under applicable intellectual property laws.
You may not copy, reproduce, modify, or distribute any content without prior written permission.

11. Privacy

Your use of Medy24 is also governed by our Privacy Policy, which explains how we collect, use, and protect your personal information.

12. Disclaimer

Medy24 acts as a technology platform connecting users with licensed pharmacies and healthcare service providers.
The information provided through the application is for general informational purposes only and should not be considered medical advice.
Always consult a qualified healthcare professional before taking any medication or making medical decisions.

13. Limitation of Liability

To the fullest extent permitted by law, Medy24 shall not be liable for:
• Indirect or consequential damages.
• Loss of profits or business.
• Delays in delivery.
• Errors caused by third-party service providers.
• Misuse of medicines purchased through the platform.

Our maximum liability shall not exceed the amount paid by you for the affected order.

14. Third-Party Services

Medy24 may integrate with third-party services such as:
• Payment gateways
• Google Maps
• Firebase
• SMS and OTP providers
• Delivery partners

These services operate under their own terms and privacy policies.

15. Suspension and Termination

Medy24 reserves the right to suspend or terminate your account without prior notice if:
• You violate these Terms.
• Fraudulent activity is detected.
• Required by law.
• Your actions threaten the security or integrity of the platform.

16. Changes to These Terms

We may revise these Terms and Conditions from time to time.
Updated versions will be posted within the application and on our website.
Your continued use of Medy24 after any changes constitutes your acceptance of the revised Terms.

17. Governing Law

These Terms shall be governed by and interpreted in accordance with the laws of India.
Any disputes arising from these Terms shall be subject to the exclusive jurisdiction of the courts located in Kolkata, West Bengal, India.

18. Contact Us

If you have any questions regarding these Terms and Conditions, please contact us:

Medy24 Private Limited

Email: services.naiyo@gmail.com
Phone: +91 62891 71798
Address:
1/30B, Chittaranjan Colony,
Baghajatin, Kolkata – 700032,
West Bengal, India

Business Hours:
Monday – Saturday
10:00 AM – 7:00 PM

© 2026 Medy24 Private Limited. All Rights Reserved.
''',
            style: AppTextStyles.description,
          ),
        ),
      ),
    );
  }
}
