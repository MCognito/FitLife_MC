import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../../../resources/theme/color_style.dart';
import '../../../authentication/viewmodel/auth_view_model.dart';
import '../../../authentication/viewmodel/auth_validation_viewmodel.dart';
import 'package:show_hide_password/show_hide_password.dart';
import 'package:provider/provider.dart' as provider;

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _validationViewModel = AuthValidationViewModel();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authViewModel =
          provider.Provider.of<AuthViewModel>(context, listen: false);
      final success = await authViewModel.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (success) {
        if (mounted) {
          // Send email notification about password change
          _sendPasswordChangeNotification();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = authViewModel.error ?? 'Failed to change password';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to send email notification about password change
  Future<void> _sendPasswordChangeNotification() async {
    try {
      // This would typically call a backend API to send the email
      // For now, we'll just log it
      print('Sending password change notification email');

      // In a real implementation, you would call your backend API:
      // final authService = AuthService();
      // await authService.sendPasswordChangeNotification();
    } catch (e) {
      print('Error sending password change notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the theme mode for changes
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    // Set colors based on theme - matching settings page style
    final buttonColor =
        isDarkMode ? ColorStyle.purpleButton : ColorStyle.purpleButtonLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page title
              Text(
                'Change Password',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),

              // Security section
              _buildSectionHeader(context, 'Security'),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Password Field
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      labelText: "Current Password",
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Please enter your current password";
                        }
                        return null;
                      },
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 20),

                    // New Password Field
                    _buildPasswordField(
                      controller: _newPasswordController,
                      labelText: "New Password",
                      validator: _validationViewModel.validatePassword,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 20),

                    // Confirm New Password Field
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      labelText: "Confirm New Password",
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Please confirm your new password";
                        }
                        if (val != _newPasswordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      isDarkMode: isDarkMode,
                    ),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Change Password Button
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Changing...'),
                          ],
                        )
                      : const Text('Change Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required FormFieldValidator<String> validator,
    required bool isDarkMode,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ShowHidePassword(
          passwordField: (hidePassword) {
            return TextFormField(
              controller: controller,
              obscureText: hidePassword,
              decoration: InputDecoration(
                labelText: labelText,
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              validator: validator,
            );
          },
          iconSize: 20,
          visibleOffIcon: Icons.visibility_off,
          visibleOnIcon: Icons.visibility,
        ),
      ),
    );
  }
}
