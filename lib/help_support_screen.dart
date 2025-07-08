import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Data model for a chat message
class Message {
  final String text;
  final bool isUser;
  Message({required this.text, required this.isUser});
}

// Main Help & Support Screen
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // --- START: MODIFIED to open a Bottom Sheet ---
  // Method to launch the AI Chat Bottom Sheet
  void _showAIChatBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to take up more screen height
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        // We use a DraggableScrollableSheet for a better user experience
        return DraggableScrollableSheet(
          initialChildSize: 0.8, // Start at 80% of screen height
          maxChildSize: 0.9, // Can be dragged up to 90%
          minChildSize: 0.4, // Can be dragged down to 40%
          builder: (_, controller) {
            return AIChatSheet(scrollController: controller);
          },
        );
      },
    );
  }
  // --- END: MODIFICATION ---

  @override
  Widget build(BuildContext context) {
    const String contactEmail = 'skr090850@gmail.com';
    final Map<String, String> faq = {
      'How do I add a new vehicle?':
      'From the main dashboard, tap the floating "+" button at the bottom to open the "Add Vehicle" form. Fill in the details and tap "Save".',
      'How is my data secured?':
      'All your data, including personal information and document images, is securely stored and encrypted using industry-standard protocols on Firebase servers.',
      'What happens if a document expires?':
      'The app will send you a notification before the expiry date. The document status will also change to "Expired" in the app.',
    };

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
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...faq.entries.map((entry) => _buildFaqTile(question: entry.key, answer: entry.value)).toList(),
          const SizedBox(height: 32),
          const Text(
            'Contact Developer',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildContactCard(context, contactEmail),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAIChatBottomSheet(context),
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text('AI Assistant'),
        backgroundColor: Theme.of(context).primaryColor,
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
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Text(answer, style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, String email) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.person_outline, color: Colors.grey.shade700),
            title: const Text('App Developer'),
            subtitle: const Text('Suraj Kumar'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.email_outlined, color: Colors.grey.shade700),
            title: const Text('Email Support'),
            subtitle: Text(email),
            trailing: const Icon(Icons.send),
            onTap: () async {
              final Uri url = Uri(
                scheme: 'mailto',
                path: email,
                query: 'subject=VehicleVerified App Support&body=Hello Suraj,\n\n',
              );
              if (!await launchUrl(url)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not launch email app.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}


// --- AI CHAT WIDGET (for Bottom Sheet) ---
class AIChatSheet extends StatefulWidget {
  final ScrollController scrollController;
  const AIChatSheet({super.key, required this.scrollController});

  @override
  State<AIChatSheet> createState() => _AIChatSheetState();
}

class _AIChatSheetState extends State<AIChatSheet> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isBotTyping = false;

  final String _developerInfo = '''
    This app was proudly developed by Suraj Kumar. 
    Contact Email: skr090850@gmail.com
  ''';

  @override
  void initState() {
    super.initState();
    _messages.add(Message(
        text: 'Hello! How can I help you with the VehicleVerified app?',
        isUser: false));
  }

  void _sendMessage() async {
    final String query = _textController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add(Message(text: query, isUser: true));
      _isBotTyping = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      String response = await _getGeminiResponse(query);
      setState(() {
        _messages.add(Message(text: response, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(text: "Sorry, an error occurred. Please try again.", isUser: false));
      });
    } finally {
      setState(() {
        _isBotTyping = false;
      });
      _scrollToBottom();
    }
  }

  Future<String> _getGeminiResponse(String query) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      return "API Key is not configured. Please contact the developer.";
    }

    final apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey';

    final prompt = '''
      You are "VehicleVerified AI Assistant", a friendly and expert guide for the "VehicleVerified" mobile app.
      Your main goal is to help users understand how to use the app based on the detailed context provided below.
      Keep your answers concise, helpful, and easy to understand.

      **APP CONTEXT:**
      - **Primary Goal:** To digitize vehicle document management and verification.
      - **User Roles:** 1.  **Vehicle Owner:** Can register, add multiple vehicles, upload documents (RC, Insurance, PUC), generate a unique QR code for each vehicle, book services, and view service history.
        2.  **Traffic Police:** Can log in securely, scan a vehicle's QR code, or manually enter a registration number to instantly verify the status of all documents (Valid, Expired, Missing).
      - **Key Processes:**
        - **QR Code Security:** The QR code ONLY contains the vehicle's unique internal ID. It does NOT contain any personal or document data. When a police officer scans the code, the app uses this ID to fetch the LATEST document status directly and securely from the Firebase database in real-time.
        - **Service Booking:** Owners can book various services. After the scheduled service date passes, the app prompts the owner via a notification to confirm if the service was completed and to rate it ("Good" or "Bad"). This updates the service history.
        - **Notifications:** The app has a notification system to alert users about upcoming document expiries and to ask for service completion confirmations.
      - **Developer Information:** The app was developed by Suraj Kumar. His contact details are: $_developerInfo.

      **USER'S QUESTION:**
      "$query"

      Now, based on all the context above, provide the best possible answer.
    ''';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{'parts': [{'text': prompt}]}]
      }),
    );

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      return decodedResponse['candidates'][0]['content']['parts'][0]['text'];
    } else {
      print('API Error: ${response.body}');
      throw Exception('Failed to get response from AI.');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.scrollController.hasClients) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // --- START: Added Padding to avoid keyboard ---
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      // --- END: Added Padding ---
      child: Column(
        children: [
          // Handle to indicate draggable sheet
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isBotTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildMessageBubble(Message(text: "Typing...", isUser: false));
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          const Divider(height: 1),
          _buildChatInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: message.isUser ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message.text, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _buildChatInputField() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration.collapsed(hintText: 'Ask a question...'),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
