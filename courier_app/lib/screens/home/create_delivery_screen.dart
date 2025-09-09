// ============================================================================
// HOME SCREEN - CREATE DELIVERY
// ============================================================================
// This is the main screen where users create new delivery orders.
// Features: Service type selection, location selection, form validation
// Navigation: Bottom nav tab 0 (Home)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../theme/app_theme.dart';

class CreateDeliveryScreen extends StatefulWidget {
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
  final FocusNode _senderNameFocus = FocusNode();
  
  String _selectedServiceType = 'city'; // 'city' or 'region'
  String _selectedPickupType = 'easybox'; // 'easybox' or 'address'
  String _selectedPickupLocation = ''; // Selected location name
  String _selectedDeliveryType = 'easybox'; // 'easybox' or 'address'
  String _selectedDeliveryLocation = ''; // Selected delivery location name
  bool _isPickupSelected = false; // Track if pickup button is clicked
  bool _isDeliverySelected = false; // Track if delivery button is clicked
  double get _totalPrice => _selectedServiceType == 'city' ? 15.0 : 35.0;

  @override
  void dispose() {
    _pickupAddressController.dispose();
    _deliveryAddressController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _descriptionController.dispose();
    _senderNameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Courier Service', style: AppTheme.headerStyle),
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
                            width: 2,
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
                            width: 2,
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
                            width: 2,
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
                            width: 2,
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
                    focusNode: _senderNameFocus,
                    decoration: InputDecoration(
                      hintText: 'Sender Full Name',
                      hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          border: Border.all(color: Colors.grey[300]!, width: 2),
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
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Sender Phone Number',
                            hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    decoration: InputDecoration(
                      hintText: 'Recipient Full Name',
                      hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          border: Border.all(color: Colors.grey[300]!, width: 2),
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
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Recipient Phone Number',
                            hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    decoration: InputDecoration(
                      hintText: 'Package Information',
                      hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }

  void _createDelivery() async {
    if (_formKey.currentState!.validate()) {
      // Simulate delivery creation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delivery created successfully')),
      );
      context.go('/my-deliveries');
    }
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