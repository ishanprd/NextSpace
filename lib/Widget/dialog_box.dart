import 'package:flutter/material.dart';

class DialogBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onOkPressed;

  const DialogBox({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onOkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onOkPressed,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'OK', style: TextStyle(color: Colors.white),
                // Text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
