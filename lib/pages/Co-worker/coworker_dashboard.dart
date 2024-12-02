import 'package:flutter/material.dart';

class CoworkerDashboard extends StatefulWidget {
  const CoworkerDashboard({super.key});

  @override
  State<CoworkerDashboard> createState() => _CoworkerDashboardState();
}

class _CoworkerDashboardState extends State<CoworkerDashboard> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Coworker dashboard")),
    );
  }
}
