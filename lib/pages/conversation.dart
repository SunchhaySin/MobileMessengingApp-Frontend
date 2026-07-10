import 'package:flutter/material.dart';
import 'package:frontend/config/apiConfig.dart';
import 'package:frontend/providers/conversation_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/token.dart';
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;

class ConversationPage extends StatefulWidget {
  final Map<String, dynamic> conversationData;
  final Map<String, dynamic> loggedInUser;
  final String friendName;
  final bool isDarkMode;

  const ConversationPage({
    super.key,
    required this.conversationData,
    required this.loggedInUser,
    required this.friendName,
    required this.isDarkMode,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _textMessageController = TextEditingController();
  late final String conversationId;
  ConversationProvider? _conversationProvider;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    conversationId = widget.conversationData['id'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ConversationProvider>();
      provider.joinConversationRoom(conversationId);

      if (!provider.isLoaded(conversationId)) {
        fetchMessage(conversationId);
      }
    });
  }

  Future fetchMessage(String conversationId) async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/conversation/fetch/messages/$conversationId',
      );
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        context.read<ConversationProvider>().setMessages(conversationId, data);
      }
      setState(() {
          isLoading = false;
        });
    } catch (e) {
      print(e);
    }
  }

  void _sendMessage() {
    final text = _textMessageController.text;
    if (text.trim().isEmpty) return;

    context.read<ConversationProvider>().sendMessage(text, widget.loggedInUser);
    _textMessageController.clear();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe place to grab the provider reference for later use in dispose()
    _conversationProvider = context.read<ConversationProvider>();
  }

  @override
  void dispose() {
    _conversationProvider?.leaveConversationRoom(conversationId);
    _textMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConversationProvider>();
    final messages = provider.messagesFor(conversationId);
    
    return Scaffold(
      body: Container(
        color: widget.isDarkMode ? Colors.black : Colors.white,
        child: Column(
          children: [
            Container(
              height: 80,
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.only(top: 40, right:6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Text(
                          widget.friendName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.more_vert_outlined),
                  ],
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          backgroundColor:Colors.white, 
                          color: Colors.black, 
                          strokeWidth: 2.0, 
                        ),
                      ),
                      SizedBox(height: 8,),
                      Text("Loading...", style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black, fontSize: 12),)
                    ],
                  )
                  : messages.isNotEmpty
                    ? ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[messages.length - 1 - index];
                        final isMe =
                            message['sender']['id'] ==
                            widget.loggedInUser['userID'];

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.blueAccent
                                      : Colors.grey[800],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  message['content'] ?? '',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 6,
                                  right: 6,
                                  bottom: 4,
                                ),
                                child: message['pending'] == true
                                    ? const Text(
                                        "Sending...",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 10,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      )
                                    : Text(
                                        timeago.format(
                                          DateTime.parse(message['sentAt']),
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 10,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No messages yet. Start the conversation!",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
            ),

            Container(
              width: double.infinity,
              height: 60,
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 3),
              child: TextFormField(
                controller: _textMessageController,
                onFieldSubmitted: (_) => _sendMessage(),
                style: TextStyle(color: widget.isDarkMode ?Colors.black : Colors.white),
                decoration: InputDecoration(
                  hintText: "Type a message",
                  hintStyle: TextStyle(fontSize: 14, color: widget.isDarkMode ?Colors.black : Colors.white),
                  suffixIcon: GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Icon(Icons.send, color: Colors.blue.shade700),
                  ),
                  filled: true,
                  fillColor: widget.isDarkMode ?Colors.white : Colors.black87,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
