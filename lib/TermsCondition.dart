import 'package:flutter/material.dart';

class TermsCondition extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF164660),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF164660).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: Color(0xFF164660),
                  size: 40,
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Terms & Conditions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF164660),
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: 30),

            // Terms Content
            _buildSection(
              title: '1. Acceptance of Terms',
              content: 'By accessing and using the Rudhra SOS Safety App, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you must not use this application.',
            ),

            _buildSection(
              title: '2. Emergency Services',
              content: 'This application is designed for genuine emergency situations only. Misuse of emergency features, including false alerts or non-emergency use, is strictly prohibited and may result in legal action and permanent suspension of services.',
            ),

            _buildSection(
              title: '3. User Responsibilities',
              content: 'You are responsible for:\n• Maintaining accurate personal information\n• Ensuring emergency contacts are valid and consent to being contacted\n• Using the app only for legitimate emergency purposes\n• Keeping your login credentials secure',
            ),

            _buildSection(
              title: '4. Location Services',
              content: 'The app requires access to your location to provide emergency services. By using this app, you consent to sharing your location data with emergency responders and your designated contacts during SOS activations.',
            ),

            _buildSection(
              title: '5. Data Privacy',
              content: 'We collect and process personal data including your name, contact information, location data, and emergency contacts. This data is used solely for emergency response purposes and is protected in accordance with our Privacy Policy.',
            ),

            _buildSection(
              title: '6. Prohibited Uses',
              content: 'You agree not to:\n• Send false emergency alerts\n• Use the app for any illegal purposes\n• Attempt to hack or compromise app security\n• Share your account with others\n• Use automated systems to access the app',
            ),

            _buildSection(
              title: '7. Limitation of Liability',
              content: 'While we strive to provide reliable emergency services, we cannot guarantee uninterrupted access or successful emergency response in all circumstances. The app is provided "as is" without warranties of any kind.',
            ),

            _buildSection(
              title: '8. Service Modifications',
              content: 'We reserve the right to modify, suspend, or discontinue any aspect of the service at any time. Continued use of the app after changes constitutes acceptance of modified terms.',
            ),

            _buildSection(
              title: '9. Account Termination',
              content: 'We may suspend or terminate your account if you violate these terms, misuse emergency services, or engage in any activity that compromises app security or functionality.',
            ),

            _buildSection(
              title: '10. Governing Law',
              content: 'These terms shall be governed by and construed in accordance with the laws of India. Any disputes shall be subject to the exclusive jurisdiction of the courts in your jurisdiction.',
            ),

            _buildSection(
              title: '11. Contact Information',
              content: 'For questions about these Terms and Conditions, please contact us at:\n\nEmail: support@rudhrasos.com\nPhone: +91-XXXXX-XXXXX\nAddress: [Your Company Address]',
            ),

            SizedBox(height: 30),

            // Acceptance Note
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF164660).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF164660).withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_rounded, color: Color(0xFF164660), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By using Rudhra SOS Safety App, you acknowledge that you have read and agree to these Terms and Conditions.',
                      style: TextStyle(
                        color: Color(0xFF164660),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF164660),
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}