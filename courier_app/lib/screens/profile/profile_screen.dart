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
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _savedPhoneNumber = '';
  final TextEditingController _phoneController = TextEditingController();
  final UserService _userService = UserService();

  // User data with saved phone
  Map<String, dynamic> get _userProfile => {
    'phone': _savedPhoneNumber.isNotEmpty ? '+993$_savedPhoneNumber' : '+993',
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
      // For the controller, we only want the digits part (without +993)
      _phoneController.text = _savedPhoneNumber;
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
        controller.text = field.toLowerCase().contains('phone') 
          ? currentValue.replaceAll('+993', '') 
          : currentValue;
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
          content: field.toLowerCase().contains('phone') 
            ? TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  prefixIcon: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '+993',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.6),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              )
            : TextField(
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
              onPressed: () async {
                if (field.toLowerCase().contains('phone')) {
                  // Validate phone number length
                  if (controller.text.length != 8) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Phone number must be exactly 8 digits'),
                        backgroundColor: Colors.red[600],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                        ),
                      ),
                    );
                    return;
                  }
                }
                
                setState(() {
                  if (field.toLowerCase().contains('phone')) {
                    // For phone numbers, save only the digits part
                    _savedPhoneNumber = controller.text;
                    _userProfile['phone'] = '+993${controller.text}';
                  } else {
                    _userProfile[field.toLowerCase().replaceAll(' ', '_')] = controller.text;
                  }
                });
                
                // Actually save to SharedPreferences
                if (field.toLowerCase().contains('phone')) {
                  await _userService.savePhoneNumber(controller.text);
                }
                
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
                  color: AppTheme.primaryColor700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Profile', style: AppTheme.headerStyle),
        leading: const Icon(Icons.person, color: AppTheme.primaryColor, size: 28),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                margin: const EdgeInsets.fromLTRB(AppTheme.defaultPadding, AppTheme.defaultPadding, AppTheme.defaultPadding, 0),
                decoration: AppTheme.cardDecoration,
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.defaultPadding),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor50,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: AppTheme.primaryColor700,
                          ),
                        ),
                      ),
                      SizedBox(width: AppTheme.defaultPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TizGo User',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Delivery Service',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
            
            SizedBox(height: AppTheme.defaultPadding),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(currentIndex: 2),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit,
              size: 20,
              color: AppTheme.textSecondaryColor,
            ),
          ],
        ),
      ),
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDestructive ? Colors.red[50] : AppTheme.primaryColor50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 20,
                    color: isDestructive ? Colors.red[600] : AppTheme.primaryColor700,
                  ),
                ),
              ),
              SizedBox(width: AppTheme.defaultPadding),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDestructive ? Colors.red[600] : AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTheme.defaultPadding),
      height: 1,
      color: Colors.grey[200],
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
          title: Text(
            'Help & Support',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need help? Contact our support team:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 16),
              _buildContactOption(
                icon: Icons.phone,
                title: 'Call Support',
                subtitle: '+993741302753',
                onTap: () => _makePhoneCall('+993741302753'),
              ),
              SizedBox(height: 12),
              _buildContactOption(
                icon: Icons.email,
                title: 'Email Support',
                subtitle: 'support@tizgo.com',
                onTap: () => _sendEmail('support@tizgo.com'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppTheme.primaryColor700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppTheme.primaryColor700,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimaryColor,
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
              onPressed: () async {
                // Clear saved data
                await _userService.clearPhoneNumber();
                
                // Navigate to home screen
                context.go('/create-delivery');
                
                // Show logout message
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
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not make phone call'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
          ),
        ),
      );
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=TizGo Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open email client'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
          ),
        ),
      );
    }
  }
}
