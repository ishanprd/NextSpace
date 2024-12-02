import 'package:flutter/material.dart';
import 'package:nextspace/service/auth_service.dart';

class SpaceSetting extends StatefulWidget {
  const SpaceSetting({super.key});

  @override
  State<SpaceSetting> createState() => _SpaceSettingState();
}

class _SpaceSettingState extends State<SpaceSetting> {
  AuthService auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context,
                '/space_owner'); // Navigates back to the previous screen
          },
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          const SectionTitle(title: 'Account'),
          SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit profile',
            onTap: () {
              Navigator.pushNamed(context, '/edit_profile');
            },
          ),

          SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          SettingsTile(
            icon: Icons.feedback_outlined,
            title: 'Feedbacks',
            onTap: () {
              Navigator.pushNamed(context, '/feedback');
            },
          ),

          // Support & About Section
          const SectionTitle(title: 'Support & About'),

          SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.info_outline,
            title: 'Terms and Policies',
            onTap: () {},
          ),

          // Cache & Cellular Section

          // Actions Section
          const SectionTitle(title: 'Actions'),
          SettingsTile(
            icon: Icons.report_problem_outlined,
            title: 'Report a problem',
            onTap: () {},
          ),

          SettingsTile(
            icon: Icons.logout,
            title: 'Log out',
            onTap: () {
              auth.signOut(context);
            },
          ),
        ],
      ),
    );
  }
}

// Section Title Widget
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

// Settings Tile Widget
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}