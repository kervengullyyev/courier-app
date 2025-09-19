// ============================================================================
// HOME SCREEN - CREATE DELIVERY
// ============================================================================
// This is the main screen where users create new delivery orders.
// Features: Service type selection, location selection, form validation
// Navigation: Bottom nav tab 0 (Home)
// ============================================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../theme/app_theme.dart';
import '../../models/delivery.dart';
import '../../services/delivery_service.dart';

class CreateDeliveryScreen extends StatefulWidget {
  final String loggedInPhone;
  
  const CreateDeliveryScreen({Key? key, this.loggedInPhone = ''}) : super(key: key);

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
  final Connectivity _connectivity = Connectivity();
  final DeliveryService _deliveryService = DeliveryService();
  
  String _selectedServiceType = 'city'; // 'city' or 'region'
  String _selectedPickupType = 'easybox'; // 'easybox' or 'address'
  String _selectedPickupLocation = ''; // Selected location name
  String _selectedDeliveryType = 'easybox'; // 'easybox' or 'address'
  String _selectedDeliveryLocation = ''; // Selected delivery location name
  bool _isPickupSelected = false; // Track if pickup button is clicked
  bool _isDeliverySelected = false; // Track if delivery button is clicked
  bool _isOnline = false; // Track online/offline status based on connectivity
  int _totalMessageCharCount = 0; // Track total message character count
  static const int _maxMessageLength = 144; // Maximum SMS message length
  int get _totalPrice => _selectedServiceType == 'city' ? 15 : 35;
  static const String _sheetsWebhookUrl = String.fromEnvironment(
    'SHEETS_WEBHOOK_URL',
    defaultValue: 'https://script.google.com/macros/s/AKfycbz34fy01-A18cTsuZuCJGLANX_iLahIATPXfObe4_0lH9iFq-lvtvK3WpFH_DVD-PSO/exec',
  );

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectivityStatus);
    _descriptionController.addListener(_updateTotalMessageCharCount);
    _senderNameController.addListener(_updateTotalMessageCharCount);
    _senderPhoneController.addListener(_updateTotalMessageCharCount);
    _recipientNameController.addListener(_updateTotalMessageCharCount);
    _recipientPhoneController.addListener(_updateTotalMessageCharCount);
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

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(connectivityResult);
    } catch (e) {
      print('Connectivity check error: $e');
      setState(() {
        _isOnline = false;
      });
    }
  }

  void _updateConnectivityStatus(ConnectivityResult connectivityResult) {
    setState(() {
      _isOnline = connectivityResult == ConnectivityResult.mobile ||
                  connectivityResult == ConnectivityResult.wifi ||
                  connectivityResult == ConnectivityResult.ethernet;
    });
  }

  void _updateTotalMessageCharCount() {
    setState(() {
      _totalMessageCharCount = _getTotalMessageLength();
    });
  }

  int _getTotalMessageLength() {
    String message = _createDeliveryMessage();
    return message.length;
  }

  bool _isMessageTooLong() {
    return _getTotalMessageLength() > _maxMessageLength;
  }

  int _getMaxPackageInfoLength() {
    // Calculate the base message length without package info
    int baseMessageLength = _getBaseMessageLength();
    int remainingChars = _maxMessageLength - baseMessageLength;
    return remainingChars > 0 ? remainingChars : 0;
  }

  int _getBaseMessageLength() {
    // Service type: 1 for city, 2 for inter city
    String serviceCode = _selectedServiceType == 'city' ? '1' : '2';
    
    // Pickup: 1 for easybox, 2 for address + location without vowels
    String pickupCode = _selectedPickupType == 'easybox' ? '1' : '2';
    String pickupLocation = _selectedPickupLocation.isNotEmpty ? _removeVowels(_selectedPickupLocation) : '';
    String pickupInfo = pickupLocation.isNotEmpty ? '$pickupCode-$pickupLocation' : '$pickupCode-';
    
    // Delivery: 1 for easybox, 2 for address + location without vowels
    String deliveryCode = _selectedDeliveryType == 'easybox' ? '1' : '2';
    String deliveryLocation = _selectedDeliveryLocation.isNotEmpty ? _removeVowels(_selectedDeliveryLocation) : '';
    String deliveryInfo = deliveryLocation.isNotEmpty ? '$deliveryCode-$deliveryLocation' : '$deliveryCode-';
    
    // Sender info
    String senderName = _senderNameController.text.isNotEmpty ? _senderNameController.text : '';
    String senderPhone = _senderPhoneController.text.isNotEmpty ? _senderPhoneController.text : '';
    String senderInfo = senderName.isNotEmpty && senderPhone.isNotEmpty ? '$senderName/$senderPhone' : '';
    
    // Recipient info
    String recipientName = _recipientNameController.text.isNotEmpty ? _recipientNameController.text : '';
    String recipientPhone = _recipientPhoneController.text.isNotEmpty ? _recipientPhoneController.text : '';
    String recipientInfo = recipientName.isNotEmpty && recipientPhone.isNotEmpty ? '$recipientName/$recipientPhone' : '';
    
    // Price
    String price = '$_totalPrice man';
    
    String baseMessage = '''$serviceCode
$pickupInfo
$deliveryInfo
$senderInfo
$recipientInfo

$price''';
    
    return baseMessage.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Text('Courier Service', style: AppTheme.headerStyle),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _isOnline ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
        leading: const Icon(Icons.local_shipping, color: Colors.blue, size: 28),
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
                  'Delivery Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
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
                      onTap: () => setState(() => _selectedServiceType = 'city'),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedServiceType == 'city' ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedServiceType == 'city' ? Colors.blue : Colors.grey[300]!,
                            width: 1.6,
                          ),
                        ),
                        child: Text(
                          'City',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
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
                      onTap: () => setState(() => _selectedServiceType = 'region'),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedServiceType == 'region' ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedServiceType == 'region' ? Colors.blue : Colors.grey[300]!,
                            width: 1.6,
                          ),
                        ),
                        child: Text(
                          'Inter-City',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
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
                  'Pickup & Delivery Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
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
                        _showPickupOptionsDialog();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _selectedPickupLocation.isNotEmpty ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (_isPickupSelected || _selectedPickupLocation.isNotEmpty) ? Colors.blue : Colors.grey[300]!,
                            width: 1.6,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedPickupType == 'easybox' ? Icons.grid_view : Icons.home,
                              size: 16,
                              color: _selectedPickupLocation.isNotEmpty ? Colors.white : Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _selectedPickupLocation.isNotEmpty 
                                    ? _selectedPickupLocation
                                    : 'Select',
                                style: TextStyle(
                                  fontSize: 16,
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
                      onTap: () {
                        setState(() {
                          _isDeliverySelected = true;
                          _isPickupSelected = false;
                        });
                        _showDeliveryOptionsDialog();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _selectedDeliveryLocation.isNotEmpty ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (_isDeliverySelected || _selectedDeliveryLocation.isNotEmpty) ? Colors.blue : Colors.grey[300]!,
                            width: 1.6,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedDeliveryType == 'easybox' ? Icons.grid_view : Icons.home,
                              size: 16,
                              color: _selectedDeliveryLocation.isNotEmpty ? Colors.white : Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _selectedDeliveryLocation.isNotEmpty 
                                    ? _selectedDeliveryLocation
                                    : 'Select',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedDeliveryLocation.isNotEmpty ? Colors.white : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_selectedDeliveryLocation.isEmpty) ...[
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
                  'Sender Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
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
                      hintText: 'Sender Full Name',
                      hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 1.6),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      counterText: '', // Hide the default counter
                    ),
                  ),
                  SizedBox(height: 16),
                  // Sender Phone
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 48,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!, width: 1.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '+993',
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _senderPhoneController,
                          keyboardType: TextInputType.number,
                          maxLength: 8,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: 'Sender Phone Number',
                            hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.6),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue, width: 1.6),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            counterText: '', // Hide the default counter
                          ),
                        ),
                      ),
                    ],
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
                  'Recipient Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
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
                      hintText: 'Recipient Full Name',
                      hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 1.6),
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
                  
                  SizedBox(height: 16),
                  
                  // Phone Number
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 48,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!, width: 1.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '+993',
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _recipientPhoneController,
                          keyboardType: TextInputType.number,
                          maxLength: 8,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: 'Recipient Phone Number',
                            hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.6),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue, width: 1.6),
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
                      ),
                    ],
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
                  'Package Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    maxLength: _getMaxPackageInfoLength(),
                    enabled: !_isMessageTooLong(),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Package Information',
                      hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 1.6),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red[300]!, width: 1.6),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixText: '${_totalMessageCharCount}/$_maxMessageLength',
                      suffixStyle: TextStyle(
                        color: _isMessageTooLong() ? Colors.red : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      counterText: '', // Hide the default counter
                    ),
                  ),
                  if (_isMessageTooLong())
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Message exceeds $_maxMessageLength characters! Reduce package info.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
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
                            Text('Total order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
                            Text('${_totalPrice.toStringAsFixed(0)} manat', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black)),
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
                              onPressed: _createDelivery,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              ),
                              child: Text('Tassykla', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
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
      bottomNavigationBar: AppBottomNavigation(currentIndex: 0, loggedInPhone: widget.loggedInPhone),
    );
  }

  void _createDelivery() async {
    print('Tassykla button clicked!'); // Debug log
    
    // Validate required fields
    if (!_validateRequiredFields()) {
      return; // Stop if validation fails
    }
    
    // Check message length before sending
    String message = _createDeliveryMessage();
    int messageLength = message.length;
    print('Message length: $messageLength characters'); // Debug log
    
    if (messageLength > _maxMessageLength) {
      // Show alert for long message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Long Message Warning'),
            content: Text('Your message is $messageLength characters long (exceeds $_maxMessageLength characters). This will be sent as multiple SMS messages. Continue?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _proceedWithSMS();
                },
                child: Text('Continue'),
              ),
            ],
          );
        },
      );
    } else {
      // Message is short enough, proceed directly
      await _proceedWithSMS();
      _sendDeliveryToGoogleSheets();
    }
  }

  bool _validateRequiredFields() {
    List<String> errors = [];
    
    // Check pickup location
    if (_selectedPickupLocation.isEmpty) {
      errors.add('Please select a pickup location');
    }
    
    // Check delivery location
    if (_selectedDeliveryLocation.isEmpty) {
      errors.add('Please select a delivery location');
    }
    
    // Check sender name (minimum 2 characters)
    String senderName = _senderNameController.text.trim();
    if (senderName.isEmpty) {
      errors.add('Please enter sender full name');
    } else if (senderName.length < 2) {
      errors.add('Sender name must be at least 2 characters');
    }
    
    // Check sender phone (exactly 8 characters)
    String senderPhone = _senderPhoneController.text.trim();
    if (senderPhone.isEmpty) {
      errors.add('Please enter sender phone number');
    } else if (senderPhone.length != 8) {
      errors.add('Sender phone number must be exactly 8 characters');
    }
    
    // Check recipient name (minimum 2 characters)
    String recipientName = _recipientNameController.text.trim();
    if (recipientName.isEmpty) {
      errors.add('Please enter recipient full name');
    } else if (recipientName.length < 2) {
      errors.add('Recipient name must be at least 2 characters');
    }
    
    // Check recipient phone (exactly 8 characters)
    String recipientPhone = _recipientPhoneController.text.trim();
    if (recipientPhone.isEmpty) {
      errors.add('Please enter recipient phone number');
    } else if (recipientPhone.length != 8) {
      errors.add('Recipient phone number must be exactly 8 characters');
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
                                    fontSize: 16,
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
                                fontSize: 16,
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                // Success message
                Text(
                  'Your transaction was successful',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                // Transaction details
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Service Type:', _selectedServiceType == 'city' ? 'City' : 'Regional'),
                      _buildDetailRow('Pickup Type:', _selectedPickupType == 'easybox' ? 'EasyBox' : 'Address'),
                      _buildDetailRow('Pickup Location:', _selectedPickupLocation.isNotEmpty ? _selectedPickupLocation : 'Not specified'),
                      _buildDetailRow('Delivery Type:', _selectedDeliveryType == 'easybox' ? 'EasyBox' : 'Address'),
                      _buildDetailRow('Delivery Location:', _selectedDeliveryLocation.isNotEmpty ? _selectedDeliveryLocation : 'Not specified'),
                      _buildDetailRow('Sender Full Name:', _senderNameController.text.isNotEmpty ? _senderNameController.text : 'Not specified'),
                      _buildDetailRow('Sender Phone Number:', _senderPhoneController.text.isNotEmpty ? '+993${_senderPhoneController.text}' : 'Not specified'),
                      _buildDetailRow('Recipient Full Name:', _recipientNameController.text.isNotEmpty ? _recipientNameController.text : 'Not specified'),
                      _buildDetailRow('Recipient Phone Number:', _recipientPhoneController.text.isNotEmpty ? '+993${_recipientPhoneController.text}' : 'Not specified'),
                      _buildDetailRow('Package Info:', _descriptionController.text.isNotEmpty ? _descriptionController.text : 'Not specified'),
                      _buildDetailRow('Total Order:', '$_totalPrice manat', isLast: true),
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
                        _addDeliveryToOrders();
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                fontSize: 14,
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

  Future<void> _proceedWithSMS() async {
    try {
      // Send SMS to the specified phone number immediately
      print('Attempting to send SMS...'); // Debug log
      await _sendSMS();
      print('SMS sent successfully'); // Debug log
      
      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      print('SMS error: $e'); // Debug log
      // Show error message if SMS fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SMS failed: ${e.toString()}')),
      );
      context.go('/my-deliveries');
    }
  }

  Future<void> _sendDeliveryToGoogleSheets() async {
    if (_sheetsWebhookUrl.isEmpty) {
      print('Sheets webhook URL is not configured. Skipping.');
      return;
    }

    try {
      final payload = {
        'createdAt': DateTime.now().toIso8601String(),
        'serviceType': _selectedServiceType,
        'pickupType': _selectedPickupType,
        'pickupLocation': _selectedPickupLocation,
        'deliveryType': _selectedDeliveryType,
        'deliveryLocation': _selectedDeliveryLocation,
        'senderName': _senderNameController.text,
        'senderPhone': _senderPhoneController.text,
        'recipientName': _recipientNameController.text,
        'recipientPhone': _recipientPhoneController.text,
        'packageInfo': _descriptionController.text,
        'price': _totalPrice,
      };

      final response = await http.post(
        Uri.parse(_sheetsWebhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: _encodeJson(payload),
      );

      print('Sheets response status: ${response.statusCode}');
    } catch (e) {
      print('Failed to send data to Google Sheets: $e');
    }
  }

  String _encodeJson(Map<String, dynamic> data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> _sendSMS() async {
    try {
      print('Starting background SMS sending...'); // Debug log
      
      // Create detailed delivery message
      String message = _createDeliveryMessage();
      String recipient = '+40741302753';
      
      print('Sending SMS to $recipient with message: $message'); // Debug log
      
      // Use platform channel to send SMS directly
      const platform = MethodChannel('com.example.courier_app/sms');
      
      final String result = await platform.invokeMethod('sendSMS', {
        'phoneNumber': recipient,
        'message': message,
        'useDivideMessage': true,
      });
      
      print('SMS result: $result'); // Debug log
      print('SMS sent successfully in background!'); // Debug log
    } catch (e) {
      print('Background SMS error: $e'); // Debug log
      throw Exception('Failed to send SMS in background: $e');
    }
  }

  String _createDeliveryMessage() {
    // Service type: 1 for city, 2 for inter city
    String serviceCode = _selectedServiceType == 'city' ? '1' : '2';
    
    // Pickup: 1 for easybox, 2 for address + location without vowels
    String pickupCode = _selectedPickupType == 'easybox' ? '1' : '2';
    String pickupLocation = _selectedPickupLocation.isNotEmpty ? _removeVowels(_selectedPickupLocation) : '';
    String pickupInfo = pickupLocation.isNotEmpty ? '$pickupCode-$pickupLocation' : '$pickupCode-';
    
    // Delivery: 1 for easybox, 2 for address + location without vowels
    String deliveryCode = _selectedDeliveryType == 'easybox' ? '1' : '2';
    String deliveryLocation = _selectedDeliveryLocation.isNotEmpty ? _removeVowels(_selectedDeliveryLocation) : '';
    String deliveryInfo = deliveryLocation.isNotEmpty ? '$deliveryCode-$deliveryLocation' : '$deliveryCode-';
    
    // Sender info
    String senderName = _senderNameController.text.isNotEmpty ? _senderNameController.text : '';
    String senderPhone = _senderPhoneController.text.isNotEmpty ? _senderPhoneController.text : '';
    String senderInfo = senderName.isNotEmpty && senderPhone.isNotEmpty ? '$senderName/$senderPhone' : '';
    
    // Recipient info
    String recipientName = _recipientNameController.text.isNotEmpty ? _recipientNameController.text : '';
    String recipientPhone = _recipientPhoneController.text.isNotEmpty ? _recipientPhoneController.text : '';
    String recipientInfo = recipientName.isNotEmpty && recipientPhone.isNotEmpty ? '$recipientName/$recipientPhone' : '';
    
    // Package info
    String packageInfo = _descriptionController.text.isNotEmpty ? _descriptionController.text : '';
    
    // Price
    String price = '$_totalPrice man';
    
    String message = '''$serviceCode
$pickupInfo
$deliveryInfo
$senderInfo
$recipientInfo
$packageInfo
$price''';
    
    print('Complete SMS message: $message'); // Debug log
    return message.trim();
  }

  String _removeVowels(String text) {
    if (text.isEmpty) return '';
    return text.replaceAll(RegExp(r'[aeiouAEIOU]'), '').toUpperCase();
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
      courier: null,
      recipient: Recipient(
        fullName: _recipientNameController.text,
        phoneNumber: '+993${_recipientPhoneController.text}',
      ),
      sender: Sender(
        fullName: _senderNameController.text,
        phoneNumber: '+993${_senderPhoneController.text}',
      ),
      createdAt: DateTime.now().toString().split(' ')[0], // Today's date
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

    _deliveryService.addDelivery(newDelivery);
  }

  void _showPickupOptionsDialog() {
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
                        'How do we collect the parcel from you?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
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
                                _selectedPickupType = 'easybox';
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedPickupType == 'easybox' ? Colors.blue : Colors.grey[300]!,
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
                                        color: _selectedPickupType == 'easybox' ? Colors.blue : Colors.transparent,
                                        border: Border.all(
                                          color: _selectedPickupType == 'easybox' ? Colors.blue : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: _selectedPickupType == 'easybox'
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
                                            'Drop-off at easybox',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Load your parcel at any locker near you',
                                            style: TextStyle(
                                              fontSize: 14,
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
                                      color: Colors.blue,
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
                                    color: _selectedPickupType == 'address' ? Colors.blue : Colors.grey[300]!,
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
                                        color: _selectedPickupType == 'address' ? Colors.blue : Colors.transparent,
                                        border: Border.all(
                                          color: _selectedPickupType == 'address' ? Colors.blue : Colors.grey[400]!,
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
                                            'Pick-up from address',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'The courier will collect the parcel from your address',
                                            style: TextStyle(
                                              fontSize: 14,
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
                                      color: Colors.blue,
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
                                  _showLocationDialog();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: Text(
                            'Continue',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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

  void _showLocationDialog() {
    final List<Map<String, String>> locations = _selectedPickupType == 'easybox'
        ? [
            {'name': 'Ashgabat Center', 'address': 'Magtymguly Ave, 123'},
            {'name': 'Berkarar Mall', 'address': 'Gorogly St, 45'},
            {'name': 'Alem Shopping Center', 'address': 'Bitarap Turkmenistan Ave, 67'},
            {'name': 'Yimpas Shopping Center', 'address': 'Gurbansoltan Eje Ave, 89'},
            {'name': 'Teke Bazaar', 'address': 'Teke Bazaar, Block 12'},
          ]
        : [
            {'name': 'Ashgabat City Center', 'address': 'Magtymguly Ave, 123'},
            {'name': 'Berkarar District', 'address': 'Gorogly St, 45'},
            {'name': 'Alem District', 'address': 'Bitarap Turkmenistan Ave, 67'},
            {'name': 'Yimpas District', 'address': 'Gurbansoltan Eje Ave, 89'},
            {'name': 'Teke Bazaar Area', 'address': 'Teke Bazaar, Block 12'},
          ];

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
                              _selectedPickupType == 'easybox' ? 'Select Easybox' : 'Select Address',
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
                            activeColor: Colors.blue,
                          ),
                          title: Text(
                            location['name']!,
                            style: TextStyle(fontSize: 16, color: Colors.grey[800], fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            location['address'] ?? '',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
                                  _selectedPickupLocation = locations[selectedIndex]['name']!;
                                  // Leave selection state unchanged; do not auto-open delivery
                                });
                                Navigator.of(context).pop();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Text('Tassyklа', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
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

  void _showDeliveryOptionsDialog() {
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
                        'Where do we deliver the parcel?',
                        style: TextStyle(
                          fontSize: 18,
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
                                _selectedDeliveryType = 'easybox';
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedDeliveryType == 'easybox' ? Colors.blue : Colors.grey[300]!,
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
                                        color: _selectedDeliveryType == 'easybox' ? Colors.blue : Colors.transparent,
                                        border: Border.all(
                                          color: _selectedDeliveryType == 'easybox' ? Colors.blue : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: _selectedDeliveryType == 'easybox'
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
                                            'Delivery to easybox',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Parcel handover to courier and delivery to any easybox in the country',
                                            style: TextStyle(
                                              fontSize: 14,
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
                                      color: Colors.blue,
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
                                    color: _selectedDeliveryType == 'address' ? Colors.blue : Colors.grey[300]!,
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
                                        color: _selectedDeliveryType == 'address' ? Colors.blue : Colors.transparent,
                                        border: Border.all(
                                          color: _selectedDeliveryType == 'address' ? Colors.blue : Colors.grey[400]!,
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
                                            'Delivery to address',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Parcel handover to courier and delivery to address',
                                            style: TextStyle(
                                              fontSize: 14,
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
                                      color: Colors.blue,
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
                                  _showDeliveryLocationDialog();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: Text(
                            'Continue',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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

  void _showDeliveryLocationDialog() {
    final List<Map<String, String>> locations = _selectedDeliveryType == 'easybox'
        ? [
            {'name': 'Ashgabat Center', 'address': 'Magtymguly Ave, 123'},
            {'name': 'Berkarar Mall', 'address': 'Gorogly St, 45'},
            {'name': 'Alem Shopping Center', 'address': 'Bitarap Turkmenistan Ave, 67'},
            {'name': 'Yimpas Shopping Center', 'address': 'Gurbansoltan Eje Ave, 89'},
            {'name': 'Teke Bazaar', 'address': 'Teke Bazaar, Block 12'},
          ]
        : [
            {'name': 'Ashgabat City Center', 'address': 'Magtymguly Ave, 123'},
            {'name': 'Berkarar District', 'address': 'Gorogly St, 45'},
            {'name': 'Alem District', 'address': 'Bitarap Turkmenistan Ave, 67'},
            {'name': 'Yimpas District', 'address': 'Gurbansoltan Eje Ave, 89'},
            {'name': 'Teke Bazaar Area', 'address': 'Teke Bazaar, Block 12'},
          ];

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
                              _selectedDeliveryType == 'easybox' ? 'Select Easybox' : 'Select Address',
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
                            activeColor: Colors.blue,
                          ),
                          title: Text(
                            location['name']!,
                            style: TextStyle(fontSize: 16, color: Colors.grey[800], fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            location['address'] ?? '',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Text('Tassyklа', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
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