// ============================================================================
// PROFILE SCREEN - USER PROFILE
// ============================================================================
// This screen allows users to view and edit their profile information.
// Features: Editable user info, help & support, logout
// Navigation: Bottom nav tab 2 (Profile)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../theme/app_theme.dart';
import '../../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  final String loggedInPhone;
  
  const ProfileScreen({Key? key, this.loggedInPhone = ''}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _savedPhoneNumber = '';
  final TextEditingController _phoneController = TextEditingController();
  final UserService _userService = UserService();

  // User data with logged-in phone
  Map<String, dynamic> get _userProfile => {
    'phone': _savedPhoneNumber.isNotEmpty ? '+40$_savedPhoneNumber' : '+40${widget.loggedInPhone}',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedPhoneNumber();
  }

  Future<void> _loadSavedPhoneNumber() async {
    final savedPhone = await _userService.getPhoneNumber();
    setState(() {
      _savedPhoneNumber = savedPhone ?? '';
      _phoneController.text = _userProfile['phone'];
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _editField(String field, String currentValue, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        controller.text = currentValue;
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
          ),
          title: Text(
            'Edit $field',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: AppTheme.inputDecoration.copyWith(
              hintText: 'Enter $field',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _userProfile[field.toLowerCase().replaceAll(' ', '_')] = controller.text;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$field updated successfully'),
                    backgroundColor: Colors.green[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                    ),
                  ),
                );
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    Icons.help_outline,
                    size: 20,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              SizedBox(width: AppTheme.smallPadding),
              Expanded(
                child: Text(
                  'Help & Support',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Need assistance? Contact our support team:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              SizedBox(height: AppTheme.defaultPadding),
              Container(
                padding: const EdgeInsets.all(AppTheme.defaultPadding),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                    SizedBox(width: AppTheme.smallPadding),
                    Text(
                      '+40741302753',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                const phoneNumber = '+40741302753';
                final Uri phoneUri = Uri.parse('tel:$phoneNumber');
                
                try {
                  // Check if we can launch the URL
                  final bool canLaunch = await canLaunchUrl(phoneUri);
                  
                  if (canLaunch) {
                    // Launch the phone app
                    final bool launched = await launchUrl(
                      phoneUri,
                      mode: LaunchMode.externalApplication,
                    );
                    
                    if (!launched) {
                      throw Exception('Failed to launch phone app');
                    }
                  } else {
                    // Try alternative method - copy to clipboard
                    await Clipboard.setData(ClipboardData(text: phoneNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Phone app not available. Number copied to clipboard: $phoneNumber'),
                        backgroundColor: Colors.orange[600],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  // Copy number to clipboard as fallback
                  await Clipboard.setData(ClipboardData(text: phoneNumber));
                  
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not make phone call. Number copied to clipboard: $phoneNumber'),
                      backgroundColor: Colors.red[600],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                      ),
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
                
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.phone, size: 18),
              label: Text('Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.defaultPadding,
                  vertical: AppTheme.smallPadding,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    Icons.logout,
                    size: 20,
                    color: Colors.red[700],
                  ),
                ),
              ),
              SizedBox(width: AppTheme.smallPadding),
              Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout? You will need to verify your phone number again to access the app.',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.defaultPadding,
                  vertical: AppTheme.smallPadding,
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performLogout() async {
    // Clear saved phone number
    await _userService.clearPhoneNumber();
    
    // Show logout confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged out successfully'),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        ),
      ),
    );

    // Navigate back to login screen
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profile', style: AppTheme.headerStyle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/create-delivery', extra: {'phone': widget.loggedInPhone}),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Profile Header
            Container(
              margin: const EdgeInsets.fromLTRB(AppTheme.defaultPadding, AppTheme.defaultPadding, AppTheme.defaultPadding, AppTheme.defaultPadding),
              padding: const EdgeInsets.all(AppTheme.largePadding),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: AppTheme.smallPadding),
                  Text(
                    'Manage your profile information',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppTheme.defaultPadding),
            
            // Profile Information
            Container(
              margin: const EdgeInsets.fromLTRB(AppTheme.defaultPadding, 0, AppTheme.defaultPadding, AppTheme.defaultPadding),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.phone_outlined,
                    title: 'Phone Number',
                    subtitle: _userProfile['phone'],
                    fieldKey: 'phone',
                    controller: _phoneController,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppTheme.defaultPadding),
            
            // Action Buttons
            Container(
              margin: const EdgeInsets.fromLTRB(AppTheme.defaultPadding, 0, AppTheme.defaultPadding, AppTheme.defaultPadding),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  _buildActionButton(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => _showHelpDialog(),
                  ),
                  _buildDivider(),
                  _buildActionButton(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () => _showLogoutDialog(),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppTheme.largePadding),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(currentIndex: 2, loggedInPhone: widget.loggedInPhone),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String fieldKey,
    required TextEditingController controller,
  }) {
    return GestureDetector(
      onTap: () => _editField(title, subtitle, controller),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.blue[700],
                ),
              ),
            ),
            SizedBox(width: AppTheme.defaultPadding),
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
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Colors.grey[200],
    );
  }


  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.defaultPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDestructive ? Colors.red[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 20,
                    color: isDestructive ? Colors.red[700] : Colors.blue[700],
                  ),
                ),
              ),
              SizedBox(width: AppTheme.defaultPadding),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? Colors.red[700] : AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
