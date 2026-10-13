import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Make sure it not Web Plaform is not support on Web browser
    // if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3000';
    // return 'http://192.168.1.35:3000';
    return 'https://mobile-messengingapp-server.onrender.com';
  }
}