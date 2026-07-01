import 'package:flutter/material.dart';
import 'package:frontend/services/socket.dart';
import 'dart:async';

class FriendProvider extends ChangeNotifier {
  List<dynamic> _friends = [];
  List<dynamic> _sentRequests = [];
  List<dynamic> _receivedRequests = [];
  List<dynamic> _alerts = [];

  bool _friendLoaded = false;
  bool _requestsLoaded = false;
  bool _alertsLoaded = false;
  bool _listenersRegistered = false;

  List<dynamic> get friends => _friends;
  List<dynamic> get sentRequests => _sentRequests;
  List<dynamic> get receivedRequests => _receivedRequests;
  List<dynamic> get alerts => _alerts;

  bool get friendLoaded => _friendLoaded;
  bool get requestsLoaded => _requestsLoaded;
  bool get alertsLoaded => _alertsLoaded;

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

  void setAlerts(List<dynamic> data) {
    _alerts = data;
    _alertsLoaded = true;
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
      _alerts.add(response['alert']);
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

      _alerts.add(response['alert']);
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

      _alerts.add(response['alert']);
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

 // ─── Real-time Listeners (persistent — call once, e.g. right after socket connects) ───
  void setupFriendListeners() {
    if (_listenersRegistered) return; // avoid stacking on reconnect/rebuild
    _listenersRegistered = true;

    // Someone sent ME a friend request
    _socket?.on('friend:new:request', (data) {
      final response = data is List ? data[0] : data;
      _receivedRequests.add(response['request']);
      _alerts.add(response['alert']);
      notifyListeners();
    });

    // The person I sent a request to accepted it
    _socket?.on('friend:request:accepted', (data) {
      final response = data is List ? data[0] : data;
      final requestId = response['updatedStatus']['id'];

      final index = _sentRequests.indexWhere((r) => r['id'] == requestId);
      if (index != -1) {
        final existing = Map<String, dynamic>.from(_sentRequests[index]);
        _sentRequests[index] = {
          ...existing,
          'status': response['updatedStatus']['status'],
        };
      }

      _alerts.add(response['alert']);

      // I'm the requester, so MY new friend is the acceptor → 'user', not 'friend'
      final friendData = response['friend'];
      _friends.add(friendData['user']);

      notifyListeners();
    });

    // The person I sent a request to rejected it
    _socket?.on('friend:request:rejected', (data) {
      final response = data is List ? data[0] : data;
      final requestId = response['updatedStatus']['id'];

      final index = _sentRequests.indexWhere((r) => r['id'] == requestId);
      if (index != -1) {
        final existing = Map<String, dynamic>.from(_sentRequests[index]);
        _sentRequests[index] = {
          ...existing,
          'status': response['updatedStatus']['status'],
        };
      }

      _alerts.add(response['alert']);
      notifyListeners();
    });
  }

  // Call this on logout / socket teardown so listeners don't leak into the next session
  void teardownFriendListeners() {
    _socket?.off('friend:new:request');
    _socket?.off('friend:request:accepted');
    _socket?.off('friend:request:rejected');
    _listenersRegistered = false;
  }

  void clear() {
    teardownFriendListeners();
    _friends = [];
    _sentRequests = [];
    _receivedRequests = [];
    _alerts = [];
    _friendLoaded = false;
    _requestsLoaded = false;
    notifyListeners();
  }
}
