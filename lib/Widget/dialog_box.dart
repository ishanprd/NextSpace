import 'package:flutter/material.dart';

class DialogBox extends StatelessWidget {
  // Icon to be displayed at the top of the dialog
  final IconData icon;

  // Title text for the dialog
  final String title;

  // Color of the icon
  final Color color;

  // Callback function triggered when the "OK" button is pressed
  final VoidCallback onOkPressed;

  const DialogBox({
    super.key,
    required this.icon, // Required parameter for the icon
    required this.title, // Required parameter for the title
    required this.color, // Required parameter for the color
    required this.onOkPressed, // Required parameter for the callback function
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12.0), // Rounded corners for the dialog
      ),
      child: Padding(
        padding: const EdgeInsets.all(
            20.0), // Padding around the content of the dialog
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Minimize the column size to fit content
          children: [
            // Icon widget displaying the icon passed to the dialog
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 20), // Spacer between icon and title
            // Title text widget
            Text(
              title,
              textAlign: TextAlign.center, // Center-align the title text
              style: const TextStyle(
                fontSize: 18, // Font size for title
                fontWeight: FontWeight.bold, // Bold font style
              ),
            ),
            const SizedBox(height: 20), // Spacer between title and button
            // Elevated button for user action
            ElevatedButton(
              onPressed: onOkPressed, // Action triggered on button press
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green), // Button background color
              child: const Text(
                'OK', // Button label
                style: TextStyle(color: Colors.white), // Button text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
