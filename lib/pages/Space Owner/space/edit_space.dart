import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_screen.dart';
import 'package:image/image.dart' as img;

// Ensure to have this file for the MapScreen implementation

class EditSpace extends StatefulWidget {
  const EditSpace({super.key});

  @override
  State<EditSpace> createState() => _EditSpaceState();
}

class _EditSpaceState extends State<EditSpace> {
  final _formKey = GlobalKey<FormState>();
  String? _spaceName;
  String? _description;
  String? _monthlyPrice;
  String? _city;
  String? _imagePath;
  String? _location;
  File? _image;
  Uint8List? imageBytes;
  final picker = ImagePicker();

  bool _isLoading = true;
  String space_id = "";

  String _base64Image = "";
  String ownerId = FirebaseAuth.instance.currentUser?.uid ?? "default_owner_id";

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _spaceController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  final LatLng _defaultLocation =
      const LatLng(27.7172, 85.3240); // Kathmandu, Nepal

  final List<String> _selectedAmenities = [];
  final List<String> _allAmenities = [
    'Wi-Fi',
    'Desk Space',
    'Air Conditioning',
    'Meeting Rooms',
    'Event Space',
    'Elevator',
  ];
  String? _roomType;
  final List<String> _roomTypes = [
    'Private Office',
    'Meeting Room',
    'Event Space',
    'Hot Desk'
  ];

  // Function to fetch space data for the current owner
  Future<void> _fetchSpaceData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("No user logged in");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Query the 'spaces' collection for documents where 'ownerId' matches
      QuerySnapshot querySnapshot = await firestore
          .collection('spaces')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        space_id = querySnapshot.docs.first.id;
        // Use the first document (if there's only one for this user)
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;

        setState(() {
          _spaceController.text = data['spaceName'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _priceController.text = data['hoursPrice'] ?? '';
          _cityController.text = data['city'] ?? '';
          _location = data['location'] ?? '';
          _base64Image = data['imagePath'] ?? '';
          _selectedAmenities
              .addAll(List<String>.from(data['selectedAmenities'] ?? []));
          _roomType = data['roomType'];
          _isLoading = false; // Data has been fetched
        });
      } else {
        print("No documents found for the current user");
        setState(() {
          _isLoading = false; // No data found
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No space data found for this user.")),
        );
      }
    } catch (e) {
      print("Error fetching space data: $e");
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching space data: $e")),
      );
    }
  }

  Future<void> _deleteSpace(String spaceId) async {
    try {
      // Delete the document from Firestore
      await FirebaseFirestore.instance
          .collection('spaces')
          .doc(spaceId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Space deleted successfully")),
      );

      // Navigate back to the previous screen or update the UI as needed
      Navigator.pushNamed(context, '/space_owner');
    } catch (error) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting space: $error")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSpaceData(); // Fetch space data on initialization
  }

  Future<void> uploadImage() async {
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();

      // Update the state with the original image
      setState(() {
        _image = File(pickedImage.path);
        _base64Image = base64Encode(bytes);
        imageBytes = bytes; // Display the original image
      });
    } else {
      setState(() {}); // Handle case when no image is picked
    }
  }

  Future<void> _pickLocation() async {
    // Assuming you have implemented MapScreen that returns a LatLng when selecting location
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MapScreen(initialLocation: _defaultLocation)),
    );
    if (result != null) {
      setState(() {
        _location = "${result.latitude}, ${result.longitude}";
      });
    }
  }

  void _onAmenitySelected(bool? selected, String amenity) {
    setState(() {
      if (selected != null) {
        if (selected) {
          _selectedAmenities.add(amenity);
        } else {
          _selectedAmenities.remove(amenity);
        }
      }
    });
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        // Query for documents where ownerId matches
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('spaces')
            .where('ownerId', isEqualTo: ownerId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Update the first matching document
          DocumentReference docRef = querySnapshot.docs.first.reference;

          await docRef.update({
            'spaceName': _spaceController.text,
            'description': _descriptionController.text,
            'hoursPrice': _priceController.text,
            'city': _cityController.text,
            'location': _location,
            'imagePath': _base64Image,
            'selectedAmenities': _selectedAmenities,
            'roomType': _roomType,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Space data updated successfully")),
          );
          await _fetchSpaceData();
          Navigator.of(context).pop();

          // Navigate back after saving
        } else {
          // No document found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("No matching document found to update.")),
          );
        }
      } catch (error) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving data: $error")),
        );
      }
    }
  }

  void _confirmDelete(String spaceId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this space?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close the dialog
              await _deleteSpace(spaceId); // Call delete function
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Space", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _spaceController,
                      decoration: const InputDecoration(
                        labelText: "Space Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the space name";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _spaceName = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a description";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _description = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: "Hourly Price",
                        border: OutlineInputBorder(),
                        prefixText: "Rs.",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the Hours price";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _monthlyPrice = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: "City",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the city";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _city = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Location",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.map),
                          onPressed: _pickLocation,
                        ),
                      ),
                      controller: TextEditingController(text: _location),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a location";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Select Amenities",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: _allAmenities.map((amenity) {
                        return CheckboxListTile(
                          title: Text(amenity),
                          value: _selectedAmenities.contains(amenity),
                          onChanged: (bool? selected) {
                            _onAmenitySelected(selected, amenity);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    _buildRoomTypeSelection(),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: uploadImage,
                      icon: const Icon(Icons.add_a_photo_outlined,
                          color: Colors.black),
                      label: const Text('Image'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (_base64Image.isEmpty)
                          const Text(
                            "Please upload your Space image",
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.red),
                          )
                        else
                          const Text(
                            "Space image uploaded successfully!",
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueAccent),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Add functionality for availability check
                        _confirmDelete(space_id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _submitForm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRoomTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Room Type",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ..._roomTypes.map((roomType) {
          return RadioListTile<String>(
            title: Text(roomType),
            value: roomType,
            groupValue: _roomType,
            onChanged: (value) {
              setState(() {
                _roomType = value;
              });
            },
          );
        }),
      ],
    );
  }
}
