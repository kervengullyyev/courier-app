// ============================================================================
// USER SERVICE - USER DATA MANAGEMENT
// ============================================================================
// This service manages user data persistence across app sessions.
// Features: Phone number storage for profile management
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  
  factory UserService() {
    return _instance;
  }
  
  UserService._internal();
  
  static const String _phoneKey = 'saved_phone';
  
  // Get saved phone number
  Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }
  
  // Save phone number
  Future<void> savePhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phoneNumber);
  }
  
  // Clear saved phone number (for logout)
  Future<void> clearPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneKey);
  }
}