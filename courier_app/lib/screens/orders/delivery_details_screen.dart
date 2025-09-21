// ============================================================================
// DELIVERY DETAILS SCREEN - DETAILED VIEW
// ============================================================================
// This screen shows detailed information about a specific delivery.
// Features: Complete delivery information, status tracking, contact details
// Navigation: Accessed from My Orders screen
// ============================================================================

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/delivery.dart';

class DeliveryDetailsScreen extends StatelessWidget {
  final Delivery delivery;

  const DeliveryDetailsScreen({
    Key? key,
    required this.delivery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Delivery #${delivery.id}', style: AppTheme.headerStyle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16),

              // Service Information
              Container(
                margin: const EdgeInsets.fromLTRB(AppTheme.defaultPadding, 0, AppTheme.defaultPadding, AppTheme.defaultPadding),
                padding: const EdgeInsets.all(AppTheme.defaultPadding),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: AppTheme.defaultPadding),
                    _buildInfoRow('Service Type', delivery.serviceType == 'city' ? 'City Delivery' : 'Inter-City Delivery'),
                    _buildInfoRow('Pickup Type', delivery.pickupType == 'easybox' ? 'EasyBox' : 'Address'),
                    _buildInfoRow('Delivery Type', delivery.deliveryType == 'easybox' ? 'EasyBox' : 'Address'),
                    _buildInfoRow('Price', '${delivery.price.toStringAsFixed(0)} manat'),
                    _buildInfoRow('Created Date', delivery.createdAt),
                  ],
                ),
              ),

              // Address Information
              Container(
                margin: const EdgeInsets.fromLTRB(AppTheme.defaultPadding, 0, AppTheme.defaultPadding, AppTheme.defaultPadding),
                padding: const EdgeInsets.all(AppTheme.defaultPadding),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: AppTheme.defaultPadding),
                    _buildAddressSection('Pickup Location', delivery.pickupLocation, Icons.location_on_outlined),
                    SizedBox(height: AppTheme.defaultPadding),
                    _buildAddressSection('Delivery Location', delivery.deliveryLocation, Icons.location_on),
                  ],
                ),
              ),

              // Sender Information
              if (delivery.sender != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(AppTheme.defaultPadding, 0, AppTheme.defaultPadding, AppTheme.defaultPadding),
                  padding: const EdgeInsets.all(AppTheme.defaultPadding),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sender Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: AppTheme.defaultPadding),
                      _buildContactSection(
                        'Sender',
                        delivery.sender!.fullName,
                        delivery.sender!.phoneNumber,
                        Icons.person_outline,
                      ),
                    ],
                  ),
                ),

              // Recipient Information
              if (delivery.recipient != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(AppTheme.defaultPadding, 0, AppTheme.defaultPadding, AppTheme.defaultPadding),
                  padding: const EdgeInsets.all(AppTheme.defaultPadding),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recipient Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: AppTheme.defaultPadding),
                      _buildContactSection(
                        'Recipient',
                        delivery.recipient!.fullName,
                        delivery.recipient!.phoneNumber,
                        Icons.person_outline,
                      ),
                    ],
                  ),
                ),

              // Package Information
              if (delivery.packageDescription != null && delivery.packageDescription!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(AppTheme.defaultPadding, 0, AppTheme.defaultPadding, AppTheme.defaultPadding),
                  padding: const EdgeInsets.all(AppTheme.defaultPadding),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Package Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: AppTheme.defaultPadding),
                      _buildInfoRow('Description', delivery.packageDescription!),
                    ],
                  ),
                ),


              SizedBox(height: AppTheme.largePadding),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.smallPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(String title, String address, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
        SizedBox(width: AppTheme.smallPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                address,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(String title, String name, String phone, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.primaryColor700,
            ),
          ),
        ),
        SizedBox(width: AppTheme.smallPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
