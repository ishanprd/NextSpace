// Import necessary packages
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:nextspace/Widget/dialog_box.dart';
import 'package:nextspace/static_value.dart';

// StatefulWidget for the payment page
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
      final arguments = ModalRoute.of(context)?.settings.arguments
          as Map<String, dynamic>?; // Fetch arguments passed to the page
      if (arguments != null) {
        setState(() {
          bookingData = arguments;
        });
      } else {
        // Default booking data in case no arguments are passed
        bookingData = {
          'date': '2024-12-06',
          'hours': '2.00', // Time is a string here
          'spaceName': 'Conference Room A',
          'price': '20.0', // Price is now a string for consistency
        };
      }
    });
  }

  // Function to save booking data after successful payment
  Future<void> _saveBooking(EsewaPaymentSuccessResult paymentData) async {
    try {
      final booking = {
        'spaceName': bookingData['spaceName'],
        'price': bookingData['price'],
        'city': bookingData['city'],
        'spaceId': bookingData['spaceId'],
        'userId': bookingData['userId'],
        'paymentType': bookingData['paymentType'],
        'paymentStatus': 'Success',
        'date': bookingData['date'], // Use intl here
        'hours': bookingData['hours'],
        'status': 'Pending',
        'transactionId': paymentData.productId,
        'createdAt': bookingData['createdAt'],
      };

      await FirebaseFirestore.instance
          .collection('bookings')
          .add(booking); // Save the booking data to Firestore
    } catch (e) {
      print('Error saving booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to save booking. Please try again.')),
      );
    }
  }

  // Function to handle successful payment completion
  Future<void> _payment_complete(EsewaPaymentSuccessResult paymentData) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child:
              CircularProgressIndicator(), // Show loading indicator while saving
        ),
      );

      // Save payment details to Firestore
      final paymentCollection =
          FirebaseFirestore.instance.collection('payments');
      await paymentCollection.add({
        'transaction_id': paymentData.productId,
        'productName': paymentData.productName, // Transaction ID from Esewa
        'amount': paymentData.totalAmount, // Payment amount
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(), // Timestamp
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogBox(
            icon: Icons.payment,
            color: Colors.green,
            title: "Payment completed successfully",
            onOkPressed: () {
              Navigator.pushReplacementNamed(context,
                  '/coworker'); // Navigate to coworker page after success
            },
          );
        },
      );
    } catch (e) {
      // Handle payment failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    }
  }

  // Function to generate a random string for product ID
  String generateRandomString(int length) {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }

  // Function to initiate the Esewa payment process
  void esewapaymentcall(String spaceName, String price) {
    try {
      // Initialize payment with Esewa SDK
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test,
          clientId: StaticValue.CLIENT_ID,
          secretId: StaticValue.SECRET_KEY,
        ),
        esewaPayment: EsewaPayment(
          productId: generateRandomString(30), // Generate unique product ID
          productName: 'Kumud Space',
          productPrice: price,
          callbackUrl: '',
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult data) {
          debugPrint(":::SUCCESS::: => $data");
          _payment_complete(data); // Handle successful payment
          _saveBooking(data); // Save booking data
        },
        onPaymentFailure: (data) {
          debugPrint(":::FAILURE::: => $data");
        },
        onPaymentCancellation: (data) {
          debugPrint(":::CANCELLATION::: => $data");
        },
      );
    } on Exception catch (e) {
      debugPrint("EXCEPTION : ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = bookingData['date'];
    final timeString = bookingData['hours'] ?? '0.0';
    final double time = double.tryParse(timeString) ?? 0.0; // Safely parse time
    final spaceName = bookingData['spaceName'];

    // Parse pricePerHour as double, even if it's passed as String
    final priceString = bookingData['price'] ?? '0.0';
    final double pricePerHour = double.tryParse(priceString) ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Payment'), // Title for the page
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display date and time details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: $date',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total: $time Hours',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment Method section
            const Text(
              'Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Image.asset(
                'assets/esewa.png', // Add an appropriate asset for Esewa.
                height: 40,
              ),
              title: const Text('Esewa'),
              subtitle: const Text('Secure and easy payment'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const Divider(),

            // Space details section
            const Text(
              'Space Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.space_dashboard_rounded, size: 40),
              title: Text(spaceName),
              subtitle: Text(
                'Total Amount: Rs ${pricePerHour.toStringAsFixed(2)}', // Display the total amount
              ),
            ),
            const Spacer(),

            // Pay Now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  esewapaymentcall(
                      spaceName, priceString); // Call payment function
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(
                  'Pay Now (Rs ${pricePerHour.toStringAsFixed(2)})',
                  style: TextStyle(
                      color: Colors.white), // Display total amount on button
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
