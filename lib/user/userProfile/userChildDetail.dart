// ignore_for_file: file_names, use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../../service/zmodel/childmodel.dart';

class UserChildDetailPage extends StatefulWidget {
  final Child child;

  const UserChildDetailPage({Key? key, required this.child}) : super(key: key);

  @override
  _UserChildDetailPageState createState() => _UserChildDetailPageState();
}

class _UserChildDetailPageState extends State<UserChildDetailPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            title: Text(
              widget.child.sectionA['nameC'] ?? 'Child Details',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            pinned: true,
            floating: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Allow horizontal scrolling
                child: Material(
                  color: Colors.white,
                  child: Row(
                    children: [
                      _buildNavigationButton('Child\'s Info', 0),
                      _buildNavigationButton('Guardian\'s Info', 1),
                      _buildNavigationButton('Medical Info', 2),
                      _buildNavigationButton('Emergency Contact', 3),
                      _buildNavigationButton('Transport Needs', 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                ChildInfoSection(child: widget.child),
                GuardianInfoSection(child: widget.child),
                MedicalInfoSection(child: widget.child),
                EmergencyContactSection(child: widget.child),
                TransportNeedsSection(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(String label, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 8.0), // Add spacing between buttons
      child: TextButton(
        onPressed: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            color: _selectedIndex == index ? Colors.black : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Child's Info Section
class ChildInfoSection extends StatelessWidget {
  final Child child;

  const ChildInfoSection({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: 'Section A: Child\'s Particulars',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Child Name', child.sectionA['nameC']),
          _buildDetailRow('Gender', child.sectionA['genderC']),
          _buildDetailRow('Address', child.sectionA['addressC']),
          _buildDetailRow('Date of Birth', child.sectionA['dateOfBirthC']),
          _buildDetailRow('Age', child.sectionA['yearID']),
          _buildDetailRow('MyKid', child.sectionA['myKidC']),
          _buildDetailRow('Religion', child.sectionA['religionC']),
        ],
      ),
    );
  }
}

// Guardian's Info Section
class GuardianInfoSection extends StatelessWidget {
  final Child child;

  const GuardianInfoSection({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: 'Section B: Guardian\'s Particulars',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Father\'s Name', child.sectionB['nameF']),
          _buildDetailRow('Father\'s IC', child.sectionB['icF']),
          _buildDetailRow('Father\'s Income', child.sectionB['incomeF']),
          _buildDetailRow('Father\'s Address', child.sectionB['addressF']),
          _buildDetailRow('Father\'s Home Tel', child.sectionB['homeTelF']),
          _buildDetailRow('Father\'s Handphone', child.sectionB['handphoneF']),
          _buildDetailRow('Father\'s Email', child.sectionB['emailF']),
        ],
      ),
    );
  }
}

// Medical Info Section
class MedicalInfoSection extends StatelessWidget {
  final Child child;

  const MedicalInfoSection({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: 'Section C: Medical Information',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
              'Medical Condition', child.sectionC['medicalCondition']),
          _buildDetailRow('Doctor\'s Tel', child.sectionC['doctorTel']),
          _buildDetailRow('Clinic/Hospital', child.sectionC['clinicHospital']),
        ],
      ),
    );
  }
}

// Emergency Contact Section
class EmergencyContactSection extends StatelessWidget {
  final Child child;

  const EmergencyContactSection({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: 'Section D: Emergency Contact',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Name', child.sectionD['nameM']),
          _buildDetailRow('Tel', child.sectionD['telM']),
          _buildDetailRow('Relationship', child.sectionD['relationshipM']),
        ],
      ),
    );
  }
}

// Transport Needs Section
class TransportNeedsSection extends StatelessWidget {
  final Child child;

  const TransportNeedsSection({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: 'Section E: Transportation Needs',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Transportation', child.sectionE['transportation']),
          _buildDetailRow('Pickup Address', child.sectionE['pickupAddress']),
          _buildDetailRow('Drop Address', child.sectionE['dropAddress']),
        ],
      ),
    );
  }
}

// Helper method to build sections
Widget _buildSection({required String title, required Widget content}) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    ),
  );
}

Widget _buildDetailRow(String label, String? value) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6.0),
    padding: const EdgeInsets.all(12.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(
          _getIconForLabel(label),
          color: Colors.blueGrey[700],
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Text(
            value ?? 'N/A',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}

IconData _getIconForLabel(String label) {
  switch (label) {
    default:
      return Icons.info_outline;
  }
}
