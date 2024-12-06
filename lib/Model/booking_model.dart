import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  String? id; // Firestore document ID
  final String spaceName;
  final double price;
  final String city;
  final String spaceId;
  final String userId;
  final String paymentType;
  final DateTime date;
  final String hours;
  final String status;
  final Timestamp? createdAt;

  Booking({
    this.id,
    required this.spaceName,
    required this.price,
    required this.city,
    required this.spaceId,
    required this.userId,
    required this.paymentType,
    required this.date,
    required this.hours,
    required this.status,
    this.createdAt,
  });

  // Convert a Firestore document to a Booking object
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      spaceName: data['spaceName'],
      price: (data['price'] as num).toDouble(),
      city: data['city'],
      spaceId: data['spaceId'],
      userId: data['userId'],
      paymentType: data['paymentType'],
      date: DateTime.parse(data['date']),
      hours: data['hours'],
      status: data['status'],
      createdAt: data['createdAt'],
    );
  }

  // Convert a Booking object to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'spaceName': spaceName,
      'price': price,
      'city': city,
      'spaceId': spaceId,
      'userId': userId,
      'paymentType': paymentType,
      'date': date.toIso8601String(),
      'hours': hours,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
