import 'package:cloud_firestore/cloud_firestore.dart';

class Space {
  String spaceName;
  String description;
  String hoursPrice;
  String city;
  String location;
  String? imagePath;
  List<String> selectedAmenities;
  String roomType;
  String ownerId;
  String status;
  Timestamp createdAt;

  Space({
    required this.spaceName,
    required this.description,
    required this.hoursPrice,
    required this.city,
    required this.location,
    this.imagePath,
    required this.selectedAmenities,
    required this.roomType,
    required this.ownerId,
    required this.status,
    required this.createdAt,
  });

  // Convert the Space object to a Map to save to Firestore
  Map<String, dynamic> toMap() {
    return {
      'spaceName': spaceName,
      'description': description,
      'hoursPrice': hoursPrice,
      'city': city,
      'location': location,
      'imagePath': imagePath,
      'selectedAmenities': selectedAmenities,
      'roomType': roomType,
      'ownerId': ownerId,
      'status': status,
      'createdAt': createdAt,
    };
  }

  // Create a Space object from a Firestore document
  factory Space.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Space(
      spaceName: data['spaceName'],
      description: data['description'],
      hoursPrice: data['hoursPrice'],
      city: data['city'],
      location: data['location'],
      imagePath: data['imagePath'],
      selectedAmenities: List<String>.from(data['selectedAmenities']),
      roomType: data['roomType'],
      ownerId: data['ownerId'],
      status: data['status'],
      createdAt: data['createdAt'],
    );
  }
}
