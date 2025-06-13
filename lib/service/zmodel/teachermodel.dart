import 'package:cloud_firestore/cloud_firestore.dart';

class Teacher {
  String id;
  String name;
  String dateOfBirth;
  String gender;
  String idNumber;
  ContactInfo contactInfo;
  EmploymentInfo employmentInfo;
  List<String> assignedClasses; // Added assignedClasses field
  String? profileImage; // Add this field to hold the profile image URL

  Teacher({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.idNumber,
    required this.contactInfo,
    required this.employmentInfo,
    required this.assignedClasses, // Include in constructor
    this.profileImage, // Initialize the profile image
  });

  factory Teacher.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Teacher(
      id: doc.id,
      name: data['name'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      gender: data['gender'] ?? '',
      idNumber: data['idNumber'] ?? '',
      contactInfo: ContactInfo.fromMap(data['contactInfo'] ?? {}),
      employmentInfo: EmploymentInfo.fromMap(data['employmentInfo'] ?? {}),
      assignedClasses: List<String>.from(
          data['assignedClasses'] ?? []), // Initialize assignedClasses
      profileImage:
          data['profileImage'], // Add this line to retrieve the profile image
    );
  }
}

class ContactInfo {
  String phoneNumber;
  String email;
  String homeAddress;

  ContactInfo({
    required this.phoneNumber,
    required this.email,
    required this.homeAddress,
  });

  factory ContactInfo.fromMap(Map<String, dynamic> map) {
    return ContactInfo(
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      homeAddress: map['homeAddress'] ?? '',
    );
  }
}

class EmploymentInfo {
  String position;
  String joiningDate;
  String employmentStatus;
  String salary;

  EmploymentInfo({
    required this.position,
    required this.joiningDate,
    required this.employmentStatus,
    required this.salary,
  });

  factory EmploymentInfo.fromMap(Map<String, dynamic> map) {
    return EmploymentInfo(
      position: map['position'] ?? '',
      joiningDate: map['joiningDate'] ?? '',
      employmentStatus: map['employmentStatus'] ?? '',
      salary: map['salary'] ?? '',
    );
  }
}
