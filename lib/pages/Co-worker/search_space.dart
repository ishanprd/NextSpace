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
  Map<String, dynamic>?
      selectedSpace; // To store details of the selected space.
  List<Map<String, dynamic>> spaces =
      []; // Dynamic list to hold the spaces data
  bool isLoading = true; // State to track loading status
  Uint8List? imageBytes; // Store decoded image data (if available)

  @override
  void initState() {
    super.initState();
    _fetchSpaces(); // Fetch space data from Firebase when the page initializes
  }

  // Function to fetch spaces from Firestore
  Future<void> _fetchSpaces() async {
    try {
      // Query Firestore collection 'spaces'
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('spaces').get();
      // Map the fetched documents into a list of space data
      final fetchedSpaces = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, // Space document ID
          'name': data['spaceName'], // Space name
          'description': data['description'], // Space description
          'price': 'Rs. ${data['hoursPrice']} / Hour', // Space price per hour
          'rating': '4.5', // Example rating, can be dynamic based on data
          'latitude': double.parse(
              data['location'].split(',')[0]), // Latitude from location string
          'longitude': double.parse(
              data['location'].split(',')[1]), // Longitude from location string
          'image': data['imagePath'], // Image path (base64 or URL)
          'amenities': data['selectedAmenities'], // Selected amenities
        };
      }).toList();

      setState(() {
        spaces = fetchedSpaces; // Update the state with the fetched spaces
        isLoading = false; // Set loading state to false after data is fetched
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
        automaticallyImplyLeading: false, // Disable back button in the app bar
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner while fetching data
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Google Map displaying the spaces' locations
                  SizedBox(
                    height: 300, // Fixed height for the Google Map widget
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target:
                            LatLng(27.6731, 85.3249), // Default map location
                        zoom: 14, // Zoom level
                      ),
                      onMapCreated:
                          (controller) {}, // Placeholder for any actions on map creation
                      markers:
                          _buildMarkers(), // Set the markers for spaces on the map
                    ),
                  ),

                  // Space Details Section (only visible if a space is selected)
                  if (selectedSpace != null)
                    _buildSpaceDetails(selectedSpace!) // Display space details
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

  // Function to build markers for Google Map based on the fetched spaces
  Set<Marker> _buildMarkers() {
    return spaces.map((space) {
      final base64Image = space['image']; // Get base64 image for the space

      // Decode the base64 image string into bytes
      if (base64Image.isNotEmpty) {
        try {
          imageBytes = base64Decode(base64Image); // Decode base64 image data
        } catch (e) {
          print('Error decoding base64: $e'); // Handle decoding errors
          imageBytes = null; // If error occurs, set imageBytes to null
        }
      }

      // Return a marker for the space on the map
      return Marker(
        markerId: MarkerId(space['id']), // Unique marker ID
        position: LatLng(
            space['latitude'], space['longitude']), // Marker position on map
        infoWindow: InfoWindow(
          title: space['name'], // Marker info window title (space name)
          snippet: space['price'], // Marker info window snippet (price)
        ),
        onTap: () {
          setState(() {
            selectedSpace =
                space; // Update selected space when marker is tapped
          });
        },
      );
    }).toSet(); // Return a set of markers
  }

  // Function to build space details UI when a space is selected
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
          // Image Section (display either decoded image or fallback to asset image)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: imageBytes != null
                ? Image.memory(
                    imageBytes!, // Display decoded base64 image
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  )
                : Image.asset(
                    'assets/userprofile.jpg', // Fallback image if no base64 data
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
                // Space name
                Text(
                  space['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Space description
                Text(space['description']),
                const SizedBox(height: 8),

                // Space price
                Text(
                  space['price'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),

                // Space amenities
                Text(
                  "Amenities: ${space['amenities'].join(', ')}", // List amenities
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),

                // Button to view space
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    Navigator.pushNamed(context, '/view_space_for_book',
                        arguments: space[
                            'id']); // Navigate to booking page with space ID
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
