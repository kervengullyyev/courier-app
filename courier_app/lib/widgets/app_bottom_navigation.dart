// ============================================================================
// APP BOTTOM NAVIGATION - SHARED NAVIGATION COMPONENT
// ============================================================================
// Shared bottom navigation bar component to eliminate duplication across screens
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final String loggedInPhone;

  const AppBottomNavigation({
    Key? key,
    required this.currentIndex,
    this.loggedInPhone = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        enableFeedback: false,
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'My Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) => _handleNavigation(context, index),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/create-delivery', extra: {'phone': loggedInPhone});
        break;
      case 1:
        context.go('/my-deliveries');
        break;
      case 2:
        context.go('/profile', extra: {'phone': loggedInPhone});
        break;
    }
  }
}
