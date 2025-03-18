import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../resources/theme/color_style.dart';
import '../../viewmodel/auth_validation_viewmodel.dart';
import '../../viewmodel/auth_handlers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../../../resources/utils/responsive_container.dart';
import '../../../../resources/utils/responsive_text.dart';

class PasswordResetVerificationPage extends ConsumerStatefulWidget {
  final String email;

  const PasswordResetVerificationPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<PasswordResetVerificationPage> createState() =>
      _PasswordResetVerificationPageState();
}

class _PasswordResetVerificationPageState
    extends ConsumerState<PasswordResetVerificationPage> {
  final ImageProvider image =
      const AssetImage('assets/images/fitlifeLogo.jpeg');
  final codeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  int _remainingTime = 60; // 1 minute (60 seconds)
  Timer? _timer;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _remainingTime = 60; // 1 minute (60 seconds)
      _isResendEnabled = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _isResendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the theme mode for changes
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    // Set colors based on theme
    final backgroundColor =
        isDarkMode ? ColorStyle.darkGray : ColorStyle.fitLifeBlue;
    final textColor = isDarkMode ? Colors.white : ColorStyle.lightTextOnBlue;
    final inputFillColor =
        isDarkMode ? ColorStyle.darkBackground : Colors.white.withOpacity(0.9);
    final inputBorderColor = isDarkMode ? Colors.white : Colors.black54;
    final labelTextColor = isDarkMode ? Colors.lightBlue[100] : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Reset Code'),
        backgroundColor: backgroundColor,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 10),
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 15.0),
                    child: Image(
                      image: image,
                      height: 200,
                      width: 200,
                    ),
                  ),
                  // Instructions
                  ResponsiveContainer(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.only(bottom: 20.0),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.black26
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        ResponsiveText(
                          'Verification Code',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ResponsiveText(
                          'We have sent a verification code to ${widget.email}. Please enter the code below to continue.',
                          style: TextStyle(
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  // Timer display
                  _remainingTime > 0
                      ? Text(
                          'Code expires in ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(
                          'Code has expired. Please request a new one.',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 20),
                  // Verification code field
                  TextFormField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Verification Code",
                      labelStyle: TextStyle(
                        color: labelTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            BorderSide(color: inputBorderColor, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            BorderSide(color: inputBorderColor, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.lightBlue[100] : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Please enter the verification code";
                      }
                      if (val.length != 6) {
                        return "Verification code must be 6 digits";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Verify Code button
                  ElevatedButton(
                    onPressed: _remainingTime > 0
                        ? () => AuthHandlers.handleVerifyResetCode(
                              context,
                              formKey: formKey,
                              email: widget.email,
                              codeController: codeController,
                            )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? ColorStyle.purpleButton
                          : ColorStyle.purpleButtonLight,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBackgroundColor: isDarkMode
                          ? ColorStyle.purpleButton.withOpacity(0.5)
                          : ColorStyle.purpleButtonLight.withOpacity(0.5),
                    ),
                    child: const Text(
                      "Verify Code",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Resend Code button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Return to forgot password page to request a new code
                    },
                    child: Text(
                      "Resend Code",
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.lightBlue[100]
                            : Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'The code will expire in 1 minute.',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
