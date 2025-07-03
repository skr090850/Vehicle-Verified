import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey.shade200,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Frequently Asked Questions (FAQs)',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFaqTile(
            question: 'How do I add a new vehicle?',
            answer: 'From the main dashboard, tap the floating "+" button at the bottom to open the "Add Vehicle" form. Fill in the details and tap "Save".',
          ),
          _buildFaqTile(
            question: 'How is my data secured?',
            answer: 'All your data, including personal information and document images, is securely stored and encrypted using industry-standard protocols on Firebase servers.',
          ),
          _buildFaqTile(
            question: 'What happens if a document expires?',
            answer: 'The app will send you a notification before the expiry date. The document status will also change to "Expired" in the app, and your overall vehicle status will become "Not Verified" until you upload a new, valid document.',
          ),
          const SizedBox(height: 32),
          const Text(
            'Contact Us',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.email_outlined, color: Colors.grey.shade700),
                  title: const Text('Email Support'),
                  subtitle: const Text('support@vehicleverified.com'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.phone_outlined, color: Colors.grey.shade700),
                  title: const Text('Call Us'),
                  subtitle: const Text('+91 12345 67890'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFaqTile({required String question, required String answer}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer, style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
