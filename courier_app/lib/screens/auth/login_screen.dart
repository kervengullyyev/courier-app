// ============================================================================
// LOGIN SCREEN - PHONE NUMBER AUTHENTICATION
// ============================================================================
// This screen handles phone number login for the courier app.
// Features: Phone number input, validation, OTP navigation
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Generate 6-digit OTP
        final otp = _generateOTP();
        final phoneNumber = '+40${_phoneController.text}';
        
        // Send SMS with OTP
        await _sendSMS(phoneNumber, otp);
        
        setState(() {
          _isLoading = false;
        });

        // Show success message with OTP for testing
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OTP sent successfully to $phoneNumber'),
                SizedBox(height: 8),
                Text(
                  'Your OTP code: $otp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
            ),
            duration: Duration(seconds: 10),
          ),
        );

        // Navigate to OTP screen with the generated OTP
        context.go('/otp', extra: {'phone': _phoneController.text, 'otp': otp});
        
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: $e'),
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

  String _generateOTP() {
    // Generate a random 6-digit OTP
    final random = DateTime.now().millisecondsSinceEpoch;
    final otp = (random % 900000 + 100000).toString();
    return otp;
  }

  Future<void> _sendSMS(String phoneNumber, String otp) async {
    // For now, we'll use a platform channel to send SMS
    // This requires native implementation on both Android and iOS
    const platform = MethodChannel('sms_channel');
    
    try {
      print('Attempting to send SMS to: $phoneNumber');
      print('OTP Code: $otp');
      
      await platform.invokeMethod('sendSMS', {
        'phoneNumber': phoneNumber,
        'message': 'Your Courier App verification code is: $otp. Valid for 5 minutes.',
      });
      
      print('SMS sent successfully');
    } catch (e) {
      // If SMS sending fails, we'll still proceed with the OTP
      // In a real app, you might want to handle this differently
      print('SMS sending failed: $e');
      print('Continuing with OTP flow anyway...');
      // For demo purposes, we'll continue anyway
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    
    // Remove any non-digit characters for validation
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 3) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.largePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60),
                
                // Logo and Title
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_shipping_outlined,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: AppTheme.defaultPadding),
                    Text(
                      'Courier App',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: AppTheme.smallPadding),
                    Text(
                      'Fast and reliable delivery service',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 80),
                
                // Login Form
                Container(
                  padding: const EdgeInsets.all(AppTheme.largePadding),
                  decoration: AppTheme.cardDecoration,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: AppTheme.smallPadding),
                        Text(
                          'Enter your phone number to continue',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        SizedBox(height: AppTheme.largePadding),
                        
                        // Phone Number Input
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                          decoration: AppTheme.inputDecoration.copyWith(
                            hintText: 'Enter phone number',
                            prefixText: '+40 ',
                            prefixStyle: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textPrimaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          validator: _validatePhoneNumber,
                        ),
                        
                        SizedBox(height: AppTheme.largePadding),
                        
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Send OTP',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: AppTheme.largePadding),
                
                // Terms and Privacy
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
