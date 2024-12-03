import 'package:flutter/material.dart';

class AdminNotification extends StatefulWidget {
  const AdminNotification({super.key});

  @override
  State<AdminNotification> createState() => _AdminNotificationState();
}

class _AdminNotificationState extends State<AdminNotification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification"),
      ),
      body: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AdminNotification title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'There is no one who loves pain itself, who seeks after it and wants to have it, simply because it is pain.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  // Close Adminnotification logic can go here
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
