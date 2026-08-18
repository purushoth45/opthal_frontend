import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConfig {
  ApiConfig._();

  // Centralized Base URL (Configurable for emulator, simulator, physical device)
  // Android Emulator: http://10.0.2.2:8080
  // iOS Simulator / Web / Desktop: http://localhost:8080 
  
  //172.25.48.52:8080
  
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080/api';
      }
    } catch (_) {}
    return 'http://localhost:8080/api';
  }

  static const Duration timeout = Duration(seconds: 15);

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String questions = '/questions';
}
