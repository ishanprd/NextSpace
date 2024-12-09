import 'dart:typed_data';
import 'dart:convert'; // Needed for base64 decoding
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nextspace/Model/chat_room_model.dart';
import 'package:nextspace/Model/firebase_helper.dart';
import 'package:nextspace/Model/user_model.dart';
import 'package:nextspace/pages/Co-worker/chat_room_page.dart';

class ViewSpaceForBook extends StatefulWidget {
  const ViewSpaceForBook({super.key});

  @override
  State<ViewSpaceForBook> createState() => _ViewSpaceForBookState();
}

class _ViewSpaceForBookState extends State<ViewSpaceForBook> {
  late Future<DocumentSnapshot> spaceData;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LatLng? _spaceLocation; // To store the space's latitude and longitude
  late GoogleMapController mapController;

  final CollectionReference feedbackCollection =
      FirebaseFirestore.instance.collection('feedbacks');
  late Future<List<Map<String, dynamic>>> feedbacksFuture;

  String? spaceId;
  String? OwnerId;

  // Move this to Future to fetch data async
  late Future<UserModel?> ownerModelFuture;
  @override
  void initState() {
    super.initState();
    // Delay the code execution to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final spaceId = ModalRoute.of(context)?.settings.arguments as String?;
      if (spaceId != null) {
        _fetchSpaceData(spaceId);
        setState(() {
          feedbacksFuture =
              fetchFeedbacks(spaceId); // Initialize feedbacksFuture
        });
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
        setState(() {
          OwnerId = space['ownerId'];
          // Fetch the OwnerModel only when OwnerId is available
          if (OwnerId != null) {
            ownerModelFuture = FirebaseHelper.getUserModelById(OwnerId!);
          }
        });

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

  Future<List<Map<String, dynamic>>> fetchFeedbacks(String spaceId) async {
    try {
      // Get the feedbacks collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('feedbacks') // Specify the collection name
          .where('spaceId', isEqualTo: spaceId) // Query by spaceId
          .get();

      // Extract the feedback data
      List<Map<String, dynamic>> feedbackList = [];
      for (var doc in querySnapshot.docs) {
        var feedbackData = doc.data() as Map<String, dynamic>;

        // Fetch user data (image and fullName) using the userId
        String userId = feedbackData['userId'] ?? '';
        if (userId.isNotEmpty) {
          DocumentSnapshot<Map<String, dynamic>> userDoc =
              await FirebaseFirestore.instance
                  .collection('users') // Assuming you have a 'users' collection
                  .doc(userId)
                  .get();

          if (userDoc.exists) {
            var userData = userDoc.data() as Map<String, dynamic>;
            feedbackData['image'] = userData['image'] ??
                ''; // Assuming image URL is stored under 'imageUrl'
            feedbackData['userName'] = userData['fullName'] ??
                'Unknown User'; // Assuming fullName is stored under 'fullName'
          } else {
            feedbackData['userImage'] = ''; // Handle missing user data
            feedbackData['userName'] = 'Unknown User';
          }
        }

        feedbackList.add(feedbackData);
      }

      return feedbackList;
    } catch (e) {
      print("Error fetching feedbacks: $e");
      return [];
    }
  }

  Future<ChatRoomModel?> getChatroomModel(
      UserModel userModel, UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    // Check if a chatroom already exists
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Use the existing chatroom
      var docData = snapshot.docs[0].data();
      chatRoom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);
    } else {
      // Create a new chatroom
      String chatroomId =
          FirebaseFirestore.instance.collection("chatrooms").doc().id;
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: chatroomId,
        lastMessage: "",
        participants: {
          userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatroomId)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;
    }

    return chatRoom;
  }

