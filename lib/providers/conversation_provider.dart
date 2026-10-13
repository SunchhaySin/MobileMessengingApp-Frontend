import 'package:flutter/material.dart';
import 'package:frontend/services/socket.dart';

class ConversationProvider extends ChangeNotifier {
  // Cache: conversationId -> list of messages
  final Map<String, List<dynamic>> _messagesByConversation = {};

  // Track which conversations have been loaded from REST at least once
  final Set<String> _loadedConversations = {};

  // Store all conversation is a List
  List<dynamic> _conversations = [];
  bool _conversationsLoaded = false;

  // Conversations moved here when the other participant is unfriended
  // (kept read-only / hidden from the main list, not deleted)
  List<dynamic> _archivedConversations = [];

  List<dynamic> get conversations => _conversations;
  bool get conversationsLoaded => _conversationsLoaded;
  List<dynamic> get archivedConversations => _archivedConversations;

  String? _activeConversationId;
  String? _errorMessage;
  bool _listenersRegistered = false;

  String? get activeConversationId => _activeConversationId;
  String? get errorMessage => _errorMessage;

  // Get messages for a specific conversation (empty list if not loaded yet)
  List<dynamic> messagesFor(String conversationId) =>
      _messagesByConversation[conversationId] ?? [];

  bool isLoaded(String conversationId) =>
      _loadedConversations.contains(conversationId);

  get _socket => SocketService().socket;

  void setupMessageListeners() {
    if (_listenersRegistered) return; 
    _listenersRegistered = true;

    _socket?.on('new:message', _onNewMessage);
    _socket?.on('error', _onSocketError);
    _socket?.on('friend:removed', _onFriendRemoved);
     _socket?.on('conversation:deleted', _onConversationDeleted);
  }

  void teardownMessageListeners() {
    _socket?.off('new:message', _onNewMessage);
    _socket?.off('error', _onSocketError);
    _socket?.off('friend:removed', _onFriendRemoved);
     _socket?.on('conversation:deleted', _onConversationDeleted);
    _listenersRegistered = false;
  }

  // Called once after fetching from REST API for a given conversation
  void setMessages(String conversationId, List<dynamic> data) {
    _messagesByConversation[conversationId] = data;
    _loadedConversations.add(conversationId);
    notifyListeners();
  }

  void setConversations(List<dynamic> conversations) {
    _conversations = conversations.where((c) => c['isArchived'] != true).toList();
    _archivedConversations = conversations.where((c) => c['isArchived'] == true).toList();
    _conversationsLoaded = true;
    notifyListeners();
  }

  void joinConversationRoom(String conversationId) {
    if (_activeConversationId != null &&
        _activeConversationId != conversationId) {
      leaveConversationRoom(_activeConversationId!);
    }

    _activeConversationId = conversationId;
    _errorMessage = null;
    notifyListeners();

    _socket?.emit('join_conversation', conversationId);
  }

  // Helper Function to archive unfriended chats
  void _onFriendRemoved(dynamic data) {
    final response = data is List ? data[0] : data;
    final removerId = response['removedBy'];
    if (removerId == null) return;
    archiveConversationByUserId(removerId);
  }

  void _onConversationDeleted(dynamic data) {
    final response = data is List ? data[0] : data;
    final conversationId = response['conversationId'];
    if (conversationId == null) return;
    removeConversation(conversationId);
  }

  // Reorginises all messages in a specific coversation, replacing the optimistic message with the real one from the database
  void _onNewMessage(dynamic data) {
    final conversationId = data['conversationId'];
    if (conversationId == null) return;

    // Ensure a list exists even if this conversation was never REST-loaded
    _messagesByConversation.putIfAbsent(conversationId, () => []);

    final messages = _messagesByConversation[conversationId]!;
    final tempId = data['tempId'];

    if (tempId != null) {
      final index = messages.indexWhere((m) => m['id'] == tempId);

      if (index != -1) {
        // Replace the optimistic message with the real one
        messages[index] = data;
      } else {
        // Didn't find an optimistic message (e.g. another user sent it)
        messages.add(data);
      }
    } else {
      // Messages that don't have a tempId (or older server versions)
      messages.add(data);
    }

    _updateConversationSummary(data);
    notifyListeners();
  }

  // Sends the Optimistic message along with the tempId => server broadcasts the new message to members of the conversation (your friend)
  void sendMessage(String content, Map<String, dynamic> currentUser) {
    if (content.trim().isEmpty || _activeConversationId == null) return;
    
    final tempId = "temp_${DateTime.now().microsecondsSinceEpoch}";

    final optimisticMessage = {
      "id": tempId,
      "conversationId": _activeConversationId,
      "content": content.trim(),
      "sender": {
        "id": currentUser["userID"],
        "username": currentUser["username"],
      },
      "sentAt": DateTime.now().toIso8601String(),
      "pending": true,
    };

    _messagesByConversation.putIfAbsent(_activeConversationId!, () => []);
    _messagesByConversation[_activeConversationId]!.add(optimisticMessage);

    // Update the conversation preview immediately
    _updateConversationSummary(optimisticMessage);

    notifyListeners();

    _socket?.emit('send:message', {
      'tempId': tempId,
      'conversationId': _activeConversationId,
      'content': content.trim(),
    });
  }

  // Updating the UI of the Chat widgets Rendered on the HomeScreen
  void _updateConversationSummary(dynamic message) {
    final conversationId = message['conversationId'];

    final index = _conversations.indexWhere((c) => c['id'] == conversationId);

    if (index == -1) return;

    _conversations[index]['messages'] = [message];

    // Optional: move the conversation to the top
    final conversation = _conversations.removeAt(index);
    _conversations.insert(0, conversation);
  }

  // Moves a conversation to the archive list when the other participant is unfriended.
  // Looks up the conversation by the other user's id rather than conversationId,
  // since that's what's available at the point of unfriending.
  void archiveConversationByUserId(String friendUserId) {
    final index = _conversations.indexWhere((c) =>
        c['user1Id'] == friendUserId || c['user2Id'] == friendUserId);

    if (index == -1) return; // no conversation existed with this user

    // final conversation = _conversations.removeAt(index);
    final conversation = Map<String, dynamic>.from(_conversations.removeAt(index));
    conversation['isArchived'] = true;
    _archivedConversations.insert(0, conversation);
    notifyListeners();
  }

  void removeConversation(String conversationId) {
    _conversations.removeWhere((c) => c['id'] == conversationId);
    _archivedConversations.removeWhere((c) => c['id'] == conversationId);
    _messagesByConversation.remove(conversationId);
    _loadedConversations.remove(conversationId);
    notifyListeners();
  }

  void addConversation(Map<String, dynamic> conversation) {
    final exists = _conversations.any((c) => c['id'] == conversation['id']);

    if (!exists) {
      _conversations.insert(0, conversation);
      notifyListeners();
    }
  }

  void _onSocketError(dynamic data) {
    _errorMessage = data['message'] ?? 'Something went wrong';
    notifyListeners();
  }

  void leaveConversationRoom(String conversationId) {
    _socket?.emit('leave_conversation', conversationId);
    if (_activeConversationId == conversationId) {
      _activeConversationId = null;
    }
  }

  void clear() {
    teardownMessageListeners();
    _conversations.clear();
    _conversationsLoaded = false;

    _messagesByConversation.clear();
    _loadedConversations.clear();

    _activeConversationId = null;
    _errorMessage = null;
    
    notifyListeners();
  }

  @override
  void dispose() {
    teardownMessageListeners();
    super.dispose();
  }
}
