import 'package:flutter/material.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  // --- START: UPDATED CONTENT ---
  final String termsOfService = """
**Terms of Service for VehicleVerified**

**Last Updated: 08 July 2025**

Welcome to VehicleVerified! These terms and conditions outline the rules and regulations for the use of the VehicleVerified application.

**1. Acceptance of Terms**
By accessing and using this app, you accept and agree to be bound by the terms and provision of this agreement.

**2. Description of Service**
VehicleVerified provides a digital platform for vehicle owners to store their vehicle documents (like RC, Insurance, PUC) and for traffic police officials to verify these documents digitally via a QR code system.

**3. User Accounts**
- **Vehicle Owners:** You are responsible for maintaining the confidentiality of your account and password. You must provide accurate and complete information, including your Aadhar number for verification.
- **Traffic Police:** Accounts for traffic police officials require an official ID for registration and may be subject to approval by our administration to ensure only authorized personnel can access verification features.

**4. User Responsibilities**
- You agree not to use the app for any illegal or unauthorized purpose.
- You are solely responsible for the accuracy and legality of the documents you upload.
- You must not misuse the QR code or any other feature of the app.

**5. Limitation of Liability**
The developer of VehicleVerified, Suraj Kumar, will not be held liable for any incorrect data uploaded by the user, or for any damages that result from the use or inability to use this service. The app is provided "as is" without any warranties.

**6. Termination**
We may terminate or suspend your account without prior notice for any breach of these Terms.

**7. Governing Law**
These terms will be governed by and construed in accordance with the laws of India, and you submit to the non-exclusive jurisdiction of the state and federal courts located in Bihar for the resolution of any disputes.

**8. Contact Us**
If you have any questions about these Terms, please contact us at: skr090850@gmail.com
""";

  final String privacyPolicy = """
**Privacy Policy for VehicleVerified**

**Last Updated: 08 July 2025**

Your privacy is important to us. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.

**1. Information We Collect**
We may collect information about you in a variety of ways. The information we may collect includes:
- **Personal Data:** Name, email address, phone number, and Aadhar number (for owners) or Official ID (for police) that you voluntarily give to us when registering.
- **Vehicle & Document Data:** Vehicle details (registration number, chassis number, etc.) and images of your documents (RC, Insurance, PUC) that you upload to the app.

**2. How We Use Your Information**
Having accurate information permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you to:
- Create and manage your account.
- Store and display your vehicle documents for your access.
- Enable verification of your documents by authorized traffic police officials.
- Notify you of upcoming document expiries.

**3. Disclosure of Your Information**
We do not share your personal information with any third parties except as described in this Privacy Policy. We may share information we have collected about you in certain situations:
- **By Law or to Protect Rights:** If we believe the release of information about you is necessary to respond to legal process or protect the rights, property, and safety of others.
- **To Traffic Police:** Your vehicle and document status will be visible to authorized traffic police officials when they scan your QR code or search for your vehicle number for verification purposes.
- **Third-Party Service Providers:** We use Firebase services (Authentication, Firestore, Storage) for backend infrastructure. Your data is stored securely on their servers.

**4. Security of Your Information**
We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that no security measures are perfect or impenetrable.

**5. Contact Us**
If you have questions or comments about this Privacy Policy, please contact us at: skr090850@gmail.com
""";
  // --- END: UPDATED CONTENT ---

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Legal Information', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey.shade800,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Terms of Service'),
              Tab(text: 'Privacy Policy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                termsOfService,
                style: const TextStyle(height: 1.5, fontSize: 15),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                privacyPolicy,
                style: const TextStyle(height: 1.5, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
