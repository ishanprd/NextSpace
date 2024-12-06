import 'dart:typed_data';
import 'dart:convert'; // Needed for base64 decoding
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewSpace extends StatefulWidget {
  const ViewSpace({super.key});

  @override
  State<ViewSpace> createState() => _ViewSpaceState();
}

class _ViewSpaceState extends State<ViewSpace> {
  late Future<DocumentSnapshot> spaceData;
  LatLng? _spaceLocation; // To store the space's latitude and longitude
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    _fetchSpaceData();
  }

  // Fetch space data from Firebase Firestore
  void _fetchSpaceData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      spaceData = FirebaseFirestore.instance
          .collection('spaces')
          .where('ownerId', isEqualTo: user.uid) // Query space by ownerId
          .limit(1)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var space = querySnapshot.docs.first;
          // Extract location data (latitude and longitude) from the 'location' string
          var location = space['location'];

          if (location != null) {
            // Split the string by the comma to get latitude and longitude
            List<String> locationParts = location.split(',');
            if (locationParts.length == 2) {
              double latitude = double.tryParse(locationParts[0]) ?? 0.0;
              double longitude = double.tryParse(locationParts[1]) ?? 0.0;
              setState(() {
                _spaceLocation =
                    LatLng(latitude, longitude); // Set the location
              });
            } else {
              throw Exception('Invalid location format');
            }
          } else {
            throw Exception('Location not found');
          }
          return space;
        } else {
          throw Exception('Space not found');
        }
      });
    }
  }

  // Mapping amenities to icons
  IconData getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wi-fi':
        return Icons.wifi;
      case 'desk space':
        return Icons.desk;
      case 'meeting rooms':
        return Icons.business_center;
      case 'event space':
        return Icons.event;
      case 'air conditioning':
        return Icons.ac_unit;
      case 'elevator':
        return Icons.elevator;
      default:
        return Icons.help_outline; // Default icon for unknown amenities
    }
  }

  // Mapping room types to icons
  IconData getRoomTypeIcon(String roomType) {
    switch (roomType.toLowerCase()) {
      case 'private office':
        return Icons.lock; // Example icon for private office
      case 'meeting room':
        return Icons.business_center; // Icon for meeting room
      case 'event space':
        return Icons.event; // Icon for event space
      case 'hot desk':
        return Icons.hot_tub; // Icon for hot desk
      default:
        return Icons.help_outline; // Default icon for unknown room type
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: spaceData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No space found'));
          }

          var space = snapshot.data!;
          String spaceName = space['spaceName'] ?? 'Unknown Space';
          String description =
              space['description'] ?? 'No description available';
          List<String> amenities =
              List<String>.from(space['selectedAmenities'] ?? []);
          String price = space['monthlyPrice'] ?? '0';
          String roomType = space['roomType'] ?? '';

          final base64Image = space['imagePath'] ?? '';

          Uint8List? imageBytes;
          if (base64Image.isNotEmpty) {
            try {
              imageBytes =
                  base64Decode(base64Image); // Decode base64 image data
            } catch (e) {
              print('Error decoding base64: $e');
              imageBytes = null; // Handle decoding error
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                if (imageBytes != null)
                  SizedBox(
                    width: double
                        .infinity, // Set width to occupy the full available space
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.memory(
                        imageBytes,
                        fit: BoxFit
                            .cover, // You can change the BoxFit to control how the image fits
                      ), // Display image using Image.memory
                    ),
                  )
                else if (base64Image.isEmpty)
                  // If image is not base64, try loading from file path
                  _loadImageFromFile(space),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spaceName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.favorite, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  amenities.join(' • '),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. $price / Hours',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '4.9',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Space description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Facilities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: amenities.map((amenity) {
                    return _buildFacilityIcon(getAmenityIcon(amenity), amenity);
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Room Types',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildFacilityIcon(getRoomTypeIcon(roomType), roomType),
                  ],
                ),
                const SizedBox(height: 24),
                _spaceLocation == null
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _spaceLocation!,
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('spaceLocation'),
                              position: _spaceLocation!,
                            ),
                          },
                          onMapCreated: (GoogleMapController controller) {
                            mapController = controller;
                          },
                        ),
                      ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Add functionality for availability check
                    Navigator.pushNamed(context, '/edit_space');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Edit Space',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFacilityIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.blue),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Helper function to load image from file path
  Widget _loadImageFromFile(DocumentSnapshot space) {
    String imagePath = space['imagePath'] ?? '';
    if (imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        height: 200,
        width: double.infinity,
      );
    }
    return Container(); // Return empty container if no image found
  }
}
