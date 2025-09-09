// ============================================================================
// COURIER APP - MAIN ENTRY POINT
// ============================================================================
// This is the main entry point for the Courier App.
// Features: App routing, theme configuration, system UI setup
// Screens: Home (Create Delivery), Orders (My Deliveries), Profile
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'screens/orders/my_deliveries_screen.dart';
import 'screens/home/create_delivery_screen.dart';import 'screens/profile/profile_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp.router(
          title: 'Courier App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Inter',
            scaffoldBackgroundColor: AppTheme.backgroundColor,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              titleTextStyle: AppTheme.headerStyle,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
            ),
            textTheme: const TextTheme(
              displayLarge: TextStyle(fontFamily: 'Inter'),
              displayMedium: TextStyle(fontFamily: 'Inter'),
              displaySmall: TextStyle(fontFamily: 'Inter'),
              headlineLarge: TextStyle(fontFamily: 'Inter'),
              headlineMedium: TextStyle(fontFamily: 'Inter'),
              headlineSmall: TextStyle(fontFamily: 'Inter'),
              titleLarge: TextStyle(fontFamily: 'Inter'),
              titleMedium: TextStyle(fontFamily: 'Inter'),
              titleSmall: TextStyle(fontFamily: 'Inter'),
              bodyLarge: TextStyle(fontFamily: 'Inter'),
              bodyMedium: TextStyle(fontFamily: 'Inter'),
              bodySmall: TextStyle(fontFamily: 'Inter'),
              labelLarge: TextStyle(fontFamily: 'Inter'),
              labelMedium: TextStyle(fontFamily: 'Inter'),
              labelSmall: TextStyle(fontFamily: 'Inter'),
            ),
          ),
          routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/create-delivery',
  routes: [
    GoRoute(
      path: '/create-delivery',
      builder: (context, state) => CreateDeliveryScreen(),
    ),
    GoRoute(
      path: '/my-deliveries',
      builder: (context, state) => MyDeliveriesScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfileScreen(),
    ),
  ],
);