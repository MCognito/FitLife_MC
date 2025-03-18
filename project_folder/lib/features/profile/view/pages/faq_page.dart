import 'package:flutter/material.dart';
import '../pages/profile_page.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page title
          Text(
            'Frequently Asked Questions',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers to common questions about FitLife',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // FAQ items
          _buildFAQItem(
            context,
            'How do I create a workout plan?',
            'To create a workout plan, go to the Home tab and tap on the "+" button. '
                'From there, you can select exercises, set repetitions, and save your custom workout.',
          ),

          _buildFAQItem(
            context,
            'Can I track my progress over time?',
            'Yes! FitLife allows you to track your progress through the Profile section. '
                'You can view your workout history, weight changes, and other metrics to see how '
                'you\'re improving over time.',
          ),

          _buildFAQItem(
            context,
            'How do I change my profile information?',
            'You can update your profile information by going to the Profile tab, selecting '
                'the "Profile" option, and tapping on the "Edit Profile" button.',
          ),

          _buildFAQItem(
            context,
            'Is my data secure?',
            'Yes, we take data security seriously. Your personal information and fitness data '
                'are encrypted and stored securely. We do not share your information with third parties '
                'without your consent.',
          ),

          _buildFAQItem(
            context,
            'How do I reset my password?',
            'To reset your password, go to the login screen and tap on "Forgot Password". '
                'Enter your email address, and we\'ll send you instructions to reset your password.',
          ),

          _buildFAQItem(
            context,
            'Can I use FitLife offline?',
            'Some features of FitLife are available offline, such as viewing your saved workouts. '
                'However, syncing data and accessing the exercise library requires an internet connection.',
          ),

          _buildFAQItem(
            context,
            'How do I contact support?',
            'You can contact our support team through the "Contact" section in your profile. '
                'We aim to respond to all inquiries within 24-48 hours.',
          ),

          const SizedBox(height: 24),

          // Didn't find your answer section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Didn\'t find your answer?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Contact our support team for further assistance.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Find the ProfilePageState and use _selectOption to navigate to Contact
                    final ProfilePageState? profileState =
                        context.findAncestorStateOfType<ProfilePageState>();

                    if (profileState != null) {
                      // Use the navigateTo method to navigate to Contact
                      profileState.navigateTo('Contact');
                    } else {
                      // Fallback message if ProfilePageState can't be found
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Unable to navigate to Contact page. Please use the menu.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: const Text('Contact Support'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
