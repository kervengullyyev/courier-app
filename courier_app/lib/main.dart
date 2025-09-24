// ============================================================================
// TIZGO APP - MAIN ENTRY POINT
// ============================================================================
// This is the main entry point for the TizGo App.
// Features: App routing, theme configuration, system UI setup
// Screens: Home (Create Delivery), Orders (My Deliveries), Profile
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'screens/orders/my_deliveries_screen.dart';
import 'screens/home/create_delivery_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'theme/app_theme.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize localization service
  final localizationService = LocalizationService();
  await localizationService.loadLanguage();
  
  runApp(MyApp(localizationService: localizationService));
}

class MyApp extends StatelessWidget {
  final LocalizationService localizationService;
  
  const MyApp({Key? key, required this.localizationService}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: ChangeNotifierProvider<LocalizationService>.value(
        value: localizationService,
        child: Consumer<LocalizationService>(
          builder: (context, localizationService, child) {
            return MaterialApp.router(
              title: 'TizGo',
              locale: localizationService.currentLanguage == 'tk' 
                  ? const Locale('en', '') // Fallback to English for Turkmen
                  : Locale(localizationService.currentLanguage),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
                Locale('ru', ''),
              ],
          theme: ThemeData(
            primarySwatch: MaterialColor(0xFF0065F8, {
              50: Color(0xFFE3F2FD),
              100: Color(0xFFBBDEFB),
              200: Color(0xFF90CAF9),
              300: Color(0xFF64B5F6),
              400: Color(0xFF42A5F5),
              500: Color(0xFF0065F8),
              600: Color(0xFF1E88E5),
              700: Color(0xFF1976D2),
              800: Color(0xFF1565C0),
              900: Color(0xFF0D47A1),
            }),
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
            );
          },
        ),
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