import 'dart:typed_data';
import 'dart:convert'; // Needed for base64 decoding
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewSpaceForBook extends StatefulWidget {
  const ViewSpaceForBook({super.key});

  @override
  State<ViewSpaceForBook> createState() => _ViewSpaceForBookState();
}

class _ViewSpaceForBookState extends State<ViewSpaceForBook> {
  late Future<DocumentSnapshot> spaceData;
  LatLng? _spaceLocation; // To store the space's latitude and longitude
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    // Delay the code execution to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final spaceId = ModalRoute.of(context)?.settings.arguments as String?;
      if (spaceId != null) {
        _fetchSpaceData(spaceId);
      } else {
        // Handle the case where the spaceId is not passed
        print('No spaceId provided');
      }
    });
  }

  // Fetch space data from Firebase Firestore
  void _fetchSpaceData(String spaceId) {
    spaceData = FirebaseFirestore.instance
        .collection('spaces')
        .doc(spaceId)
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        var space = docSnapshot;
        // Extract location data (latitude and longitude) from the 'location' string
        var location = space['location'];

        if (location != null) {
          // Split the string by the comma to get latitude and longitude
          List<String> locationParts = location.split(',');
          if (locationParts.length == 2) {
            double latitude = double.tryParse(locationParts[0]) ?? 0.0;
            double longitude = double.tryParse(locationParts[1]) ?? 0.0;
            setState(() {
              _spaceLocation = LatLng(latitude, longitude); // Set the location
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
      appBar: AppBar(),
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
          String spaceId = space.id;
          String spaceName = space['spaceName'] ?? 'Unknown Space';
          String description =
              space['description'] ?? 'No description available';
          List<String> amenities =
              List<String>.from(space['selectedAmenities'] ?? []);
          String price = space['hoursPrice'] ?? '0';
          // Check if roomType is a list or a single string
          List<String> roomTypes = (space['roomType'] is List)
              ? List<String>.from(space['roomType'] ?? [])
              : [space['roomType'] ?? 'Unknown'];

          String roomType = roomTypes.isNotEmpty ? roomTypes.first : 'Unknown';

          // If there's more than one room type, display only the first one.

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
                      ),
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
                      'Rp. $price / Month',
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
                  'Room Type', // Display only one room type
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFacilityIcon(getRoomTypeIcon(roomType), roomType),
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
                    Navigator.pushNamed(context, '/add_details',
                        arguments: spaceId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _loadImageFromFile(DocumentSnapshot space) {
    return space['imagePath'] != null
        ? Image.network(
            space['imagePath']!,
            fit: BoxFit.cover,
            height: 200, // Example height, adjust as needed
          )
        : const SizedBox.shrink(); // Placeholder when no image path is found
  }
}
