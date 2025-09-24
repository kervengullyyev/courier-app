// ============================================================================
// APP BOTTOM NAVIGATION - SHARED NAVIGATION COMPONENT
// ============================================================================
// Shared bottom navigation bar component to eliminate duplication across screens
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/localization_service.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigation({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            enableFeedback: false,
            currentIndex: currentIndex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: localizationService.translate('home'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping),
                label: localizationService.translate('my_orders'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: localizationService.translate('profile'),
              ),
            ],
            onTap: (index) => _handleNavigation(context, index),
          ),
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/create-delivery');
        break;
      case 1:
        context.go('/my-deliveries');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }
}
