import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/contact_viewmodel.dart';
import '../../models/contact_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedCategory = 'General Inquiry';
  final List<String> _categories = [
    'General Inquiry',
    'Technical Support',
    'Account Issues',
    'Billing',
    'Feature Request',
    'Bug Report',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Load user email from SharedPreferences
    _loadUserEmail();
  }

  // Load user email from SharedPreferences
  Future<void> _loadUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoString = prefs.getString('user_info');

      if (userInfoString != null && userInfoString.isNotEmpty) {
        final userInfo = jsonDecode(userInfoString);
        final email = userInfo['email'];

        if (email != null && email.isNotEmpty) {
          setState(() {
            _emailController.text = email;
          });
        }
      }
    } catch (e) {
      print('Error loading user email: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final contact = ContactModel(
        name: _nameController.text,
        email: _emailController.text,
        subject: _subjectController.text,
        message: _messageController.text,
        category: _selectedCategory,
      );

      final contactViewModel =
          Provider.of<ContactViewModel>(context, listen: false);
      contactViewModel.submitContactForm(context, contact);

      // Reset form fields except email
      _nameController.clear();
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _selectedCategory = 'General Inquiry';
      });
    }
  }

  Widget _buildContactInfo(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                content,
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactViewModel = Provider.of<ContactViewModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Information Card (restored)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  _buildContactInfo(
                      Icons.email, 'Email', 'fitlifetech776@gmail.com'),
                  const SizedBox(height: 8),
                  _buildContactInfo(
                    Icons.location_on,
                    'Address',
                    'Beatrice Shilling Building - Coventry University, 5 Gulson Rd, Coventry CV1 5JH, UK',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Contact Form Card (restored subject field)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Send us a Message',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email field (read-only)
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        hintText: 'Your registered email will be used',
                        helperText:
                            'This field is pre-filled with your account email',
                      ),
                      readOnly: true, // Make it read-only
                      enabled: false, // Disable the field
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Subject field (restored)
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.subject),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      value: _selectedCategory,
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Message Field
                    TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your message';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: contactViewModel.isSubmitting
                            ? null
                            : () => _submitForm(context),
                        icon: const Icon(Icons.send),
                        label: contactViewModel.isSubmitting
                            ? const Text("Sending...")
                            : const Text("Send Message"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
