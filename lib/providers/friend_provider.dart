import 'package:flutter/material.dart';
import 'package:frontend/services/socket.dart';
import 'dart:async';

class FriendProvider extends ChangeNotifier {
  List<dynamic> _friends = [];
  List<dynamic> _sentRequests = [];
  List<dynamic> _receivedRequests = [];
  bool _friendLoaded = false;
  bool _requestsLoaded = false;

  List<dynamic> get friends => _friends;
  List<dynamic> get sentRequests => _sentRequests;
  List<dynamic> get receivedRequests => _receivedRequests;
  bool get friendLoaded => _friendLoaded;
  bool get requestsLoaded => _requestsLoaded;

  get _socket => SocketService().socket; // Connection to socketIO

  // Setter for storing friendList on the first fetch from the database
  void setFriends(List<dynamic> data) {
    _friends = data;
    _friendLoaded = true;
    notifyListeners();
  }

  // Setter for storing request on the first fetch from the database
  void setRequests(List<dynamic> sent, List<dynamic> received) {
    _sentRequests = sent;
    _receivedRequests = received;
    _requestsLoaded = true;
    notifyListeners();
  }

  // ─── Socket Actions ───

  // Handles sending friend request which reflect on sent request in real-time
  Future<String> addFriendRequest(String recipientId) {
    final completer = Completer<String>();
    _socket?.emit('friend:add', {'recipientId': recipientId});

    _socket?.once('friend:add:success', (data) {
      final response = data is List ? data[0] : data;
      _sentRequests.add(response['request']);
      notifyListeners();
      completer.complete(response['message']?.toString() ?? 'Request Sent');
    });

    _socket?.once('friend:add:error', (data) {
      final response = data is List ? data[0] : data;
      completer.complete(
        response['message']?.toString() ?? 'Something went wrong',
      );
    });

    return completer.future;
  }


  // Handles request acception and updates the status in real-time 
  Future<String> acceptRequest(String requestId) {
    final completer = Completer<String>();
    _socket?.emit('friend:accept', {'requestId': requestId});

    _socket?.once('friend:accept:success', (data) {
      final response = data is List ? data[0] : data;
      final index = _receivedRequests.indexWhere((r) => r['id'] == requestId);
      if (index != -1) {
        final existing = Map<String, dynamic>.from(_receivedRequests[index]); 
        _receivedRequests[index] = {
        ...existing,         // ← keep existing data with nested relations
        'status': response['updatedStatus']['status'],                // ← just update the status string directly
      };
    }
      final friendData = response['friend'];
      _friends.add(friendData['friend']);
      notifyListeners();
      completer.complete(response['message']?.toString() ?? 'Request Accepted');
    });

    _socket?.once('friend:accept:error', (data) {
      final response = data is List ? data[0] : data;
      completer.complete(
        response['message']?.toString() ?? 'Something went wrong',
      );
    });

    return completer.future;
  }


  // Handles request rejection and updates the status in real-time 
  Future<String> rejectRequest(String requestId) {
    final completer = Completer<String>();
    _socket?.emit('friend:reject', {'requestId': requestId});

    _socket?.once('friend:reject:success', (data) {
      final response = data is List ? data[0] : data;
      final index = _receivedRequests.indexWhere((r) => r['id'] == requestId);
      if (index != -1) {
        final existing = Map<String, dynamic>.from(_receivedRequests[index]); 
        _receivedRequests[index] = {
          ...existing,
          'status': response['updatedStatus']['status']}; // ← update status in place
      }
      notifyListeners();
      completer.complete(response['message']?.toString() ?? 'Request Rejected');
    });


    _socket?.once('friend:reject:error', (data) {
      final response = data is List ? data[0] : data;
      completer.complete(
        response['message']?.toString() ?? 'Something went wrong',
      );
    });

    return completer.future;
  }

  // Handles removing requests both as the sender and receiver, 1 request is bidirectional
  Future<String> removeRequest(List<String> requestIds, String requestType) {
     final completer = Completer<String>();

    _socket?.emit("request:remove", {"requestIds": requestIds});

    _socket?.once("request:remove:success", (data) {
      if (requestType == 'sent') {
        _sentRequests.removeWhere((r) => requestIds.contains(r['id']));
      } else {
        _receivedRequests.removeWhere((r) => requestIds.contains(r['id']));
      }

      notifyListeners();
      completer.complete(data["message"] as String);
    });

    _socket?.once("request:remove:error", (data) {
      completer.completeError(data["message"] as String);
    });

    return completer.future;
  }

  // ─── Real-time Listeners (other user's side) ───
  void setupFriendListeners() {
    // Notifies when another user's send you a friend request
    _socket?.on('friend:new:request', (data) {
      addReceivedRequest(data['request']);
    });

    // Notifies when another user's accepted you friends request
    _socket?.on('friend:request:accepted', (data) {
      addFriend(data['friend']);
    });

    // Notifies when another user's rejects your friend request
    _socket?.on('friend:request:rejected', (data) {
      removeFromSentRequests(data['requestId']);
    });
  }

  // ─── Local State Helpers ───
  void addReceivedRequest(dynamic data) {
    _receivedRequests.add(data);
    notifyListeners();
  }
  
  void addFriend(dynamic data) {
    _friends.add(data);
    notifyListeners();
  }

  void removeFromSentRequests(String requestId) {
    _sentRequests.removeWhere((r) => r['id'] == requestId);
    notifyListeners();
  }

  void clear() {
    _friends = [];
    _sentRequests = [];
    _receivedRequests = [];
    _friendLoaded = false;
    _requestsLoaded = false;
    notifyListeners();
  }
}
