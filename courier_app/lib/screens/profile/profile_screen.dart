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
import 'package:provider/provider.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../theme/app_theme.dart';
import '../../services/user_service.dart';
import '../../services/localization_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _savedPhoneNumber = '';
  String _fullName = '';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final UserService _userService = UserService();
  
  // Language selection
  String _selectedLanguage = 'English';
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'ru', 'name': 'Russian', 'native': 'Русский'},
    {'code': 'tk', 'name': 'Turkmen', 'native': 'Türkmen'},
  ];

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
    final savedName = await _userService.getFullName();
    setState(() {
      _savedPhoneNumber = savedPhone ?? '';
      _fullName = (savedName ?? '').trim();
      // For the controller, we only want the digits part (without +993)
      _phoneController.text = _savedPhoneNumber;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _editField(String field, String currentValue, TextEditingController controller, LocalizationService localizationService, {String? fieldKey}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isPhoneField = fieldKey == 'phone' || field.toLowerCase().contains('phone');
        controller.text = isPhoneField
          ? currentValue.replaceAll('+993', '') 
          : currentValue;
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
          ),
          title: Text(
            '${localizationService.translate('edit_field')} $field',
            style: TextStyle(
              fontSize: AppTheme.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          content: isPhoneField 
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
                              fontSize: AppTheme.fontSizeLarge,
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
            : SizedBox(
                width: double.maxFinite,
                child: TextField(
                  controller: controller,
                  decoration: AppTheme.inputDecoration.copyWith(
                    hintText: 'Enter $field',
                  ),
                ),
              ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizationService.translate('cancel'),
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (isPhoneField) {
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
                  if (isPhoneField) {
                    _savedPhoneNumber = controller.text;
                    _userProfile['phone'] = '+993${controller.text}';
                  } else if (fieldKey == 'full_name') {
                    _fullName = controller.text.trim();
                  } else {
                    _userProfile[field.toLowerCase().replaceAll(' ', '_')] = controller.text;
                  }
                });
                
                // Actually save to SharedPreferences
                if (isPhoneField) {
                  await _userService.savePhoneNumber(controller.text);
                } else if (fieldKey == 'full_name') {
                  await _userService.saveFullName(controller.text.trim());
                }
                
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(fieldKey == 'phone' 
                      ? localizationService.translate('phone_updated')
                      : fieldKey == 'full_name' 
                        ? localizationService.translate('full_name_updated')
                        : '$field updated successfully'),
                    backgroundColor: Colors.green[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                    ),
                  ),
                );
              },
              child: Text(
                localizationService.translate('save'),
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
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(localizationService.translate('profile'), style: AppTheme.headerStyle),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Text(
                          'Hello, ' + (_fullName.isNotEmpty ? _fullName : ''),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      // Remove secondary TizGo service text under the name
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
                    icon: Icons.person_outline,
                    title: localizationService.translate('full_name'),
                    subtitle: _fullName.isEmpty ? '' : _fullName,
                    fieldKey: 'full_name',
                    controller: _nameController,
                    localizationService: localizationService,
                  ),
                  _buildDivider(),
                  _buildInfoTile(
                    icon: Icons.phone_outlined,
                    title: localizationService.translate('phone_number'),
                    subtitle: _userProfile['phone'],
                    fieldKey: 'phone',
                    controller: _phoneController,
                    localizationService: localizationService,
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
                    icon: Icons.language,
                    title: localizationService.translate('language'),
                    subtitle: localizationService.getNativeLanguageName(localizationService.currentLanguage),
                    onTap: () => _showLanguageDialog(localizationService),
                  ),
                  _buildDivider(),
                  _buildActionButton(
                    icon: Icons.help_outline,
                    title: localizationService.translate('help_support'),
                    onTap: () => _showHelpDialog(localizationService),
                  ),
                  _buildDivider(),
                  _buildActionButton(
                    icon: Icons.logout,
                    title: localizationService.translate('logout'),
                    onTap: () => _showLogoutDialog(localizationService),
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
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String fieldKey,
    required TextEditingController controller,
    required LocalizationService localizationService,
  }) {
    return GestureDetector(
      onTap: () => _editField(title, subtitle, controller, localizationService, fieldKey: fieldKey),
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
                      fontSize: AppTheme.fontSizeMedium,
                      color: AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeLarge,
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
    String? subtitle,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeLarge,
                        color: isDestructive ? Colors.red[600] : AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeMedium,
                          color: AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
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

  void _showHelpDialog(LocalizationService localizationService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
          ),
          title: Text(
            localizationService.translate('help_support'),
            style: TextStyle(
              fontSize: AppTheme.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizationService.translate('need_help'),
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 16),
              _buildContactOption(
                icon: Icons.phone,
                title: localizationService.translate('call_support'),
                subtitle: '+99362676755',
                onTap: () => _makePhoneCall('+99362676755'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizationService.translate('ok'),
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
                        fontSize: AppTheme.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeLarge,
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

  void _showLogoutDialog(LocalizationService localizationService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
          ),
          title: Text(
            localizationService.translate('logout'),
            style: TextStyle(
              fontSize: AppTheme.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          content: Text(
            localizationService.translate('are_you_sure_logout'),
            style: TextStyle(
              fontSize: AppTheme.fontSizeLarge,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizationService.translate('cancel'),
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
                await _userService.clearFullName();
                setState(() {
                  _savedPhoneNumber = '';
                  _fullName = '';
                });
                
                // Navigate to home screen
                context.go('/create-delivery');
                
                // Show logout message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizationService.translate('logged_out')),
                    backgroundColor: Colors.green[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                    ),
                  ),
                );
              },
              child: Text(
                localizationService.translate('logout'),
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

  void _showLanguageDialog(LocalizationService localizationService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
          ),
          title: Text(
            localizationService.translate('select_language'),
            style: TextStyle(
              fontSize: AppTheme.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: localizationService.getAvailableLanguages().map((language) {
              final isSelected = localizationService.currentLanguage == language['code'];
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await localizationService.changeLanguage(language['code']!);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${localizationService.translate('language_changed')} ${language['native']}'),
                            backgroundColor: Colors.green[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor50 : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              language['code']!.toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: AppTheme.fontSizeSmall,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            language['native']!,
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeLarge,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                      ],
                    ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizationService.translate('cancel'),
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
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

}
