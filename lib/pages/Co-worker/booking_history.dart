import 'package:flutter/material.dart';

class BookingHistory extends StatefulWidget {
  const BookingHistory({super.key});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  final List<Map<String, String>> bookingHistory = [
    {
      "title": "Luxury Suite",
      "date": "Dec 2, 2024",
      "status": "Confirmed",
      "price": "\$200",
    },
    {
      "title": "Deluxe Room",
      "date": "Nov 20, 2024",
      "status": "Cancelled",
      "price": "\$150",
    },
    {
      "title": "Executive Room",
      "date": "Nov 15, 2024",
      "status": "Completed",
      "price": "\$180",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Booking History",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: bookingHistory.length,
          itemBuilder: (context, index) {
            final booking = bookingHistory[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking["title"]!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Date: ${booking["date"]}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Status: ${booking["status"]}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: booking["status"] == "Cancelled"
                                ? Colors.red
                                : booking["status"] == "Confirmed"
                                    ? Colors.blue
                                    : Colors.green,
                          ),
                        ),
                        Text(
                          "Price: ${booking["price"]}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
