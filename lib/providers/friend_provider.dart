// import 'package:flutter/material.dart';

// class FriendProvider extends ChangeNotifier {
//   List<dynamic> _friends = [];
//   List<dynamic> _sentRequests = [];
//   List<dynamic> _receivedRequests = [];
//   bool _loaded = false;

//   List<dynamic> get friends => _friends;
//   List<dynamic> get sentRequests => _sentRequests;
//   List<dynamic> get receivedRequests => _receivedRequests;
//   bool get loaded => _loaded;

//   void setFriends(List<dynamic> data) {
//     _friends = data;
//     _loaded = true;
//     notifyListeners();
//   }

//   void setSentRequests(List<dynamic> data) {
//     _sentRequests = data;
//     notifyListeners();
//   }

//   void setReceivedRequests(List<dynamic> data) {
//     _receivedRequests = data;
//     notifyListeners();
//   }

//   void clear() {
//     _friends = [];
//     _sentRequests = [];
//     _receivedRequests = [];
//     _loaded = false;
//     notifyListeners();
//   }
// }