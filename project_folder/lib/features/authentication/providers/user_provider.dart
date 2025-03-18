import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user_model.dart';

// Provider to store the current user
final userProvider = StateProvider<UserModel?>((ref) => null);

// Provider to get the current user's ID
final userIdProvider = Provider<String>((ref) {
  final user = ref.watch(userProvider);
  // Return the user ID if available, otherwise return a default ID for development
  return user?.id ?? '67bc7fa4ec8d63256bdb94b8';
});
