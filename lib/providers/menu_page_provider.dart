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
  String _profilePicture = "";
  String get profilePicture => _profilePicture;

  void setProfilePicture(String data) {
    _profilePicture = data;
    notifyListeners();
  }

  void updateProfilePicture(String newProfilePicture) {
    _profilePicture = newProfilePicture;
    notifyListeners();
  }
}