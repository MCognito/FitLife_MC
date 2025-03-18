import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final String? avatarUrl;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.email,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child:
                avatarUrl == null ? const Icon(Icons.person, size: 50) : null,
          ),
          const SizedBox(height: 16),

          // Username
          Text(
            username,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          // Email
          Text(
            email,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
