// lib/zmodel/childmodel.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Child {
  final String id; // Add this line
  final String userId; // Add userId to link with User
  Map<String, dynamic> sectionA;
  Map<String, dynamic> sectionB;
  Map<String, dynamic> sectionC;
  Map<String, dynamic> sectionD;
  Map<String, dynamic> sectionE;
  List<String> milestoneIds; // Add this field
  String? profileImage; // Add this field to hold the profile image URL

  Child({
    required this.id, // Include this in the constructor
    required this.userId, // Include userId in the constructor
    required this.sectionA,
    required this.sectionB,
    required this.sectionC,
    required this.sectionD,
    required this.sectionE,
    this.milestoneIds = const [], // Initialize as empty list
    this.profileImage, // Initialize the profile image
  });

  // Factory constructor to create a Child from a Firestore document
  factory Child.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Child(
      id: doc.id, // Get the document ID
      userId: data['userId'] ?? '', // Fetch user ID from the document
      sectionA: data['SectionA'] ?? {},
      sectionB: data['SectionB'] ?? {},
      sectionC: data['SectionC'] ?? {},
      sectionD: data['SectionD'] ?? {},
      sectionE: data['SectionE'] ?? {},
      milestoneIds: List<String>.from(
          data['milestoneIds'] ?? []), // Populate the milestoneIds
      profileImage:
          data['profileImage'], // Add this line to retrieve the profile image
    );
  }

  // Getter for the child's name
  String get name =>
      sectionA['nameC'] ?? 'Unnamed Child'; // Default if nameC is not available
}
