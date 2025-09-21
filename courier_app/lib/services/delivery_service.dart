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

  // Initialize with sample data
  void initializeWithSampleData() {
    if (_deliveries.isEmpty) {
      _deliveries = [
        Delivery(
          id: 1,
          pickupAddress: 'Easybox - Ashgabat Center',
          deliveryAddress: 'Easybox - Mary City',
          status: 'In Transit',
          courier: const Courier(fullName: 'Ahmet Rahmanov'),
          recipient: const Recipient(fullName: 'Gulnara Berdiyeva', phoneNumber: '+993 12 34 56 78'),
          sender: const Sender(fullName: 'Ahmet Rahmanov', phoneNumber: '+993 12 34 56 78'),
          createdAt: '2024-01-15 14:30:00',
          price: 15.0,
          serviceType: 'city',
          pickupType: 'easybox',
          deliveryType: 'easybox',
          pickupLocation: 'Ashgabat Center',
          deliveryLocation: 'Mary City',
          packageDescription: 'Documents and small package',
        ),
        Delivery(
          id: 2,
          pickupAddress: '123 Main Street, Ashgabat',
          deliveryAddress: '456 Oak Avenue, Turkmenabat',
          status: 'Delivered',
          courier: const Courier(fullName: 'Saparmurat Niyazov'),
          recipient: const Recipient(fullName: 'Merdan Atayev', phoneNumber: '+993 23 45 67 89'),
          sender: const Sender(fullName: 'Gurbanguly Berdimuhamedov', phoneNumber: '+993 23 45 67 89'),
          createdAt: '2024-01-14 09:15:00',
          price: 35.0,
          serviceType: 'inter-city',
          pickupType: 'address',
          deliveryType: 'address',
          pickupLocation: 'Ashgabat City Center',
          deliveryLocation: 'Turkmenabat District',
          packageDescription: 'Electronics and fragile items',
        ),
        Delivery(
          id: 3,
          pickupAddress: 'Easybox - Balkanabat',
          deliveryAddress: '789 Pine Road, Dashoguz',
          status: 'Pending',
          courier: null,
          recipient: const Recipient(fullName: 'Aysoltan Orazova', phoneNumber: '+993 34 56 78 90'),
          sender: const Sender(fullName: 'Oguljeren Berdiyeva', phoneNumber: '+993 34 56 78 90'),
          createdAt: '2024-01-13 16:45:00',
          price: 15.0,
          serviceType: 'city',
          pickupType: 'easybox',
          deliveryType: 'address',
          pickupLocation: 'Balkanabat',
          deliveryLocation: 'Dashoguz Area',
          packageDescription: 'Clothing and personal items',
        ),
      ];
    }
  }

  // Generate next ID
  int getNextId() {
    if (_deliveries.isEmpty) return 1;
    return _deliveries.map((d) => d.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
