// ignore_for_file: file_names, use_super_parameters, library_private_types_in_public_api, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../service/zmodel/teachermodel.dart';

class TeacherProfilePage extends StatefulWidget {
  final String docId; // Add docId as a parameter

  const TeacherProfilePage({Key? key, required this.docId}) : super(key: key);

  @override
  _TeacherProfilePageState createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  Teacher? teacher; // To hold the fetched teacher data
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchTeacherData(); // Fetch teacher data on initialization
  }

  Future<void> fetchTeacherData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('teachers') // Replace with your collection name
          .doc(widget.docId)
          .get();
      setState(() {
        teacher =
            Teacher.fromDocument(doc); // Convert document to Teacher object
        isLoading = false; // Set loading to false after fetching data
      });
    } catch (e) {
      print('Error fetching teacher data: $e');
      setState(() {
        isLoading = false; // Set loading to false on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileImage(),
              const SizedBox(height: 16),
              _buildUserInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return teacher!.profileImage != null && teacher!.profileImage!.isNotEmpty
        ? CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage(teacher!.profileImage!),
          )
        : CircleAvatar(
            radius: 80,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPersonalInfoSection(),
          _buildContactInfoSection(),
          _buildEmploymentInfoSection(),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Information', style: headerStyle),
          const SizedBox(height: 12.0),
          _buildInfoRow(Icons.person, 'Name:', teacher!.name),
          _buildInfoRow(
              Icons.calendar_today, 'Date of Birth:', teacher!.dateOfBirth),
          _buildInfoRow(Icons.transgender, 'Gender:', teacher!.gender),
          _buildInfoRow(Icons.credit_card, 'ID Number:', teacher!.idNumber),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contact Information', style: headerStyle),
          const SizedBox(height: 12.0),
          _buildInfoRow(
              Icons.phone, 'Phone:', teacher!.contactInfo.phoneNumber),
          _buildInfoRow(Icons.email, 'Email:', teacher!.contactInfo.email),
          _buildInfoRow(
              Icons.home, 'Address:', teacher!.contactInfo.homeAddress),
        ],
      ),
    );
  }

  Widget _buildEmploymentInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Employment Information', style: headerStyle),
          const SizedBox(height: 12.0),
          _buildInfoRow(
              Icons.work, 'Position:', teacher!.employmentInfo.position),
          _buildInfoRow(Icons.date_range, 'Joining Date:',
              teacher!.employmentInfo.joiningDate),
          _buildInfoRow(Icons.check_circle, 'Status:',
              teacher!.employmentInfo.employmentStatus),
          _buildInfoRow(
              Icons.monetization_on, 'Salary:', teacher!.employmentInfo.salary),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Text(label, style: labelStyle),
          const SizedBox(width: 8),
          Expanded(
            child:
                Text(info, style: infoStyle, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

// Common text style for labels (headers)
  static const TextStyle labelStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

// Common text style for information (non-bold)
  static const TextStyle infoStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );

// Common text style for headers
  static const TextStyle headerStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
}
