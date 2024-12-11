import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextspace/Model/space_model.dart';
import 'map_screen.dart'; // Ensure to have this file for the MapScreen implementation

class CreateSpace extends StatefulWidget {
  const CreateSpace({super.key});

  @override
  State<CreateSpace> createState() => _CreateSpaceState();
}

class _CreateSpaceState extends State<CreateSpace> {
  final _formKey = GlobalKey<FormState>();
  String? _spaceName;
  String? _description;
  String? _monthlyPrice;
  String? _city;
  String? _imagePath;
  String? _location;
  File? _image;

  String _base64Image = "";
  final picker = ImagePicker();
  Uint8List? imageBytes;

  String ownerId = FirebaseAuth.instance.currentUser?.uid ?? "default_owner_id";

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _spaceController = TextEditingController();

  // Default location for map picker
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
  String _roomType = ''; // Variable to hold selected room type
  final List<String> _roomTypes = [
    'Private Office',
    'Meeting Room',
    'Event Space',
    'Hot Desk',
  ];

  // Function to pick an image
  Future<void> _pickImage() async {
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

  // Function to toggle amenities selection
  void _onAmenitySelected(bool? selected, String amenity) {
    setState(() {
      if (selected == true) {
        _selectedAmenities.add(amenity);
      } else {
        _selectedAmenities.remove(amenity);
      }
    });
  }

  void _onTypeSelected(String type) {
    setState(() {
      _roomType = type; // Set the selected room type
    });
  }

  // Function to pick location from map
  void _pickLocation() async {
    final LatLng? selectedLocation = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MapScreen(initialLocation: _defaultLocation),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        _location =
            "${selectedLocation.latitude}, ${selectedLocation.longitude}";
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Create the Space object
        Space space = Space(
          spaceName:
              _spaceController.text.trim(), // Provide default value if null
          description: _descriptionController.text.trim(), // Default if null
          hoursPrice: _monthlyPrice ?? "0", // Default price if null
          city: _city ?? "Unknown City", // Default city if null
          location: _location ?? "0.0, 0.0", // Default location if null
          imagePath: _base64Image, // This can remain null if not selected
          selectedAmenities: _selectedAmenities,
          roomType: _roomType,
          ownerId: ownerId,
          status: 'Pending', // Replace with actual owner ID
          createdAt: Timestamp.fromDate(DateTime.now()),
        );

        // Create a reference to Firestore
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Save the space data to Firestore
        await firestore.collection('spaces').add(space.toMap());

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Space registered successfully!")),
        );
        Navigator.pushNamed(context, '/space_owner');

        // Optionally, reset the form after submission
        _formKey.currentState!.reset();
        setState(() {
          _imagePath = null;
          _location = null;
          _selectedAmenities.clear();
          _roomTypes.clear();
        });
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to register space: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Create Space",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Space Name Field
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
                  _spaceName = _spaceController.text;
                },
              ),
              const SizedBox(height: 20),

              // Description Field
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
                  _description = _descriptionController.text;
                },
              ),
              const SizedBox(height: 20),

              // Monthly Price Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Price Per Hours",
                  border: OutlineInputBorder(),
                  prefixText: "Rs.",
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the monthly price";
                  }
                  return null;
                },
                onSaved: (value) {
                  _monthlyPrice = value;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
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

              // Location Field
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Location",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.location_on),
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

              // Amenities Checkbox List
              const Text(
                "Select Amenities",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              const Text(
                "Room Types",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Column(
                children: _roomTypes.map((type) {
                  return RadioListTile<String>(
                    title: Text(type),
                    value: type,
                    groupValue:
                        _roomType, // The groupValue is the current selected room type
                    onChanged: (String? selectedType) {
                      if (selectedType != null) {
                        _onTypeSelected(selectedType);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Image Picker
              OutlinedButton.icon(
                onPressed:
                    _pickImage, // Use the existing _pickImage function for selecting an image
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  side: const BorderSide(
                    color: Colors.blueAccent,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                icon: const Icon(
                  Icons.add_a_photo_outlined,
                  color: Colors.black,
                ),
                label: const Text(
                  'Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (_base64Image.isEmpty) // Check if an image is not selected
                    const Text(
                      "Please upload your Space image",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    )
                  else
                    const Text(
                      "Space image uploaded successfully!",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text(
                  "Create Space",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
