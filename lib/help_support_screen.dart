import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .env file ke liye import karein

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
  // Method to launch the AI Chat Dialog
  void _showAIChatDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const AIChatDialog();
      },
    );
  }

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
        onPressed: () => _showAIChatDialog(context),
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


// --- AI CHAT DIALOG WIDGET ---
class AIChatDialog extends StatefulWidget {
  const AIChatDialog({super.key});

  @override
  State<AIChatDialog> createState() => _AIChatDialogState();
}

class _AIChatDialogState extends State<AIChatDialog> {
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
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
    // --- FIX: API Key ko ab .env file se padha jayega ---
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      return "API Key is not configured. Please contact the developer.";
    }

    final apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey';

    final prompt = '''
      You are a helpful assistant for a mobile app called "VehicleVerified".
      Your purpose is to answer user questions about the app.
      App Context: The app helps users manage vehicle documents, get expiry notifications, and allows police to verify documents via QR code.
      Developer Info: $_developerInfo
      
      Answer the following user question concisely: "$query"
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
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI Assistant'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        )
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
