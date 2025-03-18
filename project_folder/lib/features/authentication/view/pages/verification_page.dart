import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../resources/theme/color_style.dart';
import '../../../../main.dart';
import '../../service/auth_service.dart';
import '../custom_widgets/custom_button.dart';
import '../custom_widgets/custom_input_fields.dart';

class VerificationPage extends ConsumerStatefulWidget {
  final String email;
  final String username;
  final String password;

  const VerificationPage({
    Key? key,
    required this.email,
    required this.username,
    required this.password,
  }) : super(key: key);

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isResendEnabled = false;
  String? _errorMessage;
  int _remainingTime = 60; // 1 minute (60 seconds)
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sendVerificationCode();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.sendVerificationCode(widget.email);

      if (response['success']) {
        // Start the timer
        _startTimer();
      } else {
        setState(() {
          _errorMessage =
              response['error'] ?? 'Failed to send verification code';
          _isResendEnabled = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isResendEnabled = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final code = _codeController.text.trim();

      final result = await _authService.verifyCode(widget.email, code);

      if (result['success']) {
        print("Verification successful, proceeding to registration");

        // If verification is successful, complete the registration
        final registerResponse = await _authService.register(
            widget.username, widget.email, widget.password,
            code: code);

        if (registerResponse['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful! Please log in.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);
          }
        } else {
          setState(() {
            _errorMessage = registerResponse['error'] ?? 'Registration failed';
            print("Registration failed: $_errorMessage");
          });
        }
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Invalid verification code';
          print("Verification failed: $_errorMessage");
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        print("Error during verification: $e");
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        title: const Text('Email Verification'),
        backgroundColor: backgroundColor,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Icon(
                    Icons.email_outlined,
                    size: 80,
                    color: textColor,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Verification Code Sent',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We\'ve sent a verification code to:',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.email,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Please enter the 6-digit code below:',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 8,
                      color: isDarkMode ? Colors.lightBlue[100] : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '000000',
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the verification code';
                      }
                      if (value.length != 6) {
                        return 'Code must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  _errorMessage != null
                      ? Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            CustomButton(
                              text: "Verify",
                              onPressed: _verifyCode,
                            ),
                            const SizedBox(height: 20),
                            _remainingTime > 0
                                ? Text(
                                    'Resend code in ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  )
                                : TextButton(
                                    onPressed: _isResendEnabled
                                        ? () {
                                            _sendVerificationCode();
                                          }
                                        : null,
                                    child: Text(
                                      'Resend Code',
                                      style: TextStyle(
                                        color: _isResendEnabled
                                            ? (isDarkMode
                                                ? Colors.lightBlue[100]
                                                : Colors.blue[800])
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                  const SizedBox(height: 20),
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
