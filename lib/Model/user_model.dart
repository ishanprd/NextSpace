class UserModel {
  final String? uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final String gender;
  final String imageUrl;
  final String? photo;
  final String role;

  UserModel({
    this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.gender,
    required this.imageUrl,
    this.photo,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'gender': gender,
      'imageUrl': imageUrl,
      'photo': photo, // photo is optional in the JSON structure, so it's
      'role': role,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      password: json['password'],
      gender: json['gender'],
      imageUrl: json['imageUrl'],
      photo: json['photo'], // photo is optional in the JSON structure, so it's
      role: json['role'],
    );
  }
}
