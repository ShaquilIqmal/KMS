// ignore_for_file: file_names, use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../service/database_service.dart';

class AdminMilestonePage extends StatefulWidget {
  const AdminMilestonePage({super.key});

  @override
  State<AdminMilestonePage> createState() => _AdminMilestonePageState();
}

class _AdminMilestonePageState extends State<AdminMilestonePage> {
  String? selectedYear;
  String? selectedCriteria;
  String? selectedLevel;
  DateTime? targetAchievedDate; // Keep targetAchievedDate

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<String> years = ['Year 4', 'Year 5', 'Year 6'];
  final List<String> criteriaOptions = [
    'General',
    'Reading',
    'Writing',
    'Speaking',
    'Listening'
  ];
  final List<String> levels = ['1', '2', '3', '4'];

  @override
  void initState() {
    super.initState();
  }

  // Check if a milestone already exists for the selected criteria, year, and level
  Future<bool> checkIfLevelExists() async {
    if (selectedCriteria == null ||
        selectedLevel == null ||
        selectedYear == null) {
      return false; // No criteria, year, or level selected, no need to check
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('milestones')
        .where('criteria', isEqualTo: selectedCriteria)
        .where('year', isEqualTo: selectedYear)
        .where('milestoneLevel', isEqualTo: selectedLevel)
        .get();

    return snapshot.docs
        .isNotEmpty; // Return true if any document exists with the same criteria, year, and level
  }

  // Save the milestone data to Firestore
  Future<void> saveMilestone() async {
    bool levelExists = await checkIfLevelExists();

    if (levelExists) {
      // Show snackbar if the level already exists for the selected criteria and year
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'The level for the selected criteria and year already exists.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedLevel == null) {
      print('Please select a milestone level.');
      return;
    }

    final String title = titleController.text;
    final String description = descriptionController.text;

    // Generate milestone ID
    String milestoneId =
        '${selectedCriteria}_${selectedYear}_Level$selectedLevel';

    Map<String, dynamic> milestoneData = {
      'year': selectedYear,
      'title': title,
      'description': description,
      'criteria': selectedCriteria,
      'milestoneLevel': selectedLevel,
      'targetAchievedDate': targetAchievedDate, // Keep targetAchievedDate
    };

    try {
      await DatabaseService().addMilestone(milestoneId, milestoneData);
      print('Milestone added with ID: $milestoneId');
      await linkMilestoneToChildren(milestoneId, selectedYear, achieved: false);

      // Clear the text fields and reset variables
      titleController.clear();
      descriptionController.clear();
      setState(() {
        selectedYear = null;
        selectedCriteria = null;
        selectedLevel = null;
        targetAchievedDate = null; // Reset the targetAchievedDate
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Milestone saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving milestone: $e');
    }
  }

  // Link the milestone to all children in the selected year
  Future<void> linkMilestoneToChildren(String milestoneId, String? year,
      {required bool achieved}) async {
    QuerySnapshot childrenSnapshot = await FirebaseFirestore.instance
        .collection('child')
        .where('SectionA.yearID', isEqualTo: year)
        .get();

    for (var childDoc in childrenSnapshot.docs) {
      var data = childDoc.data() as Map<String, dynamic>?;

      List<Map<String, dynamic>> currentMilestones =
          List<Map<String, dynamic>>.from(data?['milestones'] ?? []);

      currentMilestones.add({
        'milestoneId': milestoneId,
        'achieved': achieved,
        'targetAchievedDate': targetAchievedDate,
      });

      await DatabaseService().childCollection.doc(childDoc.id).update({
        'milestones': currentMilestones,
      });
    }
  }

  Future<void> _selectTargetAchievedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: targetAchievedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.grey.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        targetAchievedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Admin Milestone Setup',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownField(
              'Year',
              selectedYear,
              years,
              (String? newValue) {
                setState(() {
                  selectedYear = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              'Criteria',
              selectedCriteria,
              criteriaOptions,
              (String? newValue) {
                setState(() {
                  selectedCriteria = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              'Level',
              selectedLevel,
              levels,
              (String? newValue) {
                setState(() {
                  selectedLevel = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDateField(
              'Target Achieved Date',
              targetAchievedDate,
              context,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Title',
              titleController,
              includeLabel: false,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Description',
              descriptionController,
              maxLines: 3,
              includeLabel: false,
            ),
            const SizedBox(height: 24),
            _buildSaveMilestoneButton()
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          ),
          dropdownColor:
              Colors.white, // Set the dropdown menu background to white
          hint: Text('Select $label'),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          readOnly: true,
          onTap: () async {
            await _selectTargetAchievedDate(context);
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            hintText: 'Select $label',
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
            ),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: Colors.grey.shade600,
            ),
          ),
          controller: TextEditingController(
            text: date != null ? "${date.toLocal()}".split(' ')[0] : '',
          ), // Set the controller's text to the selected date
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, bool includeLabel = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (includeLabel) Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: includeLabel ? label : null,
            labelStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            hintText: 'Enter $label',
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildSaveMilestoneButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          ),
          onPressed: saveMilestone,
          child: const Text(
            'Save Milestone',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
