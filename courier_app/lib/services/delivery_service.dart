// ============================================================================
// DELIVERY SERVICE - DATA MANAGEMENT
// ============================================================================
// Service to manage delivery data across the app
// ============================================================================

import '../models/delivery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DeliveryService {
  static final DeliveryService _instance = DeliveryService._internal();
  factory DeliveryService() => _instance;
  DeliveryService._internal();

  // List to store all deliveries
  List<Delivery> _deliveries = [];

  // Get all deliveries
  List<Delivery> get deliveries => List.unmodifiable(_deliveries);

  // Add a new delivery and persist
  Future<void> addAndPersistDelivery(Delivery delivery) async {
    _deliveries.insert(0, delivery);
    await _saveToPreferences();
  }

  // Get delivery by ID
  Delivery? getDeliveryById(int id) {
    try {
      return _deliveries.firstWhere((delivery) => delivery.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update delivery status
  void updateDeliveryStatus(int id, String status) {
    final index = _deliveries.indexWhere((delivery) => delivery.id == id);
    if (index != -1) {
      _deliveries[index] = _deliveries[index].copyWith(status: status);
    }
  }

  // Load deliveries from SharedPreferences
  Future<void> loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString('deliveries');
      if (jsonString == null || jsonString.isEmpty) {
        return;
      }
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      _deliveries = decoded
          .map((item) => Delivery.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // If parsing fails, keep current list
    }
  }

  // Save deliveries to SharedPreferences
  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> payload =
        _deliveries.map((d) => d.toJson()).toList();
    await prefs.setString('deliveries', json.encode(payload));
  }

  // Generate next ID
  int getNextId() {
    if (_deliveries.isEmpty) return 1;
    return _deliveries.map((d) => d.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}