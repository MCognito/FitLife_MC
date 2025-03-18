import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_profile.dart';
import '../../service/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;
  String? _errorMessage;

  // Form controllers
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _genderController;
  late TextEditingController _dateOfBirthController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    final personalInfo = widget.profile.personalInfo;
    _ageController =
        TextEditingController(text: personalInfo.age?.toString() ?? '');
    _heightController =
        TextEditingController(text: personalInfo.height?.toString() ?? '');
    _genderController = TextEditingController(text: personalInfo.gender ?? '');
    _selectedDate = personalInfo.dateOfBirth;
    _dateOfBirthController = TextEditingController(
      text: personalInfo.dateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(personalInfo.dateOfBirth!)
          : '',
    );
  }

  @override
  void dispose() {
    // Dispose controllers
    _ageController.dispose();
    _heightController.dispose();
    _genderController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  // Calculate age accurately considering month and day
  int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    // Subtract 1 if the birthday hasn't occurred yet this year
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);

        // Calculate age based on date of birth with accurate calculation
        final age = calculateAge(picked);
        _ageController.text = age.toString();
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create updated personal info
      final updatedPersonalInfo = widget.profile.personalInfo.copyWith(
        age: _ageController.text.isNotEmpty
            ? int.parse(_ageController.text)
            : null,
        height: _heightController.text.isNotEmpty
            ? double.parse(_heightController.text)
            : null,
        gender:
            _genderController.text.isNotEmpty ? _genderController.text : null,
        dateOfBirth: _selectedDate,
      );

      // Create updated profile
      final updatedProfile = widget.profile.copyWith(
        personalInfo: updatedPersonalInfo,
      );

      // Save to backend
      await _profileService.updateUserProfile(updatedProfile);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        // Return to profile page
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to update profile: $e';
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information Section
                    Text(
                      'Personal Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Date of Birth field
                    TextFormField(
                      controller: _dateOfBirthController,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 16),

                    // Age field
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          try {
                            final age = int.parse(value);
                            if (age < 0 || age > 120) {
                              return 'Please enter a valid age';
                            }
                          } catch (e) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Height field
                    TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          try {
                            final height = double.parse(value);
                            if (height < 0 || height > 300) {
                              return 'Please enter a valid height';
                            }
                          } catch (e) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Gender field
                    TextFormField(
                      controller: _genderController,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
