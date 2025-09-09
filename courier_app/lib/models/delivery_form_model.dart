// ============================================================================
// DELIVERY FORM MODEL - STATE MANAGEMENT
// ============================================================================
// Model class for managing delivery form state efficiently
// ============================================================================

import 'package:flutter/foundation.dart';

class DeliveryFormModel extends ChangeNotifier {
  // Service type
  String _selectedServiceType = 'city';
  String get selectedServiceType => _selectedServiceType;
  
  // Pickup details
  String _selectedPickupType = 'easybox';
  String _selectedPickupLocation = '';
  String get selectedPickupType => _selectedPickupType;
  String get selectedPickupLocation => _selectedPickupLocation;
  
  // Delivery details
  String _selectedDeliveryType = 'easybox';
  String _selectedDeliveryLocation = '';
  String get selectedDeliveryType => _selectedDeliveryType;
  String get selectedDeliveryLocation => _selectedDeliveryLocation;
  
  // Form validation states
  bool _isPickupSelected = false;
  bool _isDeliverySelected = false;
  bool get isPickupSelected => _isPickupSelected;
  bool get isDeliverySelected => _isDeliverySelected;
  
  // Computed properties
  double get totalPrice => _selectedServiceType == 'city' ? 15.0 : 35.0;
  
  bool get isFormValid => 
      _selectedPickupLocation.isNotEmpty && 
      _selectedDeliveryLocation.isNotEmpty;
  
  // Service type methods
  void setServiceType(String type) {
    if (_selectedServiceType != type) {
      _selectedServiceType = type;
      notifyListeners();
    }
  }
  
  // Pickup methods
  void setPickupType(String type) {
    if (_selectedPickupType != type) {
      _selectedPickupType = type;
      notifyListeners();
    }
  }
  
  void setPickupLocation(String location) {
    if (_selectedPickupLocation != location) {
      _selectedPickupLocation = location;
      notifyListeners();
    }
  }
  
  void setPickupSelected(bool selected) {
    if (_isPickupSelected != selected) {
      _isPickupSelected = selected;
      if (selected) {
        _isDeliverySelected = false;
      }
      notifyListeners();
    }
  }
  
  // Delivery methods
  void setDeliveryType(String type) {
    if (_selectedDeliveryType != type) {
      _selectedDeliveryType = type;
      notifyListeners();
    }
  }
  
  void setDeliveryLocation(String location) {
    if (_selectedDeliveryLocation != location) {
      _selectedDeliveryLocation = location;
      notifyListeners();
    }
  }
  
  void setDeliverySelected(bool selected) {
    if (_isDeliverySelected != selected) {
      _isDeliverySelected = selected;
      if (selected) {
        _isPickupSelected = false;
      }
      notifyListeners();
    }
  }
  
  // Reset methods
  void resetPickupSelection() {
    _isPickupSelected = false;
    notifyListeners();
  }
  
  void resetDeliverySelection() {
    _isDeliverySelected = false;
    notifyListeners();
  }
  
  void resetForm() {
    _selectedServiceType = 'city';
    _selectedPickupType = 'easybox';
    _selectedPickupLocation = '';
    _selectedDeliveryType = 'easybox';
    _selectedDeliveryLocation = '';
    _isPickupSelected = false;
    _isDeliverySelected = false;
    notifyListeners();
  }
}
