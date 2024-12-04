import 'package:flutter/material.dart';
import 'package:nextspace/service/auth_service.dart';

class CoWorkerSetting extends StatefulWidget {
  const CoWorkerSetting({super.key});

  @override
  State<CoWorkerSetting> createState() => _AdminSettingState();
}

class _AdminSettingState extends State<CoWorkerSetting> {
  AuthService auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // ignore: prefer_const_constructors
        title: Center(
          child: const Text(
            'Settings',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: ListView(
        children: [
          // Account Section
          const SectionTitle(title: 'Account'),
          SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit profile',
            onTap: () {
              Navigator.pushNamed(context, '/edit_admin_profile');
            },
          ),

          SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              Navigator.pushNamed(context, '/admin_notifications');
            },
          ),
          SettingsTile(
            icon: Icons.feedback_outlined,
            title: 'Issues and problems',
            onTap: () {
              Navigator.pushNamed(context, '/issues');
            },
          ),

          // Support & About Section
          const SectionTitle(title: 'Support & About'),

          SettingsTile(
            icon: Icons.info_outline,
            title: 'Terms and Policies',
            onTap: () {},
          ),
          const SectionTitle(title: 'Actions'),

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
