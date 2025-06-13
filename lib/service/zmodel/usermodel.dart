// lib/zmodel/usermodel.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import 'childmodel.dart';

class User {
  String id;
  String name;
  String email;
  String noTel;
  String password;
  String? profileImage; // Add this field to hold the profile image URL
  List<String> childIds; // Store child document IDs
  List<Child> children; // Optionally store the fetched child data

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.noTel,
    required this.password,
    this.profileImage, // Initialize the profile image
    this.childIds = const [], // Initialize as empty list
    this.children = const [], // Initialize as empty list
  });

  // Factory constructor to create a User from a Firestore document
  factory User.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      noTel: data['noTel'] ?? '',
      password: data['password'] ?? '',
      childIds:
          List<String>.from(data['childIds'] ?? []), // Convert to List<String>
      children: [], // This will be filled later if needed
      profileImage:
          data['profileImage'], // Add this line to retrieve the profile image
    );
  }
}
