// ============================================================================
// OTP SCREEN - VERIFICATION CODE
// ============================================================================
// This screen handles OTP verification for phone number authentication.
// Features: 6-digit OTP input, resend functionality, verification
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../theme/app_theme.dart';
import '../../services/user_service.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String? expectedOTP;

  const OTPScreen({Key? key, required this.phoneNumber, this.expectedOTP}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with TickerProviderStateMixin, CodeAutoFill {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 30;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
    _setupAnimations();
    _autoFocusFirstField();
    _listenForSMS();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  void _autoFocusFirstField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _listenForSMS() async {
    try {
      // Get the app signature for SMS autofill
      String? signature = await SmsAutoFill().getAppSignature;
      print('App signature for SMS autofill: $signature');
      
      // Start listening for SMS codes using sms_autofill
      await SmsAutoFill().listenForCode();
      
    } catch (e) {
      print('Error setting up SMS autofill: $e');
    }
  }

  @override
  void codeUpdated() {
    // This method is called when SMS code is received
    String? receivedCode = code;
    if (receivedCode != null && receivedCode.length == 6) {
      print('SMS code received via CodeAutoFill: $receivedCode');
      // Auto-fill the individual controllers
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = receivedCode[i];
      }
      // Auto-verify when complete
      Future.delayed(Duration(milliseconds: 500), () {
        _verifyOTP();
      });
    }
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((node) => node.dispose());
    _animationController.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  void _startResendCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _startResendCountdown();
      }
    });
  }

  void _handleOTPChange(String value, int index) {
    if (value.length == 1) {
      // Move to next field with smooth transition
      if (index < 5) {
        Future.delayed(Duration(milliseconds: 50), () {
          _focusNodes[index + 1].requestFocus();
        });
      } else {
        // Last field filled, auto-verify
        Future.delayed(Duration(milliseconds: 100), () {
          _focusNodes[index].unfocus();
          _verifyOTP();
        });
      }
    } else if (value.isEmpty && index > 0) {
      // Move to previous field when deleting
      Future.delayed(Duration(milliseconds: 50), () {
        _focusNodes[index - 1].requestFocus();
      });
    }
  }

  void _clearAllOTPFields() {
    for (int i = 0; i < 6; i++) {
      _controllers[i].clear();
    }
    // Clear the PinFieldAutoFill
    SmsAutoFill().unregisterListener();
    _listenForSMS(); // Re-register listener
  }

  void _testSMSAutofill() {
    // Simulate SMS autofill with test code
    String testCode = "123456";
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = testCode[i];
    }
    print('Test SMS autofill applied: $testCode');
  }


  void _verifyOTP() async {
    String otp = _controllers.map((controller) => controller.text).join();
    
    if (otp.length == 6) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));

      // Verify OTP
      bool isValid = _verifyOTPCode(otp);
      
      setState(() {
        _isLoading = false;
      });

      if (isValid) {
        // Save phone number to persistent storage
        final userService = UserService();
        await userService.savePhoneNumber(widget.phoneNumber);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phone number verified successfully!'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
            ),
          ),
        );

        // Navigate to main app with phone number
        context.go('/create-delivery', extra: {'phone': widget.phoneNumber});
      } else {
        // Clear fields and show error message
        _clearAllOTPFields();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP. Please try again.'),
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

  bool _verifyOTPCode(String enteredOTP) {
    // In a real app, this would be verified against the server
    // For now, we'll check against the expected OTP if available
    if (widget.expectedOTP != null) {
      return enteredOTP == widget.expectedOTP;
    }
    
    // For demo purposes, accept any 6-digit code
    return enteredOTP.length == 6;
  }

  void _resendOTP() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResending = true;
    });

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isResending = false;
      _resendCountdown = 30;
    });

    _startResendCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent successfully'),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Verify Phone', style: AppTheme.headerStyle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.largePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                
                // Header
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.message_outlined,
                          size: 40,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                    SizedBox(height: AppTheme.defaultPadding),
                    Text(
                      'Enter Verification Code',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: AppTheme.smallPadding),
                    Text(
                      'We sent a 6-digit code to',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '+40${widget.phoneNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 60),
                
                // OTP Input Fields
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.largePadding),
                    decoration: AppTheme.cardDecoration,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              width: 40,
                              height: 55,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _focusNodes[index].hasFocus 
                                      ? Colors.blue[700]! 
                                      : _controllers[index].text.isNotEmpty
                                          ? Colors.green[600]!
                                          : Colors.grey[300]!,
                                  width: _focusNodes[index].hasFocus ? 3 : 2,
                                ),
                                borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                                color: Colors.white,
                                boxShadow: _focusNodes[index].hasFocus ? [
                                  BoxShadow(
                                    color: Colors.blue[700]!.withOpacity(0.2),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ] : [
                                  BoxShadow(
                                    color: Colors.grey[300]!.withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(1),
                                ],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                  hintText: '',
                                ),
                                onChanged: (value) => _handleOTPChange(value, index),
                                onTap: () {
                                  // Clear field when tapped
                                  if (_controllers[index].text.isNotEmpty) {
                                    _controllers[index].clear();
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                      
                      
                      SizedBox(height: AppTheme.smallPadding),
                      
                      // SMS Autofill Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sms,
                            size: 16,
                            color: Colors.green[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'SMS autofill + manual input',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: AppTheme.defaultPadding),
                      
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: _clearAllOTPFields,
                            child: Text(
                              'Clear All',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _testSMSAutofill,
                            child: Text(
                              'Test Fill',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[600],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: AppTheme.defaultPadding),
                      
                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOTP,
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
                                  'Verify',
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
                
                // Resend OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: _resendOTP,
                      child: Text(
                        _resendCountdown > 0 
                            ? 'Resend in ${_resendCountdown}s'
                            : 'Resend',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _resendCountdown > 0 
                              ? AppTheme.textSecondaryColor
                              : Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (_isResending) ...[
                  SizedBox(height: AppTheme.smallPadding),
                  Text(
                    'Sending...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
