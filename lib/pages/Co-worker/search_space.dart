import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchSpace extends StatefulWidget {
  const SearchSpace({super.key});

  @override
  State<SearchSpace> createState() => _SearchSpaceState();
}

class _SearchSpaceState extends State<SearchSpace> {
  late GoogleMapController _mapController;
  Map<String, dynamic>?
      selectedSpace; // To store details of the selected space.

  // Dummy data for spaces
  final List<Map<String, dynamic>> spaces = [
    {
      'id': '1',
      'image': 'assets/background.jpg',
      'name': 'Workpair Co',
      'description': 'WiFi · Coffee · Meeting Room',
      'price': 'Rp. 125.000 / Hour',
      'rating': '4.9',
      'latitude': -6.200000,
      'longitude': 106.816666,
    },
    {
      'id': '2',
      'image': 'assets/background.jpg',
      'name': 'Office Spot',
      'description': 'WiFi · Quiet Zone · Meeting Room',
      'price': 'Rp. 100.000 / Hour',
      'rating': '4.8',
      'latitude': -6.210000,
      'longitude': 106.825000,
    },
  ];

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
      body: SingleChildScrollView(
        // Add SingleChildScrollView to make it scrollable
        child: Column(
          children: [
            // Google Map
            Container(
              height: 300, // Fixed height for Google Map
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-6.200000, 106.816666),
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
      return Marker(
        markerId: MarkerId(space['id']),
        position: LatLng(space['latitude'], space['longitude']),
        infoWindow: InfoWindow(
          title: space['name'],
          snippet: space['description'],
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
            child: Image.asset(
              space['image'], // Ensure the correct image path is provided
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
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

                // Rating
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(space['rating']),
                  ],
                ),
                const SizedBox(height: 16),

                // Book Now Button
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )),
                  ),
                  onPressed: () {
                    // Add booking logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Booked ${space['name']}"),
                      ),
                    );
                  },
                  child: const Text(
                    "Book Now",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
