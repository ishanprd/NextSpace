import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CoworkerDashboard extends StatefulWidget {
  const CoworkerDashboard({super.key});

  @override
  State<CoworkerDashboard> createState() => _CoworkerDashboardState();
}

class _CoworkerDashboardState extends State<CoworkerDashboard> {
  final TextEditingController _searchController = TextEditingController();
  double _selectedPriceRange = 500.0; // Default price range
  String? _selectedRoomType;
  String? Name; // Changed to List<String>
  final List<String> _selectedAmenities =
      []; // Added to hold selected amenities
  List<Map<String, dynamic>> _filteredSpaces = [];
  String SpaceId = ' ';

  Uint8List? imageBytes;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Fetch data from Firestore on init
    _fetchSpaces();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      // Get the current signed-in user
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch the user document from Firestore using the user's UID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users') // Assuming you have a 'users' collection
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // Get the user data from the document as a Map
          var userData = userDoc.data() as Map<String, dynamic>;

          // Assign the fullName field from Firestore to the Name variable
          setState(() {
            Name = userData['fullName'];
          });

          ''; // Default to an empty string if not found
          // Optional: Print user's name for debugging
        } else {
          print("User document doesn't exist in Firestore.");
        }
      } else {
        print("No user is currently signed in.");
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  // Fetch spaces from Firestore
  Future<void> _fetchSpaces() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('spaces')
          .where('status', isEqualTo: 'Accepted')
          .get();

      final List<Map<String, dynamic>> spaces = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['spaceName'],
                'image': doc['imagePath'],
                'features': List<String>.from(doc['selectedAmenities']),
                'price': double.tryParse(doc['hoursPrice'].toString()) ?? 0.0,
                'type': doc['roomType'], // Ensure roomType is correctly handled
              })
          .toList();

      // Print the fetched spaces to check the data
      // print('Fetched spaces: $spaces');

      setState(() {
        _filteredSpaces = spaces;
      });
    } catch (e) {
      print('Error fetching coworking spaces: $e');
    }
  }

  // Apply filters
  void _applyFilters() {
    setState(() {
      // Re-fetch or reset the filtered spaces before applying the filter
      _filteredSpaces = _filteredSpaces.where((space) {
        // Search filter
        final matchesName = _searchController.text.isEmpty ||
            space['name']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        // Price range filter
        final matchesPrice =
            _selectedPriceRange == 0 || space['price'] <= _selectedPriceRange;

        // Room type filter
        final roomType = space['type'];
        final matchesRoomType =
            _selectedRoomType == null || _selectedRoomType == roomType;

        // Amenities filter
        final amenities = space['features'];
        final matchesAmenities = _selectedAmenities.isEmpty ||
            _selectedAmenities.every((amenity) => amenities.contains(amenity));

        return matchesName &&
            matchesPrice &&
            matchesRoomType &&
            matchesAmenities;
      }).toList();

      // Log if no spaces match the filter
      if (_filteredSpaces.isEmpty) {
        print('No spaces found matching the filters.');
      }
    });
  }

  // Build Room Type Filter Chip
  Widget _buildRoomTypeFilterChip(String label, StateSetter modalSetState) {
    final isSelected =
        _selectedRoomType == label; // Check if the label is the selected one
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        modalSetState(() {
          if (selected) {
            // Set the selected room type and ensure no other room type is selected
            _selectedRoomType = label;
          } else {
            // Deselect the room type
            _selectedRoomType = null;
          }
        });
        _applyFilters(); // Update the main widget state
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
    );
  }

  // Build Amenities Filter Chip
  Widget _buildAmenitiesFilterChip(String label, StateSetter modalSetState) {
    final isSelected = _selectedAmenities.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        modalSetState(() {
          if (selected) {
            _selectedAmenities.add(label);
          } else {
            _selectedAmenities.remove(label);
          }
        });
        _applyFilters(); // Update the main widget state
      },
      selectedColor: Colors.green.shade100,
      checkmarkColor: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Text
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  "Hi $Name , \nwhere you wanna work today?",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search cafe, entire place, room",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onSubmitted: (value) => _applyFilters(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.0),
                          ),
                        ),
                        builder: (BuildContext context) {
                          // Use StatefulBuilder to manage modal's internal state
                          return StatefulBuilder(
                            builder: (BuildContext context,
                                StateSetter modalSetState) {
                              return Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Filter Options",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Price Range Slider
                                    const Text(
                                      "Price Range",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Slider(
                                      value: _selectedPriceRange,
                                      min: 0,
                                      max: 10000, // Adjust as needed
                                      divisions: 100,
                                      label:
                                          'Rs. ${_selectedPriceRange.toInt()}',
                                      onChanged: (value) {
                                        // Use modalSetState for the modal-specific update
                                        modalSetState(() {
                                          _selectedPriceRange = value;
                                        });
                                        // Use setState to propagate filter changes to the main widget
                                        _applyFilters();
                                      },
                                    ),

                                    // Room Type Filter
                                    const SizedBox(height: 20),
                                    const Text(
                                      "Room Type",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Wrap(
                                      spacing: 10,
                                      children: [
                                        _buildRoomTypeFilterChip(
                                            "Private Room", modalSetState),
                                        _buildRoomTypeFilterChip(
                                            "Event Space", modalSetState),
                                        _buildRoomTypeFilterChip(
                                            "Meeting Room", modalSetState),
                                        _buildRoomTypeFilterChip(
                                            "Hot Desk", modalSetState),
                                      ],
                                    ),

                                    // Amenities Filter
                                    const SizedBox(height: 20),
                                    const Text(
                                      "Amenities",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Wrap(
                                      spacing: 10,
                                      children: [
                                        _buildAmenitiesFilterChip(
                                            "Wi-Fi", modalSetState),
                                        _buildAmenitiesFilterChip(
                                            "Air Conditioning", modalSetState),
                                        _buildAmenitiesFilterChip(
                                            "Desk Space", modalSetState),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filtered Spaces Section
              const Text(
                "Nearest spaces",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._filteredSpaces.map((space) {
                final base64Image = space['image'];

                if (base64Image.isNotEmpty) {
                  try {
                    imageBytes =
                        base64Decode(base64Image); // Decode base64 image data
                  } catch (e) {
                    print('Error decoding base64: $e');
                    imageBytes = null; // Set imageBytes to null on error
                  }
                }

                return _buildSpaceCard(
                  context,
                  space['id'],
                  space['name'],
                  space['price'],
                  space['type'],
                  space['features'], // Pass amenities here
                  imageBytes,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpaceCard(
    BuildContext context,
    String id,
    String spaceName,
    double price,
    String roomType,
    List<String> amenities,
    Uint8List? imageBytes,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/view_space_for_book', arguments: id);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with Heart Icon
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: imageBytes != null
                        ? Image.memory(
                            imageBytes,
                            height: 250,
                            width: 350,
                            fit: BoxFit.cover,
                          )
                        : const Placeholder(
                            fallbackHeight: 100, fallbackWidth: 100),
                  )
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                spaceName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Row(
                children: amenities.map((amenity) {
                  return Text(
                    ' $amenity ',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Price and Rating Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rs. ${price.toStringAsFixed(0)} / hour',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  // const Row(
                  //   children: [
                  //     Icon(
                  //       Icons.star,
                  //       color: Colors.amber,
                  //       size: 18,
                  //     ),
                  //     SizedBox(width: 4),
                  //     // Text(
                  //     //   rating,
                  //     //   style: const TextStyle(
                  //     //     fontSize: 14,
                  //     //     fontWeight: FontWeight.bold,
                  //     //   ),
                  //     // ),
                  //   ],
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
