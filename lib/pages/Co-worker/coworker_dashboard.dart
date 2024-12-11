import 'dart:convert'; // For base64 encoding/decoding.
import 'dart:typed_data'; // For handling byte data.
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase Firestore database.
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase authentication.
import 'package:flutter/material.dart'; // For Flutter UI components.
import 'package:image_picker/image_picker.dart'; // For image picking functionality.

class CoworkerDashboard extends StatefulWidget {
  const CoworkerDashboard({super.key});

  @override
  State<CoworkerDashboard> createState() => _CoworkerDashboardState();
}

class _CoworkerDashboardState extends State<CoworkerDashboard> {
  final TextEditingController _searchController =
      TextEditingController(); // Controller for search input.
  double _selectedPriceRange = 5000.0; // Default price range.
  String? _selectedRoomType; // The room type selected for filtering.
  String? Name; // Variable to store user's name.
  final List<String> _selectedAmenities =
      []; // List of selected amenities for filtering.
  List<Map<String, dynamic>> _filteredSpaces =
      []; // List of spaces after applying filters.
  String SpaceId = ' '; // Placeholder for space ID (could be used later).

  Uint8List? imageBytes; // For holding the decoded image bytes.
  List<Map<String, dynamic>> _spaces =
      []; // List of spaces fetched from Firestore.
  final picker =
      ImagePicker(); // Instance for picking images (not used in the current code).

  @override
  void initState() {
    super.initState();
    _fetchSpaces(); // Fetch coworking spaces on init.
    _fetchUserName(); // Fetch current user's name.
  }

  // Fetch the current signed-in user's name from Firestore.
  Future<void> _fetchUserName() async {
    try {
      final User? user =
          FirebaseAuth.instance.currentUser; // Get the current signed-in user.

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users') // Fetch user document from Firestore.
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          var userData =
              userDoc.data() as Map<String, dynamic>; // Extract user data.
          setState(() {
            Name = userData[
                'fullName']; // Assign the full name to the Name variable.
          });
        } else {
          print("User document doesn't exist in Firestore.");
        }
      } else {
        print("No user is currently signed in.");
      }
    } catch (e) {
      print(
          'Error fetching user name: $e'); // Handle error while fetching user data.
    }
  }

  // Fetch spaces from Firestore with "Accepted" status.
  Future<void> _fetchSpaces() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('spaces') // Fetch spaces from Firestore.
          .where('status', isEqualTo: 'Accepted') // Only fetch accepted spaces.
          .get();

      final List<Map<String, dynamic>> spaces = snapshot.docs
          .map((doc) => {
                'id': doc.id, // Space ID.
                'name': doc['spaceName'], // Space name.
                'image': doc['imagePath'], // Image path (URL or base64).
                'features': List<String>.from(
                    doc['selectedAmenities']), // Amenities list.
                'price': double.tryParse(doc['hoursPrice'].toString()) ??
                    0.0, // Space price.
                'type': doc['roomType'], // Room type.
              })
          .toList();

      setState(() {
        _spaces = spaces; // Store all spaces.
        _filteredSpaces = spaces; // Initially, no filter, show all spaces.
      });
    } catch (e) {
      print(
          'Error fetching coworking spaces: $e'); // Handle error in fetching spaces.
    }
  }

  // Apply the selected filters on spaces.
  void _applyFilters() {
    setState(() {
      _filteredSpaces = _spaces.where((space) {
        final matchesName = _searchController.text.isEmpty ||
            space['name']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        final matchesPrice =
            _selectedPriceRange == 0 || space['price'] == _selectedPriceRange;

        final matchesRoomType =
            _selectedRoomType == null || _selectedRoomType == space['type'];

        final matchesAmenities = _selectedAmenities.isEmpty ||
            _selectedAmenities
                .every((amenity) => space['features'].contains(amenity));

        return matchesName &&
            matchesPrice &&
            matchesRoomType &&
            matchesAmenities;
      }).toList();
    });
  }

  // Build the Room Type filter chip for selection.
  Widget _buildRoomTypeFilterChip(String label, StateSetter modalSetState) {
    final isSelected =
        _selectedRoomType == label; // Check if the label is selected.
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        modalSetState(() {
          if (selected) {
            _selectedRoomType = label; // Select room type.
          } else {
            _selectedRoomType = null; // Deselect room type.
          }
        });
        _applyFilters(); // Apply filter after selection.
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
    );
  }

  // Build the Amenities filter chip for selection.
  Widget _buildAmenitiesFilterChip(String label, StateSetter modalSetState) {
    final isSelected = _selectedAmenities.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        modalSetState(() {
          if (selected) {
            _selectedAmenities.add(label); // Add to selected amenities.
          } else {
            _selectedAmenities.remove(label); // Remove from selected amenities.
          }
        });
        _applyFilters(); // Apply filter after selection.
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
                                      max: 10000,
                                      divisions: 100,
                                      label:
                                          'Rs. ${_selectedPriceRange.toInt()}',
                                      onChanged: (value) {
                                        modalSetState(() {
                                          _selectedPriceRange = value;
                                        });
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
                        base64Decode(base64Image); // Decode base64 image.
                  } catch (e) {
                    print('Error decoding base64: $e');
                    imageBytes = null; // Handle error if base64 decode fails.
                  }
                }

                return _buildSpaceCard(
                  context,
                  space['id'],
                  space['name'],
                  space['price'],
                  space['type'],
                  space['features'], // Pass amenities here.
                  imageBytes,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Build the space card for each coworking space.
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

              // Subtitle (Amenities)
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
