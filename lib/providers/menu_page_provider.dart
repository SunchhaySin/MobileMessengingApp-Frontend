import 'package:flutter/material.dart';

class MenuPageProvider extends ChangeNotifier{
  // Current Logged In User
  Map<String, dynamic> loggedInUser = {};
  Map<String, dynamic> get currentUser => loggedInUser;

  void setCurrentUser(Map<String, dynamic> data) {
    loggedInUser = data;
    notifyListeners();
  }

  void updateUsername(String newUsername) {
    if(loggedInUser.isNotEmpty){
      loggedInUser['username'] = newUsername;
    }
    notifyListeners();
  }

  // Dark Mode
  bool _darkMode = true;
  bool get darkMode => _darkMode;

  void turnOn() {
    _darkMode = true;
    notifyListeners();
  } 

  void turnOff() {
    _darkMode = false;
    notifyListeners();
  } 

  // Stored Profile Data
  String _myContacts = "";
  String get myContacts  => _myContacts;

  String _myBio = "";
  String get myBio => _myBio;


  void setContacts(String data) {
    _myContacts = data;
    notifyListeners();
  }

  void updateContact(String data) {
    _myContacts = data;
    notifyListeners();
  }

  void setBio(String data) {
    _myBio = data;
    notifyListeners();
  }

  void updateBio(String newBio) {
    _myBio = newBio;
    notifyListeners();
  }

  // Profile Picture
  String _profileUrl = "";
  String get profileUrl => _profileUrl;

  void setProfilePicture(String data) {
    _profileUrl = data;
    notifyListeners();
  }

  void updateProfilePicture(String newProfileUrl) {
    _profileUrl = newProfileUrl;
    notifyListeners();
  }

  // Profile History
  List<dynamic> _profileHistoryList = [];
  List<dynamic> get profileHistory => _profileHistoryList;

  void setProfileHistory(List<dynamic> data) {
    _profileHistoryList = data;
    notifyListeners();
  }

  void updateHistoryList(dynamic history) {
    _profileHistoryList.insert(0, history);
    notifyListeners();
  }

  void clear() {
    _profileHistoryList = [];
    loggedInUser = {};
    _profileUrl = "";
    _myContacts = "";
    _myBio = "";
    _darkMode = true;
    notifyListeners();
  }
}