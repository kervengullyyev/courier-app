// ============================================================================
// PROFILE SCREEN - USER PROFILE
// ============================================================================
// This screen allows users to view and edit their profile information.
// Features: Editable user info, help & support, logout
// Navigation: Bottom nav tab 2 (Profile)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Static user data
  Map<String, dynamic> _userProfile = {
    'name': 'Ahmet Rahmanov',
    'phone': '+993 12 34 56 78',
    'address': 'Ashgabat, Turkmenistan',
  };

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = _userProfile['name'];
    _phoneController.text = _userProfile['phone'];
    _addressController.text = _userProfile['address'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _editField(String field, String currentValue, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        controller.text = currentValue;
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter $field',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _userProfile[field.toLowerCase().replaceAll(' ', '_')] = controller.text;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$field updated successfully')),
                );
              },
              child: Text('Save'),
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
        title: const Text('Profile', style: AppTheme.headerStyle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/create-delivery'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.largePadding),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _userProfile['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Profile Information
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.defaultPadding),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.person,
                    title: 'Full Name',
                    subtitle: _userProfile['name'],
                    fieldKey: 'name',
                    controller: _nameController,
                  ),
                  _buildDivider(),
                  _buildInfoTile(
                    icon: Icons.phone,
                    title: 'Phone Number',
                    subtitle: _userProfile['phone'],
                    fieldKey: 'phone',
                    controller: _phoneController,
                  ),
                  _buildDivider(),
                  _buildInfoTile(
                    icon: Icons.location_on,
                    title: 'Address',
                    subtitle: _userProfile['address'],
                    fieldKey: 'address',
                    controller: _addressController,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.defaultPadding),
              child: Column(
                children: [
                  _buildActionButton(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                  SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      // TODO: Handle logout
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
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
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blue, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit,
              color: Colors.grey[400],
              size: 20,
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
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Colors.red[50] : Colors.white,
          foregroundColor: isDestructive ? Colors.red : Colors.black,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDestructive ? Colors.red[200]! : Colors.grey[200]!,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
