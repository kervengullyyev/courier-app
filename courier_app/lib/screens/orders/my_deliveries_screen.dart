// ============================================================================
// ORDERS SCREEN - MY DELIVERIES
// ============================================================================
// This screen shows the user's delivery history and order status.
// Features: Static sample data, delivery list, status display
// Navigation: Bottom nav tab 1 (My Orders)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../theme/app_theme.dart';
import '../../models/delivery.dart';
import '../../services/delivery_service.dart';
import '../../services/localization_service.dart';
import 'delivery_details_screen.dart';

class MyDeliveriesScreen extends StatefulWidget {
  const MyDeliveriesScreen({Key? key}) : super(key: key);

  @override
  _MyDeliveriesScreenState createState() => _MyDeliveriesScreenState();
}

class _MyDeliveriesScreenState extends State<MyDeliveriesScreen> {
  final DeliveryService _deliveryService = DeliveryService();

  @override
  void initState() {
    super.initState();
    _bootstrapDeliveries();
  }

  Future<void> _bootstrapDeliveries() async {
    await _deliveryService.loadFromPreferences();
    if (mounted) setState(() {});
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
            title: Text(localizationService.translate('my_orders'), style: AppTheme.headerStyle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.go('/create-delivery'),
            ),
          ),
          body: SafeArea(
            child: _deliveryService.deliveries.isEmpty
                ? _buildEmptyState(localizationService)
                : _buildDeliveriesList(localizationService),
          ),
          bottomNavigationBar: AppBottomNavigation(currentIndex: 1),
        );
      },
    );
  }

  Widget _buildEmptyState(LocalizationService localizationService) {
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
              localizationService.translate('no_deliveries_yet'),
              style: TextStyle(
                fontSize: AppTheme.fontSizeHeader,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: AppTheme.smallPadding),
            Text(
              localizationService.translate('create_first_delivery'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
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
                  localizationService.translate('create_delivery'),
                  style: AppTheme.buttonTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveriesList(LocalizationService localizationService) {
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
                    // Header with ID and Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${localizationService.translate('delivery_id')}${delivery.id}',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeXLarge,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              delivery.createdAt.split(' ')[0], // Date part
                              style: TextStyle(
                                fontSize: AppTheme.fontSizeMedium,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            Text(
                              delivery.createdAt.split(' ')[1], // Time part
                              style: TextStyle(
                                fontSize: AppTheme.fontSizeSmall,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.defaultPadding),
                    
                    // Addresses
                    _buildAddressRow(
                      icon: Icons.location_on_outlined,
                      label: localizationService.translate('from'),
                      address: delivery.pickupAddress,
                    ),
                    SizedBox(height: AppTheme.smallPadding),
                    _buildAddressRow(
                      icon: Icons.location_on,
                      label: localizationService.translate('to'),
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
                                    color: AppTheme.primaryColor50,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: AppTheme.primaryColor700,
                                  ),
                                ),
                                SizedBox(width: AppTheme.smallPadding),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localizationService.translate('recipient'),
                                        style: TextStyle(
                                          fontSize: AppTheme.fontSizeSmall,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                      Text(
                                        delivery.recipient!.fullName,
                                        style: TextStyle(
                                          fontSize: AppTheme.fontSizeMedium,
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
                  fontSize: AppTheme.fontSizeSmall,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              SizedBox(height: 2),
              Text(
                address,
                style: TextStyle(
                  fontSize: AppTheme.fontSizeMedium,
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
