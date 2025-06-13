import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class ViewMilestonePage extends StatefulWidget {
  const ViewMilestonePage({super.key});

  @override
  State<ViewMilestonePage> createState() => _ViewMilestonePageState();
}

class _ViewMilestonePageState extends State<ViewMilestonePage> {
  String selectedYear = 'Year 4'; // Default to Year 4
  Map<String, List<Map<String, dynamic>>> categorizedMilestones = {};

  final List<String> years = ['Year 4', 'Year 5', 'Year 6'];

  @override
  void initState() {
    super.initState();
    fetchMilestones();
  }

  Future<void> fetchMilestones() async {
    categorizedMilestones.clear();

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('milestones')
        .where('year', isEqualTo: selectedYear)
        .get();

    for (var doc in snapshot.docs) {
      final milestoneData = doc.data() as Map<String, dynamic>;
      final criteria = milestoneData['criteria'] ?? 'General';

      if (!categorizedMilestones.containsKey(criteria)) {
        categorizedMilestones[criteria] = [];
      }

      categorizedMilestones[criteria]!.add({
        'id': doc.id,
        ...milestoneData,
      });
    }
    setState(() {});
  }

  Future<void> deleteMilestone(String id) async {
    try {
      print('Attempting to delete milestone with ID: $id');

      DocumentReference milestoneRef =
          FirebaseFirestore.instance.collection('milestones').doc(id);

      QuerySnapshot childDocsSnapshot =
          await FirebaseFirestore.instance.collection('child').get();

      for (var doc in childDocsSnapshot.docs) {
        var childData = doc.data() as Map<String, dynamic>?;
        if (childData == null || !childData.containsKey('milestones')) continue;

        List<dynamic> currentMilestones = childData['milestones'];
        List<Map<String, dynamic>> updatedMilestones =
            currentMilestones.cast<Map<String, dynamic>>().where((milestone) {
          return milestone['milestoneId'] != id;
        }).toList();

        if (updatedMilestones.length != currentMilestones.length) {
          await doc.reference.update({'milestones': updatedMilestones});
        }
      }

      await milestoneRef.delete();
      await fetchMilestones();
    } catch (e) {
      print('Error deleting milestone: $e');
    }
  }

  Future<void> editMilestone(
      String id, String currentTitle, String currentDescription) async {
    final TextEditingController titleController =
        TextEditingController(text: currentTitle);
    final TextEditingController descriptionController =
        TextEditingController(text: currentDescription);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Colors.black.withOpacity(0.8), // Black transparent background
          title: const Text(
            'Edit Milestone',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text color
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white), // White text color
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle:
                      TextStyle(color: Colors.white), // White label text color
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white), // White text color
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle:
                      TextStyle(color: Colors.white), // White label text color
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white), // White text color
              ),
            ),
            TextButton(
              onPressed: () async {
                final newTitle = titleController.text;
                final newDescription = descriptionController.text;

                await FirebaseFirestore.instance
                    .collection('milestones')
                    .doc(id)
                    .update({
                  'title': newTitle,
                  'description': newDescription,
                });

                Navigator.of(context).pop();
                await fetchMilestones();
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white), // White text color
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'View Milestones',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildYearDropdown(),
            const SizedBox(height: 16),
            _buildMilestonesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildYearDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Select Year:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.grey), // Add border to dropdown
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedYear,
                    items: years.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedYear = newValue;
                          fetchMilestones();
                        });
                      }
                    },
                    isExpanded: true,
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesList() {
    return Expanded(
      child: ListView(
        children: categorizedMilestones.entries.map((entry) {
          final criteria = entry.key;
          final milestones = entry.value;

          return _buildExpansionTile(criteria, milestones);
        }).toList(),
      ),
    );
  }

  Widget _buildExpansionTile(
      String criteria, List<Map<String, dynamic>> milestones) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            criteria,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          children: milestones.map((milestone) {
            return _buildMilestoneCard(milestone);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMilestoneCard(Map<String, dynamic> milestone) {
    // Get the targetAchievedDate and format it
    DateTime? targetAchievedDate = milestone['targetAchievedDate'] != null
        ? (milestone['targetAchievedDate'] as Timestamp).toDate()
        : null; // Check if targetAchievedDate is available

    String formattedDate = targetAchievedDate != null
        ? DateFormat('yyyy-MM-dd').format(targetAchievedDate)
        : 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        title: Text(
          milestone['title'] ?? 'No Title',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${milestone['description'] ?? 'No Description'}\nLevel: ${milestone['milestoneLevel'] ?? 'N/A'}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4), // Add some space
            Text(
              'Target Achieved Date: $formattedDate',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: _buildMilestoneActions(milestone),
        contentPadding: const EdgeInsets.all(16.0),
      ),
    );
  }

  Widget _buildMilestoneActions(Map<String, dynamic> milestone) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            editMilestone(
              milestone['id'],
              milestone['title'] ?? '',
              milestone['description'] ?? '',
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.black
                      .withOpacity(0.8), // Black transparent background
                  title: const Text(
                    'Confirm Deletion',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text color
                    ),
                  ),
                  content: const Text(
                    'Are you sure you want to delete this milestone?',
                    style: TextStyle(
                      color: Colors.white, // White text color
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style:
                            TextStyle(color: Colors.white), // White text color
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        deleteMilestone(milestone['id']);
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red), // White text color
                      ),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
