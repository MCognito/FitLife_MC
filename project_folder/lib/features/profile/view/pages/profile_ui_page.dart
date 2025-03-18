import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../../service/profile_service.dart';
import '../../service/streak_service.dart';
import '../../models/user_profile.dart';
import 'edit_profile_page.dart';
import 'package:intl/intl.dart';
import 'profile_logs_page.dart';
import '../../service/user_score_service.dart';
import '../../models/user_score.dart';
import 'dart:async';

class ProfileUIPage extends StatefulWidget {
  const ProfileUIPage({super.key});

  @override
  State<ProfileUIPage> createState() => _ProfileUIPageState();
}

class _ProfileUIPageState extends State<ProfileUIPage> {
  final ProfileService _profileService = ProfileService();
  final StreakService _streakService = StreakService();
  final UserScoreService _userScoreService = UserScoreService();
  bool _isLoading = true;
  String? _errorMessage;
  UserProfile? _userProfile;
  Map<String, dynamic> _streakInfo = {
    'currentStreak': 0,
    'longestStreak': 0,
    'lastActivityDate': null,
    'inGracePeriod': false,
    'gracePeriodHours': 24,
    'minimumStepsThreshold': 3000
  };
  int _userLevel = 1;
  UserScore? _userScore;
  late Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadStreakInfo();
    _loadUserScore();

    // Set up a timer to refresh the user score periodically
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadUserScore();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when the page becomes visible
    _loadUserScore();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get user info first (username and email)
      final userInfo = await _profileService.getUserInfo();

      // Then get the full profile
      final profile = await _profileService.getUserProfile();

      if (!mounted) return;

