import 'package:flutter/material.dart';
import 'package:frontend/config/apiConfig.dart';
import 'package:frontend/providers/conversation_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/token.dart';
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;
import '../widgets/dialog/deleteConversation.dart';

class ConversationPage extends StatefulWidget {
  final Map<String, dynamic> conversationData;
  final Map<String, dynamic> loggedInUser;
  final String friendName;
  final bool isDarkMode;
  final String profileInitials;
  final String? profileUrl;

  const ConversationPage({
    super.key,
    required this.conversationData,
    required this.loggedInUser,
    required this.friendName,
    required this.isDarkMode,
    required this.profileInitials,
    this.profileUrl,
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

  Future<String> deleteConversation(String conversationId) async {
    try {
      final res = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/conversation/delete/$conversationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );
      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        if (mounted) {
          context.read<ConversationProvider>().removeConversation(
            conversationId,
          );
        }
        return data['message']?.toString() ?? 'Conversation deleted';
      } else {
        return data['message']?.toString() ?? 'Failed to delete conversation';
      }
    } catch (e) {
      print(e);
      return 'Something went wrong';
    }
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
    final bool isArchived = (widget.conversationData['isArchived'] as bool?) ?? false;

    return Scaffold(
      body: Container(
        color: widget.isDarkMode ? Colors.black : Colors.white,
        child: Column(
          children: [
            Container(
              height: 80,
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.only(top: 40, right: 6, bottom: 4),
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
                        widget.profileUrl != null
                            ? CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  widget.profileUrl!,
                                ),
                              )
                            : CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue.shade800,
                                child: Center(
                                  child: Text(
                                    widget.profileInitials,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                        SizedBox(width: 4),
                        Text(
                          widget.friendName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Icon(Icons.more_vert_outlined),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_outlined, color: Colors.white),
                      color: Color(0xFF1E1E2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      offset: Offset(-32, -8),
                      padding: EdgeInsets
                          .zero, // removes default outer padding around the menu items
                      onSelected: (value) async {
                        if (value == 'archive' || value == 'unArchive') {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Feature currently unresolved, Try Again!",
                                ),
                              ),
                            );
                          }
                        } else if (value == 'delete') {
                          DeleteconversationDialog(
                            friendUsername: widget.friendName,
                            conversationId: conversationId,
                            onConfirm: () async {
                              final message = await deleteConversation(
                                conversationId,
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              }
                            },
                          ).openDialog(context);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: isArchived ? 'unArchive' : 'archive',
                          height: 25,
                          child: Row(
                            children: [
                              Icon(
                                isArchived ? Icons.unarchive : Icons.archive,
                                color: Colors.white70,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Text(
                                isArchived ? 'Unarchive' : 'Archive',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          enabled:
                              false, // prevents the divider from being selectable/tappable
                          height: 1,
                          padding: EdgeInsets.zero,
                          child: Divider(
                            color: Colors.white24,
                            height: 1,
                            thickness: 1,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          height: 25,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                            backgroundColor: Colors.white,
                            color: Colors.black,
                            strokeWidth: 2.0,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Loading...",
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontSize: 12,
                          ),
                        ),
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
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.6,
                            ),
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
                                      ? Text(
                                          "Sending...",
                                          style: TextStyle(
                                            color: widget.isDarkMode
                                                ? Colors.white54
                                                : Colors.black87,
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        )
                                      : Text(
                                          timeago.format(
                                            DateTime.parse(message['sentAt']),
                                          ),
                                          style: TextStyle(
                                            color: widget.isDarkMode
                                                ? Colors.white54
                                                : Colors.black87,
                                            fontSize: 10,
                                          ),
                                        ),
                                ),
                              ],
                            ),
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
            !isArchived
                ? Container(
                    width: double.infinity,
                    height: 60,
                    margin: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      top: 3,
                    ),
                    child: TextFormField(
                      controller: _textMessageController,
                      onFieldSubmitted: (_) => _sendMessage(),
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.black : Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: widget.isDarkMode
                              ? Colors.black
                              : Colors.white,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () => _sendMessage(),
                          child: Icon(Icons.send, color: Colors.blue.shade700),
                        ),
                        filled: true,
                        fillColor: widget.isDarkMode
                            ? Colors.white
                            : Colors.black87,
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
                  )
                : Container(
                    width: double.infinity,
                    height: 66,
                    color: Colors.blue.shade700,
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.archive_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "This coversation has been archived",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "Restore you friendship to chat with ${widget.friendName}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
