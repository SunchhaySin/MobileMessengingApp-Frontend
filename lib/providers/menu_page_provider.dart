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
}