      setState(() {
        // Create a merged profile with user info and profile data
        _userProfile = profile.copyWith(
          username: userInfo['username'] ?? 'User',
          email: userInfo['email'] ?? 'user@example.com',
        );
        _isLoading = false;
      });
    } catch (e) {
      print("Error in _loadUserProfile: $e");

      if (!mounted) return;

      // Try to get just the user info if profile fails
      try {
        final userInfo = await _profileService.getUserInfo();

        if (!mounted) return;

        setState(() {
          // Create a basic profile with just user info
          _userProfile = UserProfile(
            userId: '',
            username: userInfo['username'] ?? 'User',
            email: userInfo['email'] ?? 'user@example.com',
            personalInfo: UserPersonalInfo(),
            fitnessStats: UserFitnessStats(),
            preferences: UserPreferences(),
          );
          _isLoading = false;
        });
      } catch (userInfoError) {
        if (!mounted) return;

        setState(() {
          _errorMessage = 'Failed to load profile: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStreakInfo() async {
    try {
      print("[PROFILE] Loading streak info");

      // Set a timeout for the streak info request
      final streakInfo = await _streakService
          .getUserStreakInfo()
          .timeout(const Duration(seconds: 5), onTimeout: () {
        print("[PROFILE] Streak info request timed out");
        return {
          'currentStreak': 0,
          'longestStreak': 0,
          'lastActivityDate': null,
          'inGracePeriod': false,
          'gracePeriodHours': 24,
          'minimumStepsThreshold': 3000
        };
      });

      print("[PROFILE] Streak info loaded: $streakInfo");

      if (mounted) {
        setState(() {
          // Ensure we have default values for all required fields
          _streakInfo = {
            'currentStreak': streakInfo['currentStreak'] ?? 0,
            'longestStreak': streakInfo['longestStreak'] ?? 0,
            'lastActivityDate': streakInfo['lastActivityDate'],
            'inGracePeriod': streakInfo['inGracePeriod'] ?? false,
            'gracePeriodHours': streakInfo['gracePeriodHours'] ?? 24,
            'minimumStepsThreshold':
                streakInfo['minimumStepsThreshold'] ?? 3000,
          };
          print(
              "[PROFILE] Updated streak info in UI: currentStreak=${_streakInfo['currentStreak']}, longestStreak=${_streakInfo['longestStreak']}");
        });
      }
    } catch (e) {
      print("[PROFILE] Error loading streak info: $e");
      // Set default values in case of error
      if (mounted) {
        setState(() {
          _streakInfo = {
            'currentStreak': 0,
            'longestStreak': 0,
            'lastActivityDate': null,
            'inGracePeriod': false,
            'gracePeriodHours': 24,
            'minimumStepsThreshold': 3000
          };
        });
      }
    }
  }

  Future<void> _loadUserScore() async {
    if (!mounted) return;

    try {
      final scoreData = await _userScoreService.getUserScore();

      if (!mounted) return;

      setState(() {
        _userScore = scoreData;
      });
    } catch (e) {
      print("Error loading user score: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadUserProfile();
              _loadStreakInfo();
              _loadUserScore();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile refreshed'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _userProfile == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_off,
                            color: Colors.orange,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Profile Not Available',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              'Unable to load your profile. Please try again.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadUserProfile,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile header with user info
                            _buildProfileHeader(),

                            const SizedBox(height: 24),

                            // Streak Information
                            _buildSimpleStreakCard(),

                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Account Information Section
                            Text(
                              'Account Information',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),

                            // Account information fields
                            _buildSimpleInfoCard([
                              _buildSimpleInfoRow(
                                  'Username', _userProfile!.username),
                              _buildSimpleInfoRow('Email', _userProfile!.email),
                              _buildSimpleInfoRow(
                                  'Member Since', _memberSince()),
                            ]),

                            const SizedBox(height: 24),

                            // Personal Information Section
                            Text(
                              'Personal Information',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),

                            // Personal information fields
                            _buildSimpleInfoCard([
                              _buildSimpleInfoRow('Age',
                                  _personalInfo().age?.toString() ?? 'Not set'),
                              _buildSimpleInfoRow(
                                  'Height',
                                  _personalInfo().height != null
                                      ? '${_personalInfo().height} cm'
                                      : 'Not set'),
                              _buildSimpleInfoRow('Gender',
                                  _personalInfo().gender ?? 'Not set'),
                              _buildSimpleInfoRow(
                                  'Date of Birth',
                                  _personalInfo().dateOfBirth != null
                                      ? DateFormat('yyyy-MM-dd')
                                          .format(_personalInfo().dateOfBirth!)
                                      : 'Not set'),
                            ]),

                            const SizedBox(height: 16),

                            // Edit Profile Button
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (mounted) {
                                    _navigateToEditProfile(context);
                                  }
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Profile'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Future<void> _navigateToEditProfile(BuildContext context) async {
    if (!mounted || !context.mounted) return;

    // Show a SnackBar message instead of navigating to the edit profile page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Profile editing will be implemented in a future update to comply with data protection regulations.'),
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Original code commented out for future implementation
    /*
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(profile: _userProfile!),
        ),
      );

      if (result == true && mounted) {
        // Profile was updated, reload the data
        _loadUserProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error navigating to edit profile: $e')),
        );
      }
    }
    */
  }

  Future<void> _navigateToLogsPage(BuildContext context) async {
    try {
      print("[PROFILE] Navigating to logs page");

      if (!mounted || !context.mounted) {
        print("[PROFILE] Context is no longer valid for navigation");
        return;
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileLogsPage(),
        ),
      );

      // If result is true, refresh the streak info
      if (result == true && mounted) {
        print("[PROFILE] Returned from logs page with refresh flag");
        await _loadStreakInfo();
      }
    } catch (e) {
      print("[PROFILE] Error navigating to logs page: $e");
      // Show error message if navigation fails
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error navigating to logs page. Please try again."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Simplified info card with fixed constraints
  Widget _buildSimpleInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  // Simplified info row with fixed constraints
  Widget _buildSimpleInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // Simplified streak card with fixed constraints
  Widget _buildSimpleStreakCard() {
    // Ensure we have default values for all required fields
    final currentStreak = _streakInfo['currentStreak'] ?? 0;
    final longestStreak = _streakInfo['longestStreak'] ?? 0;
    final inGracePeriod = _streakInfo['inGracePeriod'] ?? false;

    // Get streak message with error handling
    String streakMessage;
    try {
      streakMessage = _streakService.formatStreakMessage(_streakInfo);
    } catch (e) {
      print("[PROFILE] Error formatting streak message: $e");
      streakMessage = "Start your streak today by logging a workout or steps!";
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and refresh button
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activity Streak',
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      inGracePeriod
                          ? Icons.warning_amber_rounded
                          : Icons.local_fire_department,
                      color: inGracePeriod ? Colors.orange : Colors.red,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      onPressed: () {
                        _loadStreakInfo();
                        if (mounted && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Refreshing streak info...')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Streak stats
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildSimpleStreakStat('Current', currentStreak),
                const SizedBox(width: 16),
                _buildSimpleStreakStat('Longest', longestStreak),
              ],
            ),

            const SizedBox(height: 16),

            // Streak message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                streakMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),

            const SizedBox(height: 16),

            // Log activity button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (mounted && context.mounted) {
                    _navigateToLogsPage(context);
                  }
                },
                icon: const Icon(Icons.add_chart),
                label: const Text('Log Activity'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simplified streak stat with fixed constraints
  Widget _buildSimpleStreakStat(String label, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$value',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'days',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    _userProfile?.username.isNotEmpty == true
                        ? _userProfile!.username[0].toUpperCase()
                        : "U",
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: Text(
                              _userProfile?.username ?? "User",
                              style: Theme.of(context).textTheme.titleLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Lvl ${_userScore?.level ?? 1}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          _userProfile?.email ?? "Email not available",
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Score: ${_userScore?.totalScore ?? 0} pts",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_userScore != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "Level Progress",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        "${(_userScore!.levelProgress() * 100).toInt()}%",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  LinearProgressIndicator(
                                    value: _userScore!.levelProgress(),
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${_userScore!.pointsToNextLevel()} points to level ${_userScore!.level + 1}",
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Daily Points: ${_userScore!.dailyPoints}/300",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _memberSince() {
    String memberSince = 'Not available';
    try {
      if (_userProfile?.createdAt != null) {
        final dateFormat = DateFormat('MMMM yyyy');
        memberSince = dateFormat.format(_userProfile!.createdAt!);
      }
    } catch (e) {
      print('Error formatting date: $e');
    }
    return memberSince;
  }

  UserPersonalInfo _personalInfo() {
    return _userProfile!.personalInfo;
  }
}
