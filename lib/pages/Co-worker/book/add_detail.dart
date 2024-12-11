// Import necessary packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// StatefulWidget to add booking details
class AddDetail extends StatefulWidget {
  const AddDetail({super.key});

  @override
  State<AddDetail> createState() => _AddDetailState();
}

class _AddDetailState extends State<AddDetail> {
  // Controllers to handle user input for date and time
  TextEditingController dateController = TextEditingController();
  TextEditingController fromTimeController = TextEditingController();
  TextEditingController toTimeController = TextEditingController();

  // Variable to store the selected booking method (Online or Cash)
  String? selectedMethod = 'Online';

  @override
  void initState() {
    super.initState();
    // Fetch space data once the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final spaceId = ModalRoute.of(context)?.settings.arguments as String?;
      if (spaceId != null) {
        _fetchSpaceData(spaceId); // Fetch space data if spaceId is provided
      } else {
        print('No spaceId provided');
      }
    });
  }

  // Space details variables
  String spaceid = '';
  String spaceName = '';
  String placeName = '';
  double price = 0.0;

  // Variables for selected date and time
  DateTime? selectedDate;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ??
          DateTime.now(), // Default to current date if no date selected
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd')
            .format(picked); // Format and set the selected date
      });
    }
  }

  // Function to show time picker
  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(), // Default to current time
    );
    if (picked != null) {
      setState(() {
        if (isFromTime) {
          fromTime = picked;
          fromTimeController.text =
              picked.format(context); // Format and set the 'from' time
        } else {
          toTime = picked;
          toTimeController.text =
              picked.format(context); // Format and set the 'to' time
        }
      });
    }
  }

  // Function to calculate duration between 'from' and 'to' time in hours
  double _calculateHours() {
    if (fromTime == null || toTime == null)
      return 0.0; // If times are not selected, return 0

    final from = Duration(hours: fromTime!.hour, minutes: fromTime!.minute);
    final to = Duration(hours: toTime!.hour, minutes: toTime!.minute);

    double hours = (to.inMinutes - from.inMinutes) /
        60.0; // Calculate the time difference in hours
    return hours > 0 ? hours : 0.0; // Prevent negative duration
  }

  // Function to fetch space data from Firestore
  void _fetchSpaceData(String spaceId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('spaces')
          .doc(spaceId)
          .get(); // Get space data from Firestore

      if (docSnapshot.exists) {
        var spaceData = docSnapshot.data() as Map<String, dynamic>;

        setState(() {
          spaceid = spaceId;
          spaceName = spaceData['spaceName'] ?? '';
          placeName = spaceData['city'] ?? '';
          var priceValue = spaceData['hoursPrice'];
          price = (priceValue is String)
              ? double.tryParse(priceValue) ??
                  0.0 // Handle string and numeric price values
              : priceValue?.toDouble() ?? 0.0;
        });
      } else {
        throw Exception('Space not found');
      }
    } catch (e) {
      print('Error fetching space data: $e');
    }
  }

  // Function to save booking data to Firestore
  void _saveBooking() async {
    // Check if all required fields are filled
    if (selectedDate == null || fromTime == null || toTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time range.')),
      );
      return;
    }

    double hours = _calculateHours(); // Calculate booking duration in hours
    if (hours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid time range selected.')),
      );
      return;
    }

    try {
      final userId =
          FirebaseAuth.instance.currentUser?.uid; // Get current user ID
      if (userId == null) {
        throw Exception('User not logged in');
      }
      double totalAmount = price * hours; // Calculate total amount

      final bookingData = {
        'spaceName': spaceName,
        'price': totalAmount.toStringAsFixed(2),
        'city': placeName,
        'spaceId': spaceid,
        'userId': userId,
        'paymentType': selectedMethod,
        'paymentStatus': 'Pending',
        'date': DateFormat('yyyy-MM-dd')
            .format(selectedDate!), // Use intl package to format the date
        'hours': hours.toStringAsFixed(2),
        'status': 'Pending',
        'transactionId': '',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // If payment method is Esewa, navigate to the payment page
      if (selectedMethod == 'Esewa') {
        Navigator.pushNamed(
          context,
          '/payments',
          arguments: bookingData,
        );
      } else if (selectedMethod == 'Cash') {
        // Otherwise, save the booking directly to Firestore
        await FirebaseFirestore.instance
            .collection('bookings')
            .add(bookingData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking saved successfully!')),
        );
        Navigator.pushNamed(context,
            '/coworker'); // Navigate to coworker page after successful booking
      }
    } catch (e) {
      print('Error saving booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to save booking. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Booking Details'), // Title for the screen
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel), // Cancel button to close the form
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Space Name: $spaceName', // Display space name
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text(
                'Place: $placeName', // Display place name
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text(
                'Rate: Rs ${price.toStringAsFixed(2)} per hour', // Display rate per hour
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              // Date and time input fields
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Select Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: fromTimeController,
                decoration: const InputDecoration(
                  labelText: 'Select From Time',
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () => _selectTime(context, true),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: toTimeController,
                decoration: const InputDecoration(
                  labelText: 'Select To Time',
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () => _selectTime(context, false),
              ),
              const SizedBox(height: 20),
              // Payment method selection
              const Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: const Text('Esewa'),
                leading: Radio<String>(
                  value: 'Esewa',
                  groupValue: selectedMethod,
                  onChanged: (value) => setState(() => selectedMethod = value),
                ),
              ),
              ListTile(
                title: const Text('Cash'),
                leading: Radio<String>(
                  value: 'Cash',
                  groupValue: selectedMethod,
                  onChanged: (value) => setState(() => selectedMethod = value),
                ),
              ),
              const SizedBox(height: 24),
              // Save and Cancel buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: _saveBooking, // Save booking on press
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context), // Cancel and go back
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
