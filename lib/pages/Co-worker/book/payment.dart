import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Map<String, dynamic> bookingData; // Variable to hold booking data

  @override
  void initState() {
    super.initState();
    // Fetching booking data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        setState(() {
          bookingData = arguments;
        });
      } else {
        // Default booking data in case no arguments are passed
        bookingData = {
          'date': '2024-12-06',
          'time': '10:00 AM',
          'spaceName': 'Conference Room A',
          'price': 20.0, // Price per hour
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loader until bookingData is available
    final date = bookingData['date'];
    final time = bookingData['hours'];
    final spaceName = bookingData['spaceName'];
    final pricePerHour = bookingData['price'];
    final totalPrice = pricePerHour * time;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: $date',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Time: $time Hours',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment Method
            const Text(
              'Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Image.asset(
                'esewa.png', // Add an appropriate asset for Esewa.
                height: 40,
              ),
              title: const Text('Esewa'),
              subtitle: const Text('Secure and easy payment'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const Divider(),

            // Space Details
            const Text(
              'Space Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.meeting_room, size: 40),
              title: Text(spaceName),
              subtitle: Text('Rate: Rs${pricePerHour.toStringAsFixed(2)}/hour'),
            ),
            const Spacer(),

            // Pay Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implement payment logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment Successful!')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text('Pay Now (Rs${totalPrice.toStringAsFixed(2)})'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
