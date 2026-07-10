import 'dart:io' show Platform;

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://192.168.1.37:3000';
  }
}