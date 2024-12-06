import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddDetail extends StatefulWidget {
  const AddDetail({super.key});

  @override
  State<AddDetail> createState() => _AddDetailState();
}

class _AddDetailState extends State<AddDetail> {
  // Controllers for Date and Time
  TextEditingController dateController = TextEditingController();
  TextEditingController fromTimeController = TextEditingController();
  TextEditingController toTimeController = TextEditingController();

  // Selected radio button value for booking method
  String? selectedMethod = 'Online';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final spaceId = ModalRoute.of(context)?.settings.arguments as String?;
      if (spaceId != null) {
        _fetchSpaceData(spaceId);
      } else {
        print('No spaceId provided');
      }
    });
  }

  // Space details
  String spaceid = '';
  String spaceName = '';
  String placeName = '';
  double price = 0.0;

  // Date and Time selection variables
  DateTime? selectedDate;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = '${picked.toLocal()}'.split(' ')[0];
      });
    }
  }

  // Function to show time picker
  Future<void> _selectTime(
    BuildContext context,
    bool isFromTime,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFromTime) {
          fromTime = picked;
          fromTimeController.text = picked.format(context);
        } else {
          toTime = picked;
          toTimeController.text = picked.format(context);
        }
      });
    }
  }

  // Function to calculate duration in hours
  double _calculateHours() {
    if (fromTime == null || toTime == null) return 0.0;

    final from = Duration(hours: fromTime!.hour, minutes: fromTime!.minute);
    final to = Duration(hours: toTime!.hour, minutes: toTime!.minute);

    double hours = (to.inMinutes - from.inMinutes) / 60.0;
    return hours > 0 ? hours : 0.0; // Prevent negative durations
  }

  void _fetchSpaceData(String spaceId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('spaces')
          .doc(spaceId)
          .get();

      if (docSnapshot.exists) {
        var spaceData = docSnapshot.data() as Map<String, dynamic>;

        setState(() {
          spaceid = spaceId;
          spaceName = spaceData['spaceName'] ?? '';
          placeName = spaceData['city'] ?? '';
          var priceValue = spaceData['hoursPrice'];
          price = (priceValue is String)
              ? double.tryParse(priceValue) ?? 0.0
              : priceValue?.toDouble() ?? 0.0;
        });
      } else {
        throw Exception('Space not found');
      }
    } catch (e) {
      print('Error fetching space data: $e');
    }
  }

  // Function to handle save action
  void _saveBooking() async {
    if (selectedDate == null || fromTime == null || toTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time range.')),
      );
      return;
    }

    double hours = _calculateHours();
    if (hours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid time range selected.')),
      );
      return;
    }

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final bookingData = {
        'spaceName': spaceName,
        'price': price,
        'city': placeName,
        'spaceId': spaceid,
        'userId': userId,
        'paymentType': selectedMethod,
        'date': selectedDate!.toIso8601String(),
        'hours': hours,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (selectedMethod == 'Esewa') {
        Navigator.pushNamed(
          context,
          '/payments',
          arguments: bookingData,
        );
      } else if (selectedMethod == 'Cash') {
        await FirebaseFirestore.instance
            .collection('bookings')
            .add(bookingData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking saved successfully!')),
        );
        Navigator.pushNamed(context, '/coworker');
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
        title: const Text('Add Booking Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Space Name: $spaceName'),
              Text('Place: $placeName'),
              Text('Price: \$${price.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              const Text(
                'Select Booking Method',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _saveBooking,
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Cancel'),
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
