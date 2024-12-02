import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importing the image picker package

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
  String? _place;
  String? _city;
  String? _imagePath;

  final List<String> _selectedAmenities = [];
  final List<String> _allAmenities = [
    'Wi-Fi',
    'Desk Space',
    'Air Conditioning',
    'Meeting Rooms',
    'Event Space',
    'Elevator',
  ];

  // Function to handle form submission
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Handle space creation logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Space created successfully!")),
      );
    }
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path; // Get the image file path
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              // Description Field
              TextFormField(
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

              // Monthly Price Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Monthly Price",
                  border: OutlineInputBorder(),
                  prefixText: "\$",
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

              // Place Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Place",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the place";
                  }
                  return null;
                },
                onSaved: (value) {
                  _place = value;
                },
              ),
              const SizedBox(height: 20),

              // City Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Open hour",
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

              // Image Picker
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text(
                      "Pick Image",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_imagePath != null)
                    Text(
                      "Image selected",
                      style: TextStyle(color: Colors.green.shade600),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/view_space');
                },
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
