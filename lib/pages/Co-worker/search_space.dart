import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchSpace extends StatefulWidget {
  const SearchSpace({super.key});

  @override
  State<SearchSpace> createState() => _SearchSpaceState();
}

class _SearchSpaceState extends State<SearchSpace> {
  late GoogleMapController _mapController;
  Map<String, dynamic>?
      selectedSpace; // To store details of the selected space.
  List<Map<String, dynamic>> spaces = []; // Dynamic list for spaces
  bool isLoading = true;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    _fetchSpaces(); // Fetch spaces from Firebase
  }

  // Fetch spaces from Firebase
  Future<void> _fetchSpaces() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('spaces').get();
      final fetchedSpaces = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['spaceName'],
          'description': data['description'],
          'price': 'Rs. ${data['hoursPrice']} / Hour',
          'rating': '4.5', // You can modify if ratings exist in Firebase
          'latitude': double.parse(data['location'].split(',')[0]),
          'longitude': double.parse(data['location'].split(',')[1]),
          'image': data['imagePath'], // Ensure this is a valid image URL
          'amenities': data['selectedAmenities'],
        };
      }).toList();

      setState(() {
        spaces = fetchedSpaces;
        isLoading = false;
      });
    } catch (e) {
      // Handle errors (e.g., connection issues)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching spaces: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Search Space",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading spinner
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Google Map
                  SizedBox(
                    height: 300, // Fixed height for Google Map
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(27.6731, 85.3249), // Default location
                        zoom: 14,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      markers: _buildMarkers(),
                    ),
                  ),

                  // Space Details Section
                  if (selectedSpace != null)
                    _buildSpaceDetails(selectedSpace!)
                  else
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text("Tap on a marker to view details."),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  // Build markers for Google Map
  Set<Marker> _buildMarkers() {
    return spaces.map((space) {
      final base64Image = space['image'];

      if (base64Image.isNotEmpty) {
        try {
          imageBytes = base64Decode(base64Image); // Decode base64 image data
        } catch (e) {
          print('Error decoding base64: $e');
          imageBytes = null; // Handle decoding error
        }
      } //
      return Marker(
        markerId: MarkerId(space['id']),
        position: LatLng(space['latitude'], space['longitude']),
        infoWindow: InfoWindow(
          title: space['name'],
          snippet: space['price'],
        ),
        onTap: () {
          setState(() {
            selectedSpace = space; // Update selected space details
          });
        },
      );
    }).toSet();
  }

  // Build space details UI
  Widget _buildSpaceDetails(Map<String, dynamic> space) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: imageBytes != null
                ? Image.memory(
                    imageBytes!, // Use MemoryImage to display byte data
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  )
                : Image.asset(
                    'assets/userprofile.jpg', // Fallback to an asset image
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  space['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(space['description']),
                const SizedBox(height: 8),

                // Price
                Text(
                  space['price'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),

                // Amenities
                Text(
                  "Amenities: ${space['amenities'].join(', ')}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),

                // Book Now Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    Navigator.pushNamed(context, '/view_space_for_book',
                        arguments: space['id']);
                  },
                  child: const Text(
                    "View Space",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
