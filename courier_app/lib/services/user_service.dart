// ============================================================================
// USER SERVICE - USER DATA MANAGEMENT
// ============================================================================
// This service manages user data persistence across app sessions.
// Features: Phone number storage, user session management
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  
  factory UserService() {
    return _instance;
  }
  
  UserService._internal();
  
  static const String _phoneKey = 'logged_in_phone';
  
  // Save logged-in phone number
  Future<void> savePhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phoneNumber);
  }
  
  // Get saved phone number
  Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }
  
  // Clear saved phone number (for logout)
  Future<void> clearPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneKey);
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final phone = await getPhoneNumber();
    return phone != null && phone.isNotEmpty;
  }
}
