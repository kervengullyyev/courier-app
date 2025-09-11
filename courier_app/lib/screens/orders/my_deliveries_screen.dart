// ============================================================================
// ORDERS SCREEN - MY DELIVERIES
// ============================================================================
// This screen shows the user's delivery history and order status.
// Features: Static sample data, delivery list, status display
// Navigation: Bottom nav tab 1 (My Orders)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../theme/app_theme.dart';
import '../../models/delivery.dart';
import '../../services/delivery_service.dart';
import 'delivery_details_screen.dart';

class MyDeliveriesScreen extends StatefulWidget {
  final String loggedInPhone;
  
  const MyDeliveriesScreen({Key? key, this.loggedInPhone = ''}) : super(key: key);

  @override
  _MyDeliveriesScreenState createState() => _MyDeliveriesScreenState();
}

class _MyDeliveriesScreenState extends State<MyDeliveriesScreen> {
  final DeliveryService _deliveryService = DeliveryService();

  @override
  void initState() {
    super.initState();
    _deliveryService.initializeWithSampleData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Orders', style: AppTheme.headerStyle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/create-delivery'),
        ),
      ),
      body: SafeArea(
        child: _deliveryService.deliveries.isEmpty
            ? _buildEmptyState()
            : _buildDeliveriesList(),
      ),
      bottomNavigationBar: AppBottomNavigation(currentIndex: 1, loggedInPhone: widget.loggedInPhone),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: AppTheme.largePadding),
            Text(
              'No deliveries yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: AppTheme.smallPadding),
            Text(
              'Create your first delivery to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: AppTheme.largePadding),
            Container(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.go('/create-delivery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.largeBorderRadius),
                  ),
                ),
                child: Text(
                  'Create Delivery',
                  style: AppTheme.buttonTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveriesList() {
    // Sort deliveries by date (most recent first)
    final sortedDeliveries = List<Delivery>.from(_deliveryService.deliveries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.defaultPadding),
      itemCount: sortedDeliveries.length,
      itemBuilder: (context, index) {
        final delivery = sortedDeliveries[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.defaultPadding),
          decoration: AppTheme.cardDecoration,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
              onTap: () => _showDeliveryDetails(context, delivery),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with ID and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery #${delivery.id}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        _buildStatusChip(delivery.status),
                      ],
                    ),
                    SizedBox(height: AppTheme.defaultPadding),
                    
                    // Addresses
                    _buildAddressRow(
                      icon: Icons.location_on_outlined,
                      label: 'From',
                      address: delivery.pickupAddress,
                    ),
                    SizedBox(height: AppTheme.smallPadding),
                    _buildAddressRow(
                      icon: Icons.location_on,
                      label: 'To',
                      address: delivery.deliveryAddress,
                    ),
                    SizedBox(height: AppTheme.defaultPadding),
                    
                    // Bottom row with recipient and date
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Recipient info
                        if (delivery.recipient != null)
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                SizedBox(width: AppTheme.smallPadding),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Recipient',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                      Text(
                                        delivery.recipient!.fullName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textPrimaryColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        SizedBox(width: AppTheme.defaultPadding),
                        
                        // Date
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            SizedBox(width: AppTheme.smallPadding),
                            Text(
                              delivery.createdAt,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        icon = Icons.schedule;
        break;
      case 'in transit':
        backgroundColor = Colors.blue[50]!;
        textColor = Colors.blue[700]!;
        icon = Icons.local_shipping;
        break;
      case 'delivered':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        icon = Icons.check_circle;
        break;
      default:
        backgroundColor = Colors.grey[50]!;
        textColor = Colors.grey[700]!;
        icon = Icons.help_outline;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.smallPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.smallBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required String label,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        SizedBox(width: AppTheme.smallPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              SizedBox(height: 2),
              Text(
                address,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeliveryDetails(BuildContext context, Delivery delivery) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryDetailsScreen(delivery: delivery),
      ),
    );
  }
}
