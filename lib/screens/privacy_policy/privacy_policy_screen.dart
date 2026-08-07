import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Privacy Policy',
        subtitle: 'DATA PROTECTION',
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
            '''Privacy Policy

Effective Date: August 5, 2026

Welcome to Medy24. Your privacy is important to us. This Privacy Policy explains how Medy24 Private Limited ("Medy24", "we", "our", or "us") collects, uses, stores, shares, and protects your personal information when you use the Medy24 mobile application, website, and related healthcare services.

By accessing or using Medy24, you agree to the collection and use of your information in accordance with this Privacy Policy.

1. Information We Collect

To provide our services efficiently, we may collect the following information:

Personal Information
• Full Name
• Mobile Number
• Email Address (optional)
• Profile Photo (optional)
• Delivery Address
• Date of Birth (optional)

Healthcare Information
• Prescription images uploaded by you
• Medicine purchase history
• Order history
• Pharmacy preferences

Device Information
• Device Model
• Operating System
• Device Identifier
• IP Address
• App Version

Location Information
With your permission, we collect your location to:
• Deliver medicines accurately
• Locate nearby pharmacies
• Improve delivery services

2. How We Collect Information

We collect information when you:
• Register an account.
• Verify your mobile number using OTP.
• Upload prescriptions.
• Place medicine orders.
• Contact customer support.
• Update your profile.
• Use our mobile application or website.

Some information is collected automatically through analytics and device information.

3. How We Use Your Information

We use your information to:
• Create and manage your account.
• Verify your identity through OTP.
• Deliver medicines and healthcare products.
• Process payments securely.
• Track your orders.
• Provide customer support.
• Improve our application and services.
• Send important notifications.
• Detect fraud and unauthorized activities.
• Comply with applicable laws.

4. Phone Number Verification

Your mobile number is verified using a secure One-Time Password (OTP).
The OTP is used only for authentication and account security.

5. Prescription Uploads

Prescription images uploaded by you are used only to:
• Verify medicines requiring prescriptions.
• Process medicine orders.
• Maintain order records where required by law.

Prescription data is never sold or used for advertising purposes.

6. Sharing Your Information

We respect your privacy.
We do not sell your personal information.

Your information may be shared only with:
• Licensed Pharmacy Partners
• Delivery Partners
• Payment Service Providers
• Technology Service Providers
• Government Authorities when legally required

All partners are required to maintain the confidentiality and security of your information.

7. Data Security

We use appropriate technical and organizational security measures to protect your personal information.

These include:
• Secure servers
• Encrypted communications
• Secure authentication
• Restricted access controls

Although we strive to protect your data, no electronic storage or internet transmission is completely secure.

8. Data Retention

Your information is retained only for as long as necessary to:
• Provide our services.
• Maintain transaction records.
• Meet legal obligations.
• Resolve disputes.

When information is no longer required, it is securely deleted or anonymized.

9. App Permissions

Medy24 may request the following permissions:

Camera: Used to capture prescriptions and profile photos.
Photos & Storage: Used to upload prescriptions and profile images.
Location: Used for medicine delivery and locating nearby pharmacies.
Notifications: Used to send Order updates, OTP verification, Delivery notifications, and Service announcements.
Phone: Used only to verify your mobile number during login.

You may revoke these permissions at any time through your device settings.

10. Cookies & Analytics

Our website and app may use cookies and analytics technologies to:
• Improve performance.
• Remember your preferences.
• Analyze application usage.
• Enhance user experience.

These technologies do not collect sensitive personal information without your consent.

11. Third-Party Services

Medy24 may use trusted third-party services including:
• Firebase Authentication
• Firebase Cloud Messaging
• Google Maps
• Payment Gateway Providers
• Analytics Services

These services have their own privacy policies governing how they process your information.

12. Children's Privacy

Medy24 is intended for users who are 18 years of age or older.
We do not knowingly collect personal information from children.
If we become aware that such information has been collected, we will delete it promptly.

13. Your Rights

You have the right to:
• Access your personal information.
• Update your information.
• Request correction of inaccurate information.
• Delete your account (subject to applicable laws).
• Withdraw permissions granted to the app.
• Contact us regarding any privacy concerns.

14. Changes to this Privacy Policy

We may update this Privacy Policy from time to time.
Changes become effective immediately after they are published in the application or on our website.
We encourage you to review this Privacy Policy periodically.

15. Contact Us

If you have any questions, concerns, or requests regarding this Privacy Policy or your personal information, please contact us:

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

© 2026 Medy24 Private Limited. All rights reserved.
''',
            style: AppTextStyles.description,
          ),
        ),
      ),
    );
  }
}
