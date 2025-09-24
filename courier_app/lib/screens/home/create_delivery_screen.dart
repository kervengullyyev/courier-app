// ============================================================================
// HOME SCREEN - CREATE DELIVERY
// ============================================================================
// This is the main screen where users create new delivery orders.
// Features: Service type selection, location selection, form validation
// Navigation: Bottom nav tab 0 (Home)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../theme/app_theme.dart';
import '../../models/delivery.dart';
import '../../services/delivery_service.dart';
import '../../services/localization_service.dart';
import '../../services/user_service.dart';

class CreateDeliveryScreen extends StatefulWidget {
  const CreateDeliveryScreen({Key? key}) : super(key: key);

  @override
  _CreateDeliveryScreenState createState() => _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends State<CreateDeliveryScreen> {

  final _formKey = GlobalKey<FormState>();
  final _pickupAddressController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final FocusNode _senderNameFocus = FocusNode();
  final DeliveryService _deliveryService = DeliveryService();
  final UserService _userService = UserService();
  
  String _selectedServiceType = 'city'; // 'city' or 'region'
  String _selectedPickupType = 'office'; // 'office' or 'address'
  String _selectedPickupLocation = ''; // Selected location name
  String _selectedDeliveryType = 'office'; // 'office' or 'address'
  String _selectedDeliveryLocation = ''; // Selected delivery location name
  bool _isPickupSelected = false; // Track if pickup button is clicked
  bool _isDeliverySelected = false; // Track if delivery button is clicked
  bool _isProcessing = false; // Track if delivery is being processed
  // Location mapping with proper structure
  static const Map<String, Map<String, dynamic>> _locations = {
    // City locations
    'bagtyyarlyk_etrap': {
      'name': 'Bagtyyarlyk Etrap',
      'description': 'Central district with business centers',
      'price': 10,
      'type': 'city',
    },
    'berkararlyk_etrap': {
      'name': 'Berkararlyk Etrap',
      'description': 'Residential area with shopping centers',
      'price': 10,
      'type': 'city',
    },
    'buzmeyin_etrap': {
      'name': 'Buzmeyin Etrap',
      'description': 'Industrial zone with warehouses',
      'price': 10,
      'type': 'city',
    },
    'kopetdag_etrap': {
      'name': 'Kopetdag Etrap',
      'description': 'Mountain area with scenic views',
      'price': 10,
      'type': 'city',
    },
    'anew': {
      'name': 'Anew',
      'description': 'Historic city with cultural sites',
      'price': 20,
      'type': 'city',
    },
    'gokdepe': {
      'name': 'Gokdepe',
      'description': 'Modern city with new developments',
      'price': 30,
      'type': 'city',
    },
    'arkadag': {
      'name': 'Arkadag',
      'description': 'New administrative center',
      'price': 30,
      'type': 'city',
    },
    // Inter-city locations
    'mary_shaher': {
      'name': 'Mary Shaher',
      'description': 'Major city in Mary region',
      'price': 40,
      'type': 'inter_city',
    },
    'wekilbazar_etrap': {
      'name': 'Wekilbazar Etrap',
      'description': 'Agricultural district in Mary region',
      'price': 50,
      'type': 'inter_city',
    },
    'sakarcage_etrap': {
      'name': 'Sakarcage Etrap',
      'description': 'Rural district with farming communities',
      'price': 50,
      'type': 'inter_city',
    },
    'bayramaly_etrap': {
      'name': 'Bayramaly Etrap',
      'description': 'Desert region with oil fields',
      'price': 60,
      'type': 'inter_city',
    },
    'murgap_etrap': {
      'name': 'Murgap Etrap',
      'description': 'Oasis region with water resources',
      'price': 60,
      'type': 'inter_city',
    },
    'mary_etrap': {
      'name': 'Mary Etrap',
      'description': 'Central district of Mary region',
      'price': 50,
      'type': 'inter_city',
    },
  };

  // Helper methods for location access
  static List<Map<String, String>> get cityLocations => _locations.entries
      .where((entry) => entry.value['type'] == 'city')
      .map((entry) => {
            'key': entry.key,
            'name': entry.value['name'] as String,
            'description': entry.value['description'] as String,
            'price': (entry.value['price'] as int).toString(),
          })
      .toList();

  static List<Map<String, String>> get interCityLocations => _locations.entries
      .where((entry) => entry.value['type'] == 'inter_city')
      .map((entry) => {
            'key': entry.key,
            'name': entry.value['name'] as String,
            'description': entry.value['description'] as String,
            'price': (entry.value['price'] as int).toString(),
          })
      .toList();

  static int getLocationPrice(String locationKey) {
    return _locations[locationKey]?['price'] ?? 0;
  }

  static String getLocationName(String locationKey) {
    return _locations[locationKey]?['name'] ?? locationKey;
  }

  int get _totalPrice {
    if (_selectedPickupLocation.isEmpty || _selectedDeliveryLocation.isEmpty) {
      return 0;
    }
    
    // Convert location names to keys for lookup
    final pickupKey = _getLocationKey(_selectedPickupLocation);
    final deliveryKey = _getLocationKey(_selectedDeliveryLocation);
    
    final pickupPrice = getLocationPrice(pickupKey);
    final deliveryPrice = getLocationPrice(deliveryKey);
    
    return pickupPrice + deliveryPrice;
  }

  // Helper method to convert location name to key
  String _getLocationKey(String locationName) {
    return _locations.entries
        .firstWhere(
          (entry) => entry.value['name'] == locationName,
          orElse: () => MapEntry('', {}),
        )
        .key;
  }
  static const String _sheetsWebhookUrl = String.fromEnvironment(
    'SHEETS_WEBHOOK_URL',
    defaultValue: 'https://script.google.com/macros/s/AKfycbzadr9Ze3SFcZGasVBxyFVvQZeYJXTm0_dlJX3c17NlxjPmSLGI8FtdyK4txS9ztoUDTw/exec',
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pickupAddressController.dispose();
    _deliveryAddressController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _descriptionController.dispose();
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _senderNameFocus.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(localizationService.translate('app_title'), style: AppTheme.headerStyle),
        leading: const Icon(Icons.local_shipping, color: AppTheme.primaryColor, size: 28),
      ),
      body: SafeArea(
        child: Column(
        children: [
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
            
            // Delivery Type Label
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localizationService.translate('delivery_type'),
                  style: AppTheme.labelTextStyle,
                ),
              ),
            ),
            
            // Service Type Selection
            Container(
              margin: EdgeInsets.fromLTRB(16, 2, 16, 4),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                      // City Option
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedServiceType = 'city';
                        _selectedPickupLocation = '';
                        _selectedDeliveryLocation = '';
                      }),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedServiceType == 'city' ? AppTheme.primaryColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedServiceType == 'city' ? AppTheme.primaryColor : Colors.grey[300]!,
                            width: 1.6,
                          ),
                        ),
                        child: Text(
                          localizationService.translate('city'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeLarge,
                            fontWeight: FontWeight.w500,
                            color: _selectedServiceType == 'city' ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 12),
                  
                  // Inter-City Option
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedServiceType = 'region';
                        _selectedPickupLocation = '';
                        _selectedDeliveryLocation = '';
                      }),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedServiceType == 'region' ? AppTheme.primaryColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedServiceType == 'region' ? AppTheme.primaryColor : Colors.grey[300]!,
                            width: 1.6,
                          ),
                        ),
                        child: Text(
                          localizationService.translate('inter_city'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeLarge,
                            fontWeight: FontWeight.w500,
                            color: _selectedServiceType == 'region' ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 8),
            
            // Pickup & Delivery Address Label
            Padding(
              padding: EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${localizationService.translate('pickup_location')} & ${localizationService.translate('delivery_location')}',
                  style: AppTheme.labelTextStyle,
                ),
              ),
            ),
            
            // Location Selection
            Container(
              margin: EdgeInsets.fromLTRB(16, 2, 16, 4),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Pickup Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPickupSelected = true;
                          _isDeliverySelected = false;
                        });
                        if (_selectedServiceType == 'city') {
                          // City service: go directly to location selection
                          _showLocationDialog(isPickup: true, localizationService: localizationService);
                        } else {
                          // Inter-city service: show pickup type options
                          _showPickupOptionsDialog(localizationService: localizationService);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _selectedPickupLocation.isNotEmpty ? AppTheme.primaryColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (_isPickupSelected || _selectedPickupLocation.isNotEmpty) ? AppTheme.primaryColor : Colors.grey[300]!,
                            width: 1.6,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedPickupType == 'office' ? Icons.grid_view : Icons.home,
                              size: 16,
                              color: _selectedPickupLocation.isNotEmpty ? Colors.white : AppTheme.primaryColor,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _selectedPickupLocation.isNotEmpty 
                                    ? _selectedPickupLocation
                                    : localizationService.translate('select'),
                                style: TextStyle(
                                  fontSize: AppTheme.fontSizeLarge,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedPickupLocation.isNotEmpty ? Colors.white : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_selectedPickupLocation.isEmpty) ...[
                              SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 8),
                  
                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  
                  SizedBox(width: 8),
                  
                  // Delivery Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectedPickupLocation.isEmpty ? null : () {
                        setState(() {
                          _isDeliverySelected = true;
                          _isPickupSelected = false;
                        });
                        if (_selectedServiceType == 'city') {
                          // City service: go directly to location selection
                          _showLocationDialog(isPickup: false, localizationService: localizationService);
                        } else {
                          // Inter-city service: show delivery type options
                          _showDeliveryOptionsDialog(localizationService: localizationService);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _selectedPickupLocation.isEmpty 
                              ? Colors.grey[100] 
                              : (_selectedDeliveryLocation.isNotEmpty ? AppTheme.primaryColor : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedPickupLocation.isEmpty 
                                ? Colors.grey[200]!
                                : ((_isDeliverySelected || _selectedDeliveryLocation.isNotEmpty) ? AppTheme.primaryColor : Colors.grey[300]!),
                            width: 1.6,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedDeliveryType == 'office' ? Icons.grid_view : Icons.home,
                              size: 16,
                              color: _selectedPickupLocation.isEmpty 
                                  ? Colors.grey[400]
                                  : (_selectedDeliveryLocation.isNotEmpty ? Colors.white : AppTheme.primaryColor),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _selectedPickupLocation.isEmpty 
                                    ? localizationService.translate('select_pickup_first')
                                    : (_selectedDeliveryLocation.isNotEmpty 
                                        ? _selectedDeliveryLocation
                                        : localizationService.translate('select')),
                                style: TextStyle(
                                  fontSize: AppTheme.fontSizeLarge,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedPickupLocation.isEmpty 
                                      ? Colors.grey[400]
                                      : (_selectedDeliveryLocation.isNotEmpty ? Colors.white : Colors.black),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_selectedDeliveryLocation.isEmpty && _selectedPickupLocation.isNotEmpty) ...[
                              SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 8),

            // Sender Information Label
            Padding(
              padding: EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localizationService.translate('sender_information'),
                  style: AppTheme.labelTextStyle,
                ),
              ),
            ),

            // Sender Information
            Container(
              margin: EdgeInsets.fromLTRB(16, 2, 16, 4),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender Name
                  TextFormField(
                    controller: _senderNameController,
                    focusNode: _senderNameFocus,
                    maxLength: 28,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: localizationService.translate('sender_name'),
                      hintStyle: TextStyle(fontSize: AppTheme.fontSizeLarge, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.6),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      counterText: '', // Hide the default counter
                    ),
                  ),
                  SizedBox(height: 10),
                  // Sender Phone
                  TextFormField(
                    controller: _senderPhoneController,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      hintText: localizationService.translate('sender_phone'),
                      prefixIcon: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.only(left: 16, right: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '+993',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSizeXLarge,
                                  // fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      hintStyle: TextStyle(fontSize: AppTheme.fontSizeLarge, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.6),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      counterText: '', // Hide the default counter
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            // Recipient Information Label
            Padding(
              padding: EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localizationService.translate('recipient_information'),
                  style: AppTheme.labelTextStyle,
                ),
              ),
            ),
            
            // Recipient Information
            Container(
              margin: EdgeInsets.fromLTRB(16, 2, 16, 4),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipient Name
                  TextFormField(
                    controller: _recipientNameController,
                    maxLength: 28,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: localizationService.translate('recipient_name'),
                      hintStyle: TextStyle(fontSize: AppTheme.fontSizeLarge, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.6),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      counterText: '', // Hide the default counter
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter recipient name';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 10),
                  
                  // Phone Number
                  TextFormField(
                    controller: _recipientPhoneController,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      hintText: localizationService.translate('recipient_phone'),
                      prefixIcon: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.only(left: 16, right: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '+993',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSizeXLarge,
                                  // fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      hintStyle: TextStyle(fontSize: AppTheme.fontSizeLarge, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.6),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      counterText: '', // Hide the default counter
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 8),
            
            // Package Information Label
            Padding(
              padding: EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localizationService.translate('package_info'),
                  style: AppTheme.labelTextStyle,
                ),
              ),
            ),
            
            // Package Information
            Container(
              margin: EdgeInsets.fromLTRB(16, 2, 16, 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _descriptionController,
                builder: (context, value, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        maxLength: 200,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: localizationService.translate('package_info_hint'),
                          hintStyle: TextStyle(fontSize: AppTheme.fontSizeLarge, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.6),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.6),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red[300]!, width: 1.6),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixText: '${value.text.length}/200',
                          suffixStyle: TextStyle(
                            color: value.text.length > 200 ? Colors.red : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                          counterText: '', // Hide the default counter
                        ),
                      ),
                      if (value.text.length > 200)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Message exceeds 200 characters! Reduce package info.',
                            style: TextStyle(color: Colors.red, fontSize: AppTheme.fontSizeSmall),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            
            SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // Fixed Bottom Section
            Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(localizationService.translate('price'), style: TextStyle(fontSize: AppTheme.fontSizeLarge, fontWeight: FontWeight.w500, color: Colors.black)),
                            Text('${_totalPrice.toStringAsFixed(0)} ${localizationService.translate('manat')}', style: TextStyle(fontSize: AppTheme.fontSizePrice, fontWeight: FontWeight.w800, color: Colors.black)),
                            if (_selectedPickupLocation.isNotEmpty && _selectedDeliveryLocation.isNotEmpty) ...[
                              // SizedBox(height: 4),
                              // Text(
                              //   '${_cityLocations[_selectedPickupLocation.toLowerCase()] ?? _interCityLocations[_selectedPickupLocation.toLowerCase()] ?? 0} + ${_cityLocations[_selectedDeliveryLocation.toLowerCase()] ?? _interCityLocations[_selectedDeliveryLocation.toLowerCase()] ?? 0} manat',
                              //   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              // ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : () => _createDelivery(localizationService),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              ),
                              child: _isProcessing
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(localizationService.translate('loading'), style: TextStyle(color: Colors.white, fontSize: AppTheme.fontSizeLarge, fontWeight: FontWeight.w600)),
                                      ],
                                    )
                                  : Text(localizationService.translate('tassykla'), style: TextStyle(color: Colors.white, fontSize: AppTheme.fontSizeXLarge, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: AppBottomNavigation(currentIndex: 0),
      );
      },
    );
  }

  void _createDelivery(LocalizationService localizationService) async {
    print('Tassykla button clicked!'); // Debug log
    
    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showOfflineAlert();
      return; // Stop if offline
    }
    
    // Validate required fields
    if (!_validateRequiredFields(localizationService)) {
      return; // Stop if validation fails
    }
    
    // Set loading state
    setState(() {
      _isProcessing = true;
    });
    
    // Proceed with data submission
    await _proceedWithSubmission();
  }

  void _showOfflineAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.red[600],
                size: 24,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeXLarge,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Please check your internet connection and try again. You need to be online to submit delivery requests.',
            style: TextStyle(
              fontSize: AppTheme.fontSizeLarge,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _validateRequiredFields(LocalizationService localizationService) {
    List<String> errors = [];
    
    // Check pickup location
    if (_selectedPickupLocation.isEmpty) {
      errors.add(localizationService.translate('please_select_pickup'));
    }
    
    // Check delivery location
    if (_selectedDeliveryLocation.isEmpty) {
      errors.add(localizationService.translate('please_select_delivery'));
    }
    
    // Check sender name (minimum 2 characters)
    String senderName = _senderNameController.text.trim();
    if (senderName.isEmpty) {
      errors.add(localizationService.translate('please_enter_sender_name'));
    } else if (senderName.length < 2) {
      errors.add('Sender name must be at least 2 characters');
    }
    
    // Check sender phone (exactly 8 characters)
    String senderPhone = _senderPhoneController.text.trim();
    if (senderPhone.isEmpty) {
      errors.add(localizationService.translate('please_enter_phone'));
    } else if (senderPhone.length != 8) {
      errors.add(localizationService.translate('phone_8_digits'));
    }
    
    // Check recipient name (minimum 2 characters)
    String recipientName = _recipientNameController.text.trim();
    if (recipientName.isEmpty) {
      errors.add(localizationService.translate('please_enter_recipient_name'));
    } else if (recipientName.length < 2) {
      errors.add('Recipient name must be at least 2 characters');
    }
    
    // Check recipient phone (exactly 8 characters)
    String recipientPhone = _recipientPhoneController.text.trim();
    if (recipientPhone.isEmpty) {
      errors.add(localizationService.translate('please_enter_phone'));
    } else if (recipientPhone.length != 8) {
      errors.add(localizationService.translate('phone_8_digits'));
    }
    
    // Show errors if any
    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Red header with warning icon
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  // White body with content
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        ...errors.asMap().entries.map((entry) {
                          int index = entry.key;
                          String error = entry.value;
                          return Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  error,
                                  style: TextStyle(
                                    fontSize: AppTheme.fontSizeLarge,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              if (index < errors.length - 1) // Add separator except for last item
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  height: 1,
                                  color: Colors.grey[300],
                                ),
                            ],
                          );
                        }).toList(),
                        SizedBox(height: 20),
                        // Red close button
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Close',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppTheme.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return false;
    }
    
    return true;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                // Green success icon
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
                SizedBox(height: 14),
                // Success title
                Text(
                  'Successful!',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                // Success message
                Text(
                  'Your transaction was successful',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                // Transaction details
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // _buildDetailRow('Service Type:', _selectedServiceType == 'city' ? 'City' : 'Regional'),
                      // _buildDetailRow('Pickup Type:', _selectedPickupType == 'office' ? 'Office' : 'Address'),
                      _buildDetailRow('Pickup Location:', _selectedPickupLocation.isNotEmpty ? _selectedPickupLocation : 'Not specified'),
                      // _buildDetailRow('Delivery Type:', _selectedDeliveryType == 'office' ? 'Office' : 'Address'),
                      _buildDetailRow('Delivery Location:', _selectedDeliveryLocation.isNotEmpty ? _selectedDeliveryLocation : 'Not specified'),
                      _buildDetailRow('Sender Full Name:', _senderNameController.text.isNotEmpty ? _senderNameController.text : 'Not specified'),
                      _buildDetailRow('Sender Phone Number:', _senderPhoneController.text.isNotEmpty ? '+993${_senderPhoneController.text}' : 'Not specified'),
                      _buildDetailRow('Recipient Full Name:', _recipientNameController.text.isNotEmpty ? _recipientNameController.text : 'Not specified'),
                      _buildDetailRow('Recipient Phone Number:', _recipientPhoneController.text.isNotEmpty ? '+993${_recipientPhoneController.text}' : 'Not specified'),
                      _buildDetailRow('Package Info:', _descriptionController.text.isNotEmpty ? _descriptionController.text : 'Not specified'),
                      // _buildDetailRow('Total Order:', '$_totalPrice manat', isLast: true),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Green OK button
                Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/my-deliveries');
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTheme.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$label $value',
              style: TextStyle(
                fontSize: AppTheme.fontSizeSmall,
                color: Colors.black,
              ),
            ),
          ),
        ),
        if (!isLast) // Add separator except for last item
          Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            height: 1,
            color: Colors.grey[300],
          ),
      ],
    );
  }

  Future<void> _proceedWithSubmission() async {
    try {
      // Persist the order immediately
      _addDeliveryToOrders();
      
      // Send data to Google Sheets
      print('Sending to Google Sheets...');
      await _sendDeliveryToGoogleSheets();
      print('Google Sheets data sent successfully');
      
      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      print('Send error: $e');
      // Show error message if sending fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: ${e.toString()}')),
      );
      context.go('/my-deliveries');
    } finally {
      // Clear loading state
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _sendDeliveryToGoogleSheets() async {
    if (_sheetsWebhookUrl.isEmpty) {
      print('Sheets webhook URL is not configured. Skipping.');
      return;
    }

    // Get saved profile data
    final savedFullName = await _userService.getFullName();
    final savedPhoneNumber = await _userService.getPhoneNumber();

    // Retry mechanism
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        print('Attempt $attempt of 3...');
      final payload = {
        'createdAt': DateTime.now().toIso8601String(),
        'serviceType': _selectedServiceType,
        'pickupType': _selectedPickupType,
        'pickupLocation': _selectedPickupLocation,
        'deliveryType': _selectedDeliveryType,
        'deliveryLocation': _selectedDeliveryLocation,
        'senderName': _senderNameController.text,
        'senderPhone': '993${_senderPhoneController.text}',
        'recipientName': _recipientNameController.text,
        'recipientPhone': '993${_recipientPhoneController.text}',
        'packageInfo': _descriptionController.text,
        'price': _totalPrice,
        // Add profile data
        'userFullName': savedFullName ?? '',
        'userPhoneNumber': savedPhoneNumber != null ? '993$savedPhoneNumber' : '',
      };

      print('Attempting to connect to: $_sheetsWebhookUrl');
      print('Payload: ${_encodeJson(payload)}');

      final response = await http.post(
        Uri.parse(_sheetsWebhookUrl),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'TizGo/1.0',
        },
        body: _encodeJson(payload),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('Request timed out after 30 seconds');
          throw Exception('Request timeout');
        },
      );

      print('Sending data to Google Sheets:');
      print('Payload: ${_encodeJson(payload)}');
      print('Sheets response status: ${response.statusCode}');
      print('Sheets response body: ${response.body}');
      
        if (response.statusCode == 200) {
          print('Google Sheets data sent successfully on attempt $attempt');
          return; // Success, exit the retry loop
        } else {
          print('Google Sheets request failed with status: ${response.statusCode} on attempt $attempt');
          if (attempt == 3) {
            print('All 3 attempts failed');
            return;
          }
        }
      } catch (e) {
        print('Failed to send data to Google Sheets on attempt $attempt: $e');
        print('Error type: ${e.runtimeType}');
        if (e.toString().contains('Failed to fetch')) {
          print('Network connectivity issue - check internet connection and Google Apps Script URL');
        } else if (e.toString().contains('timeout')) {
          print('Request timed out - Google Apps Script might be slow to respond');
        } else {
          print('Unknown error occurred');
        }
        
        if (attempt == 3) {
          print('All 3 attempts failed');
          return;
        }
        
        // Wait before retrying
        await Future.delayed(Duration(seconds: 2));
      }
    }
  }

  String _encodeJson(Map<String, dynamic> data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }



  void _addDeliveryToOrders() {
    final newDelivery = Delivery(
      id: _deliveryService.getNextId(),
      pickupAddress: _pickupAddressController.text.isNotEmpty 
          ? _pickupAddressController.text 
          : _selectedPickupLocation,
      deliveryAddress: _deliveryAddressController.text.isNotEmpty 
          ? _deliveryAddressController.text 
          : _selectedDeliveryLocation,
      status: 'Pending',
      recipient: Recipient(
        fullName: _recipientNameController.text,
        phoneNumber: '+993${_recipientPhoneController.text}',
      ),
      sender: Sender(
        fullName: _senderNameController.text,
        phoneNumber: '+993${_senderPhoneController.text}',
      ),
      createdAt: DateTime.now().toString().split('.')[0].replaceAll('T', ' '), // Full timestamp with hour and minute
      price: _totalPrice.toDouble(),
      serviceType: _selectedServiceType,
      pickupType: _selectedPickupType,
      deliveryType: _selectedDeliveryType,
      pickupLocation: _selectedPickupLocation,
      deliveryLocation: _selectedDeliveryLocation,
      packageDescription: _descriptionController.text.isNotEmpty 
          ? _descriptionController.text 
          : null,
    );

    _deliveryService.addAndPersistDelivery(newDelivery);
  }

  void _showPickupOptionsDialog({required LocalizationService localizationService}) {
    // Clear any focused text fields to prevent auto-focusing after closing the sheet
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Title
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Text(
                        localizationService.translate('how_do_we_collect'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeXLarge,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    
                    // Options
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Easybox option
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                _selectedPickupType = 'office';
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedPickupType == 'office' ? AppTheme.primaryColor : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                    // Radio button
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _selectedPickupType == 'office' ? AppTheme.primaryColor : Colors.transparent,
                                        border: Border.all(
                                          color: _selectedPickupType == 'office' ? AppTheme.primaryColor : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: _selectedPickupType == 'office'
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                    
                                    SizedBox(width: 16),
                                    
                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localizationService.translate('drop_off_easybox'),
                                            style: TextStyle(
                                              fontSize: AppTheme.fontSizeLarge,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            localizationService.translate('load_parcel_locker'),
                                            style: TextStyle(
                                              fontSize: AppTheme.fontSizeMedium,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    SizedBox(width: 16),
                                    
                                    // Icon
                                    Icon(
                                      Icons.grid_view,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                  ],
                                ),
                            ),
                          ),
                          
                          SizedBox(height: 8),
                          
                          // Address option
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  _selectedPickupType = 'address';
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedPickupType == 'address' ? AppTheme.primaryColor : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Radio button
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _selectedPickupType == 'address' ? AppTheme.primaryColor : Colors.transparent,
                                        border: Border.all(
                                          color: _selectedPickupType == 'address' ? AppTheme.primaryColor : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: _selectedPickupType == 'address'
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                    
                                    SizedBox(width: 16),
                                    
                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localizationService.translate('pickup_from_address'),
                                            style: TextStyle(
                                              fontSize: AppTheme.fontSizeLarge,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            localizationService.translate('courier_collect_address'),
                                            style: TextStyle(
                                              fontSize: AppTheme.fontSizeMedium,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    SizedBox(width: 16),
                                    
                                    // Icon
                                    Icon(
                                      Icons.home,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                    
                    // Confirm button
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _selectedPickupType.isNotEmpty
                              ? () {
                                  Navigator.of(context).pop();
                                  _showLocationDialog(localizationService: localizationService);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: Text(
                            localizationService.translate('continue'),
                            style: TextStyle(color: Colors.white, fontSize: AppTheme.fontSizeLarge, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLocationDialog({bool isPickup = true, required LocalizationService localizationService}) {
    List<Map<String, String>> locations = [];
    
    if (_selectedServiceType == 'city') {
      // City service: only city locations
      locations = cityLocations.map((location) => {
        'name': location['name']!,
        'address': location['description']!,
        'price': location['price']!,
      }).toList();
    } else {
      // Inter-city service: show all locations (city + inter-city)
      locations = [
        ...cityLocations.map((location) => {
          'name': location['name']!,
          'address': location['description']!,
          'price': location['price']!,
        }),
        ...interCityLocations.map((location) => {
          'name': location['name']!,
          'address': location['description']!,
          'price': location['price']!,
        }),
      ];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int selectedIndex = -1;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(child: Column(
                children: [
                  SizedBox(height: 24),
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[700]),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              isPickup ? localizationService.translate('select_pickup_location') : localizationService.translate('select_delivery_location'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  
                  // List
                  Expanded(
                    child: ListView.separated(
                      itemCount: locations.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[300]),
                      itemBuilder: (context, index) {
                        final location = locations[index];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          leading: Radio<int>(
                            value: index,
                            groupValue: selectedIndex,
                            onChanged: (val) => setModalState(() => selectedIndex = val ?? -1),
                            activeColor: AppTheme.primaryColor,
                          ),
                          title: Text(
                            location['name']!,
                            style: TextStyle(fontSize: AppTheme.fontSizeLarge, color: Colors.grey[800], fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            location['address'] ?? '',
                            style: TextStyle(fontSize: AppTheme.fontSizeSmall, color: Colors.grey[600]),
                          ),
                          onTap: () => setModalState(() => selectedIndex = index),
                        );
                      },
                    ),
                  ),

                  // Confirm button
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: selectedIndex < 0
                            ? null
                            : () {
                                setState(() {
                                  if (isPickup) {
                                    _selectedPickupLocation = locations[selectedIndex]['name']!;
                                    // Reset delivery location if service type is inter-city
                                    if (_selectedServiceType == 'region') {
                                      _selectedDeliveryLocation = '';
                                    }
                                  } else {
                                    _selectedDeliveryLocation = locations[selectedIndex]['name']!;
                                  }
                                  // Leave selection state unchanged; do not auto-open delivery
                                });
                                Navigator.of(context).pop();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Text(localizationService.translate('tassykla'), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              )),
            );
          },
        );
      },
    );
  }

  void _showDeliveryOptionsDialog({required LocalizationService localizationService}) {
    // Clear any focused text fields to prevent auto-focusing after closing the sheet
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Title
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Text(
                        localizationService.translate('where_do_we_deliver'),
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeXLarge,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    
                    // Options
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Easybox option
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                _selectedDeliveryType = 'office';
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedDeliveryType == 'office' ? AppTheme.primaryColor : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                    // Radio button
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _selectedDeliveryType == 'office' ? AppTheme.primaryColor : Colors.transparent,
                                        border: Border.all(
                                          color: _selectedDeliveryType == 'office' ? AppTheme.primaryColor : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: _selectedDeliveryType == 'office'
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                    
                                    SizedBox(width: 16),
                                    
                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localizationService.translate('delivery_to_easybox'),
                                            style: TextStyle(
                                              fontSize: AppTheme.fontSizeLarge,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            localizationService.translate('parcel_handover_easybox'),
                                            style: TextStyle(
                                              fontSize: AppTheme.fontSizeMedium,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    SizedBox(width: 16),
                                    
                                    // Icon
                                    Icon(
                                      Icons.grid_view,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 8),
                            
                            // Address option
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  _selectedDeliveryType = 'address';
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedDeliveryType == 'address' ? AppTheme.primaryColor : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Radio button
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _selectedDeliveryType == 'address' ? AppTheme.primaryColor : Colors.transparent,
                                        border: Border.all(
                                          color: _selectedDeliveryType == 'address' ? AppTheme.primaryColor : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: _selectedDeliveryType == 'address'
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                    
                                    SizedBox(width: 16),
                                    
                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localizationService.translate('delivery_to_address'),
                                            style: TextStyle(
                                              fontSize: AppTheme.fontSizeLarge,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            localizationService.translate('courier_deliver_address'),
                                            style: TextStyle(
                                              fontSize: AppTheme.fontSizeMedium,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    SizedBox(width: 16),
                                    
                                    // Icon
                                    Icon(
                                      Icons.home,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                    
                    // Confirm button
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _selectedDeliveryType.isNotEmpty
                              ? () {
                                  Navigator.of(context).pop();
                                  _showDeliveryLocationDialog(localizationService: localizationService);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: Text(
                            localizationService.translate('continue'),
                            style: TextStyle(color: Colors.white, fontSize: AppTheme.fontSizeLarge, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeliveryLocationDialog({required LocalizationService localizationService}) {
    List<Map<String, String>> locations = [];
    
    if (_selectedServiceType == 'city') {
      // City service: only city locations
      locations = cityLocations.map((location) => {
        'name': location['name']!,
        'address': location['description']!,
        'price': location['price']!,
      }).toList();
    } else {
      // Inter-city service: show opposite locations
      final pickupKey = _getLocationKey(_selectedPickupLocation);
      final pickupType = _locations[pickupKey]?['type'];
      
      if (pickupType == 'city') {
        // If pickup is from city, show inter-city locations
        locations = interCityLocations.map((location) => {
          'name': location['name']!,
          'address': location['description']!,
          'price': location['price']!,
        }).toList();
      } else {
        // If pickup is from inter-city, show city locations
        locations = cityLocations.map((location) => {
          'name': location['name']!,
          'address': location['description']!,
          'price': location['price']!,
        }).toList();
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int selectedIndex = -1;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(child: Column(
                children: [             
                 SizedBox(height: 16),
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[700]),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              _selectedDeliveryType == 'office' ? 'Select Office' : 'Select Address',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  
                  // List
                  Expanded(
                    child: ListView.separated(
                      itemCount: locations.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[300]),
                      itemBuilder: (context, index) {
                        final location = locations[index];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          leading: Radio<int>(
                            value: index,
                            groupValue: selectedIndex,
                            onChanged: (val) => setModalState(() => selectedIndex = val ?? -1),
                            activeColor: AppTheme.primaryColor,
                          ),
                          title: Text(
                            location['name']!,
                            style: TextStyle(fontSize: AppTheme.fontSizeLarge, color: Colors.grey[800], fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            location['address'] ?? '',
                            style: TextStyle(fontSize: AppTheme.fontSizeSmall, color: Colors.grey[600]),
                          ),
                          onTap: () => setModalState(() => selectedIndex = index),
                        );
                      },
                    ),
                  ),

                  // Confirm button
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: selectedIndex < 0
                            ? null
                            : () {
                                setState(() {
                                  _selectedDeliveryLocation = locations[selectedIndex]['name']!;
                                });
                                Navigator.of(context).pop();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Text(localizationService.translate('tassykla'), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              )),
            );
          },
        );
      },
    );
  }
}