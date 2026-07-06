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
  // final bool? isNewChat;

  const ConversationPage({
    super.key,
    required this.conversationData,
    required this.loggedInUser,
    required this.friendName,
    // required this.isNewChat
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _textMessageController = TextEditingController();
  late final String conversationId;
  ConversationProvider? _conversationProvider;

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
    } catch (e) {
      print(e);
    }
  }

  void _sendMessage() {
    final text = _textMessageController.text;
    if (text.trim().isEmpty) return;

    context.read<ConversationProvider>().sendMessage(text);
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
        color: Colors.black87,
        child: Column(
          children: [
            Container(
              height: 60,
              width: double.infinity,
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
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
              child: messages.isNotEmpty
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
                                child: Text(
                                  timeago.format(
                                    DateTime.parse(message['sentAt']),
                                  ),
                                  style: TextStyle(
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
                decoration: InputDecoration(
                  hintText: "Type a message",
                  hintStyle: TextStyle(fontSize: 14, color: Colors.black),
                  suffixIcon: GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Icon(Icons.send, color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
