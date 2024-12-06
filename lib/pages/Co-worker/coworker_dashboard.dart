import 'package:flutter/material.dart';

class CoworkerDashboard extends StatefulWidget {
  const CoworkerDashboard({super.key});

  @override
  State<CoworkerDashboard> createState() => _CoworkerDashboardState();
}

class _CoworkerDashboardState extends State<CoworkerDashboard> {
  final TextEditingController _searchController = TextEditingController();
  double _selectedPriceRange = 250.0; // Default price range
  final List<String> _selectedRoomTypes = [];
  final List<Map<String, dynamic>> _allSpaces = [
    {
      "name": "Workpair Co",
      "image": 'assets/background.jpg',
      "features": "WiFi · Coffee · Meeting Room",
      "price": 125,
      "rating": "4.9",
      "type": "Meeting Room"
    },
    {
      "name": "Office Spot",
      "image": 'assets/background.jpg',
      "features": "WiFi · Quiet Zone · Meeting Room",
      "price": 100,
      "rating": "4.8",
      "type": "Private Room"
    },
  ];
  List<Map<String, dynamic>> _filteredSpaces = [];

  @override
  void initState() {
    super.initState();
    _filteredSpaces = List.from(_allSpaces); // Initialize filtered list
  }

  void _applyFilters() {
    setState(() {
      _filteredSpaces = _allSpaces.where((space) {
        final matchesName = _searchController.text.isEmpty ||
            space['name']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
        final matchesPrice = space['price'] <= _selectedPriceRange;
        final matchesRoomType = _selectedRoomTypes.isEmpty ||
            _selectedRoomTypes.contains(space['type']);
        return matchesName && matchesPrice && matchesRoomType;
      }).toList();
    });
  }

  Widget _buildRoomTypeFilterChip(String label, StateSetter modalSetState) {
    final isSelected = _selectedRoomTypes.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        modalSetState(() {
          if (selected) {
            _selectedRoomTypes.add(label);
          } else {
            _selectedRoomTypes.remove(label);
          }
        });
        _applyFilters(); // Update the main widget state
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
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
              const Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Text(
                  "Hi Michael, where you\nwanna work today?",
                  style: TextStyle(
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
                                      max: 500, // Adjust as needed
                                      divisions: 10,
                                      label:
                                          'Rp. ${_selectedPriceRange.toInt()}',
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
                                            "Hot Desk", modalSetState),
                                        _buildRoomTypeFilterChip(
                                            "Meeting Room", modalSetState),
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
                return _buildSpaceCard(
                  space['name'],
                  space['image'],
                  space['features'],
                  "Rp. ${space['price']} / Hour",
                  space['rating'],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build a space card
  Widget _buildSpaceCard(
    String title,
    String image,
    String subtitle,
    String price,
    String rating,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/view_space');
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
                    child: Image.asset(
                      image, // Replace with your image path
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              // Price and Rating Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
