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

class MyDeliveriesScreen extends StatefulWidget {
  @override
  _MyDeliveriesScreenState createState() => _MyDeliveriesScreenState();
}

class _MyDeliveriesScreenState extends State<MyDeliveriesScreen> {
  // Static sample data using proper models
  final List<Delivery> _sampleDeliveries = [
    Delivery(
      id: 1,
      pickupAddress: 'Easybox - Ashgabat Center',
      deliveryAddress: 'Easybox - Mary City',
      status: 'In Transit',
      courier: const Courier(fullName: 'Ahmet Rahmanov'),
      createdAt: '2024-01-15',
      price: 15.0,
      serviceType: 'city',
    ),
    Delivery(
      id: 2,
      pickupAddress: '123 Main Street, Ashgabat',
      deliveryAddress: '456 Oak Avenue, Turkmenabat',
      status: 'Delivered',
      courier: const Courier(fullName: 'Saparmurat Niyazov'),
      createdAt: '2024-01-14',
      price: 35.0,
      serviceType: 'inter-city',
    ),
    Delivery(
      id: 3,
      pickupAddress: 'Easybox - Balkanabat',
      deliveryAddress: '789 Pine Road, Dashoguz',
      status: 'Pending',
      courier: null,
      createdAt: '2024-01-13',
      price: 15.0,
      serviceType: 'city',
    ),
  ];

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
        child: _sampleDeliveries.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No deliveries yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create your first delivery to get started',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppTheme.defaultPadding),
                itemCount: _sampleDeliveries.length,
                itemBuilder: (context, index) {
                  final delivery = _sampleDeliveries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('Delivery #${delivery.id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From: ${delivery.pickupAddress}'),
                          Text('To: ${delivery.deliveryAddress}'),
                          Text('Status: ${delivery.status}'),
                          Text('Price: ${delivery.price.toStringAsFixed(0)} manat'),
                          if (delivery.courier != null)
                            Text('Courier: ${delivery.courier!.fullName}'),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.go('/delivery/${delivery.id}'),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }
}
