// lib/screens/chat_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_theme.dart';
import '../gemini_config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': "Hello, I'm Nyra. 💛",
      'isUser': false,
    },
    {
      'text': 'How can I help you stay safe today?',
      'isUser': false,
    },
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // SEND MESSAGE
  // ---------------------------------------------------------------------------

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _isLoading) {
      return;
    }

    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
      });

      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _askGemini();

      if (!mounted) return;

      setState(() {
        _messages.add({
          'text': response,
          'isUser': false,
        });

        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('NYRA GEMINI ERROR: $e');

      if (!mounted) return;

      setState(() {
        _messages.add({
          'text': _friendlyErrorMessage(e),
          'isUser': false,
        });

        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  // ---------------------------------------------------------------------------
  // GEMINI API
  // ---------------------------------------------------------------------------

  Future<String> _askGemini() async {
    const String model = 'gemini-flash-latest';

    final Uri url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$model:generateContent?key=$geminiApiKey',
    );

    // Build conversation history.
    final List<Map<String, dynamic>> contents = [];

    for (final message in _messages) {
      final String text = message['text'] as String;
      final bool isUser = message['isUser'] as bool;

      contents.add({
        'role': isUser ? 'user' : 'model',
        'parts': [
          {
            'text': text,
          },
        ],
      });
    }

    final Map<String, dynamic> requestBody = {
      'systemInstruction': {
        'parts': [
          {
            'text': '''
You are Nyra, a warm, intelligent AI safety companion inside a mobile
personal safety application.

Your personality:
- Calm
- Caring
- Supportive
- Intelligent
- Concise
- Never judgmental
- Never overly dramatic
- Speak naturally like a trusted companion

Your primary purpose is to help the user with:
- Personal safety
- Emergency situations
- Safety planning
- Travel and walking safety
- Understanding what to do when someone feels unsafe
- General questions and everyday conversation
- Emotional reassurance when appropriate

Important safety behavior:

1. If the user says they are in immediate danger:
   - Stay calm.
   - Encourage them to move toward a safe/public place if possible.
   - Encourage contacting a trusted person or appropriate local emergency services.
   - Remind them that the Nyra SOS feature can be used when appropriate.
   - Do not pretend that you have contacted emergency services.

2. Never claim that you can physically see the user, track them,
   contact someone, call emergency services, or access their location
   unless the application explicitly provides that capability.

3. Do not invent information about the user's contacts, location,
   previous conversations, or personal details.

4. If the user asks a normal question unrelated to safety,
   answer helpfully instead of forcing the conversation back to safety.

5. Keep responses reasonably concise and easy to read on a phone.
   Use short paragraphs or bullet points when useful.

6. If the user appears frightened or distressed, respond with empathy
   and practical next steps rather than giving a long lecture.

7. If the user asks for dangerous, illegal, or harmful instructions,
   do not provide instructions that would enable harm. Redirect toward
   a safer alternative.

You are an AI assistant, so be honest about your limitations.

Your name is Nyra.
''',
          },
        ],
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 600,
      },
    };

    debugPrint('NYRA: Sending request to Gemini...');
    debugPrint('NYRA: Model = $model');

    final http.Response response = await http
        .post(
          url,
          headers: {
          'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(
          const Duration(seconds: 30),
        );

    debugPrint('NYRA: Gemini status = ${response.statusCode}');
    debugPrint('NYRA: Gemini response = ${response.body}');

    if (response.statusCode != 200) {
      String errorMessage = 'Gemini request failed.';

      try {
        final Map<String, dynamic> errorData =
            jsonDecode(response.body) as Map<String, dynamic>;

        final dynamic error = errorData['error'];

        if (error is Map<String, dynamic>) {
          final dynamic message = error['message'];

          if (message != null) {
            errorMessage = message.toString();
          }
        }
      } catch (_) {
        // Keep the default error message.
      }

      throw Exception(
        'HTTP ${response.statusCode}: $errorMessage',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Gemini returned an invalid response.');
    }

    final List<dynamic>? candidates =
        decoded['candidates'] as List<dynamic>?;

    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini did not return a response.');
    }

    final dynamic firstCandidate = candidates.first;

    if (firstCandidate is! Map<String, dynamic>) {
      throw Exception('Gemini returned an invalid candidate.');
    }

    final dynamic content = firstCandidate['content'];

    if (content is! Map<String, dynamic>) {
      throw Exception('Gemini response did not contain content.');
    }

    final dynamic parts = content['parts'];

    if (parts is! List<dynamic> || parts.isEmpty) {
      throw Exception('Gemini response did not contain text.');
    }

    final StringBuffer answer = StringBuffer();

    for (final dynamic part in parts) {
      if (part is Map<String, dynamic>) {
        final dynamic text = part['text'];

        if (text != null) {
          answer.write(text.toString());
        }
      }
    }

    final String result = answer.toString().trim();

    if (result.isEmpty) {
      throw Exception('Gemini returned an empty response.');
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // ERROR MESSAGE
  // ---------------------------------------------------------------------------

  String _friendlyErrorMessage(Object error) {
    final String errorText = error.toString();

    debugPrint('NYRA FRIENDLY ERROR: $errorText');

    if (errorText.contains('401') ||
        errorText.toLowerCase().contains('api key') ||
        errorText.toLowerCase().contains('unauthorized')) {
      return '''
I'm having trouble with my connection key right now. 💛

Please check that the Gemini API key is correct and active.
''';
    }

    if (errorText.contains('403') ||
        errorText.toLowerCase().contains('permission')) {
      return '''
I can't access the Gemini service with the current API key.

Please check the API key permissions and Gemini API access. 💛
''';
    }

    if (errorText.contains('429') ||
        errorText.toLowerCase().contains('quota')) {
      return '''
I've reached the current Gemini usage limit.

Please wait a little and try again. 💛
''';
    }

    if (errorText.contains('404') ||
        errorText.toLowerCase().contains('not found')) {
      return '''
I couldn't find the Gemini model I'm trying to use.

Please check the Gemini model/API configuration. 💛
''';
    }

    if (errorText.toLowerCase().contains('timeout')) {
      return '''
The connection took too long.

Please check your internet connection and try again. 💛
''';
    }

    return '''
I couldn't connect to my AI service right now. 💛

Please try again in a moment.
''';
  }

  // ---------------------------------------------------------------------------
  // SCROLLING
  // ---------------------------------------------------------------------------

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPurple,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 12),

              // Main container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.containerBg,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // -------------------------------------------------------
                      // HEADER
                      // -------------------------------------------------------

                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF141927),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              const Positioned(
                                top: 20,
                                left: 20,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'talk with',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accentYellow,
                                        height: 1.1,
                                      ),
                                    ),
                                    Text(
                                      'nyra.',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.accentYellow,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Positioned(
                                right: 12,
                                bottom: 0,
                                child: Image.asset(
                                  'assets/images/pantheronknees.png',
                                  height: 135,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // -------------------------------------------------------
                      // MESSAGES
                      // -------------------------------------------------------

                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _messages.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 8);
                          },
                          itemBuilder: (context, index) {
                            final message = _messages[index];

                            final bool isUser =
                                message['isUser'] as bool;

                            final String text =
                                message['text'] as String;

                            return Align(
                              alignment: isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width *
                                          0.78,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? const Color(0xFF2E243A)
                                      : const Color(0xFF141927),
                                  borderRadius: BorderRadius.only(
                                    topLeft:
                                        const Radius.circular(18),
                                    topRight:
                                        const Radius.circular(18),
                                    bottomLeft: Radius.circular(
                                      isUser ? 18 : 4,
                                    ),
                                    bottomRight: Radius.circular(
                                      isUser ? 4 : 18,
                                    ),
                                  ),
                                  border: Border.all(
                                    color:
                                        Colors.white.withOpacity(0.04),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPurple,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // -------------------------------------------------------
                      // TYPING INDICATOR
                      // -------------------------------------------------------

                      if (_isLoading) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141927),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accentYellow,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Nyra is thinking...',
                                  style: TextStyle(
                                    color: AppColors.textPurple,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // -------------------------------------------------------
                      // INPUT
                      // -------------------------------------------------------

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.fieldBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.only(
                          left: 18,
                          right: 6,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                enabled: !_isLoading,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                ),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Type your message here...',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF6B667C),
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),

                            IconButton(
                              icon: Icon(
                                Icons.send_rounded,
                                color: _isLoading
                                    ? const Color(0xFF55515F)
                                    : AppColors.textPurple,
                                size: 22,
                              ),
                              onPressed:
                                  _isLoading ? null : _sendMessage,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}