  DateTime convertToDateTime(dynamic timestamp) {
    // Check if the timestamp is a Firestore Timestamp
    if (timestamp is Timestamp) {
      return timestamp.toDate(); // Converts the Firestore Timestamp to DateTime
    } else if (timestamp is String) {
      return DateTime.parse(timestamp); // If it's already a String, parse it
    } else {
      throw Exception('Invalid timestamp format');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userId = _auth.currentUser?.uid ?? '';
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No user data found'));
        }

        var userDoc = snapshot.data!;
        var userData = userDoc.data() as Map<String, dynamic>;

        UserModel userModel =
            UserModel.fromJson(userData); // Correctly pass the data

        // Now you can use userModel as needed

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
              spaceId = space.id;
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

              String roomType =
                  roomTypes.isNotEmpty ? roomTypes.first : 'Unknown';

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
                          'Rs. $price / Hours',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
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
                        return _buildFacilityIcon(
                            getAmenityIcon(amenity), amenity);
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Feedbacks', // Display only one room type
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showFeedbackDialog(context);
                          },
                          child: const Text(
                            'Add feedback', // Display only one room type
                            style: TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: feedbacksFuture,
                      builder: (context, feedbackSnapshot) {
                        if (feedbackSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (feedbackSnapshot.hasError) {
                          return Center(
                              child: Text('Error: ${feedbackSnapshot.error}'));
                        }

                        if (!feedbackSnapshot.hasData ||
                            feedbackSnapshot.data!.isEmpty) {
                          return const Text('No feedbacks available');
                        }

                        return Column(
                          children: feedbackSnapshot.data!.map((feedback) {
                            // Assuming 'timestamp' is a Firestore Timestamp
                            DateTime dateTime =
                                convertToDateTime(feedback['timestamp']);
                            String date =
                                "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

                            final base64Image = feedback['image'];

                            Uint8List? imageBytes;
                            try {
                              imageBytes = base64Decode(
                                  base64Image); // Decode base64 image data
                            } catch (e) {
                              print('Error decoding base64: $e');
                              imageBytes = null; // Handle decoding error
                            } // Optionally format this DateTime to a string
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: imageBytes != null
                                              ? MemoryImage(
                                                  imageBytes) // Display decoded image
                                              : const AssetImage(
                                                      'assets/userprofile.jpg')
                                                  as ImageProvider,
                                          radius: 25,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              feedback['userName'] ??
                                                  'Unknown User',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              date,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      feedback['feedback'] ??
                                          'No comment provided.',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
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
                    const SizedBox(height: 20),
                    // ignore: unnecessary_null_comparison
                    ownerModelFuture != null
                        ? FutureBuilder<UserModel?>(
                            future: ownerModelFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Text(
                                    'Error fetching owner details: ${snapshot.error}');
                              }
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: Text('Owner not found'));
                              }

                              UserModel ownerModel = snapshot.data!;
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  if (OwnerId != null &&
                                      userModel.uid != OwnerId) {
                                    getChatroomModel(userModel, ownerModel)
                                        .then((chatRoom) {
                                      if (chatRoom != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                            return ChatRoomPage(
                                              targetUser: ownerModel,
                                              userModel: userModel,
                                              firebaseUser: _auth.currentUser!,
                                              chatroom: chatRoom,
                                            );
                                          }),
                                        );
                                      }
                                    });
                                  }
                                },
                                child: const Text(
                                  "Contact Owner",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              );
                            },
                          )
                        : Container(),
                  ],
                ),
              );
            },
          ),
        );
      },
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

  void _showFeedbackDialog(BuildContext context) {
    TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Feedback"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  hintText: "Enter your feedback here",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4, // Allow the user to enter multiple lines of text
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Handle feedback submission logic
                      String feedback = feedbackController.text;
                      if (feedback.isNotEmpty) {
                        try {
                          await feedbackCollection.add({
                            'feedback': feedback,
                            'spaceId': spaceId,
                            'userId': FirebaseAuth.instance.currentUser!.uid,
                            'timestamp': DateTime.now(),
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Feedback Submitted')),
                          );
                          Navigator.of(context).pop();
                          _fetchSpaceData(spaceId!);

                          setState(() {
                            feedbacksFuture = fetchFeedbacks(
                                spaceId!); // Initialize feedbacksFuture
                          }); // Initialize feedbacksFuture
                          // Close the dialog
                        } catch (e) {
                          print('Error saving feedback: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Error saving feedback')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter some feedback')),
                        );
                      }
                    },
                    // Close the dialog

                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
