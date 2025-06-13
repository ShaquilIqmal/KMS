import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'timetableViewAdmin.dart'; // Import the TimetableViewAdminPage

class AdminTimetablePage extends StatefulWidget {
  const AdminTimetablePage({super.key});

  @override
  _AdminTimetablePageState createState() => _AdminTimetablePageState();
}

class _AdminTimetablePageState extends State<AdminTimetablePage> {
  String? viewSelectedYear;
  String? createSelectedYear;
  String? selectedDay;
  String? selectedTimeslot;
  String? subject = '';
  String? teacher;
  List<Map<String, String>> teachers =
      []; // Updated to hold teacher ID and name
  bool isTimeslotAvailable = true; // To track timeslot availability

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('teachers').get();
      setState(() {
        teachers = snapshot.docs.map((doc) {
          print(
              'Fetched teacher ID: ${doc.id}'); // Print the teacher's document ID
          return {
            'id': doc.id, // Store the document ID
            'name': doc['name'] as String,
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching teachers: $e');
    }
  }

  Future<void> _checkTimeslotAvailability() async {
    if (createSelectedYear != null &&
        selectedDay != null &&
        selectedTimeslot != null) {
      QuerySnapshot existingAssignments = await FirebaseFirestore.instance
          .collection('timetable')
          .where('day', isEqualTo: selectedDay)
          .where('timeslot', isEqualTo: selectedTimeslot)
          .get();

      setState(() {
        isTimeslotAvailable = existingAssignments.docs.isEmpty;
      });
    }
  }

  Future<void> _createTimetableEntry() async {
    if (createSelectedYear != null &&
        selectedDay != null &&
        selectedTimeslot != null &&
        subject != null &&
        teacher != null) {
      String year = createSelectedYear!;
      String documentId = '$year-$selectedDay-$selectedTimeslot';

      // Find the selected teacher's ID
      String? teacherId = teachers.firstWhere((t) => t['name'] == teacher,
          orElse: () => {'id': ''} // Return an empty string instead of null
          )['id'];

      try {
        // Query to check if the year, day, and timeslot already exist
        QuerySnapshot existingTimetableEntry = await FirebaseFirestore.instance
            .collection('timetable')
            .where('year', isEqualTo: year)
            .where('day', isEqualTo: selectedDay)
            .where('timeslot', isEqualTo: selectedTimeslot)
            .get();

        if (existingTimetableEntry.docs.isNotEmpty) {
          // If the entry already exists
          _dismissBottomSheetAndShowDialog(
              'The timeslot is already taken.', true);
        } else {
          // Query to check if the teacher is assigned to the same timeslot on the same day
          QuerySnapshot existingAssignments = await FirebaseFirestore.instance
              .collection('timetable')
              .where('teacherId', isEqualTo: teacherId)
              .where('day', isEqualTo: selectedDay)
              .where('timeslot', isEqualTo: selectedTimeslot)
              .get();

          if (existingAssignments.docs.isNotEmpty) {
            // If the teacher is already assigned for this timeslot and day in any year
            _dismissBottomSheetAndShowDialog(
                'This teacher is already assigned to this timeslot on this day.',
                true);
          } else {
            // Create the timetable entry in a single document
            await FirebaseFirestore.instance
                .collection('timetable')
                .doc(documentId)
                .set({
              'year': year,
              'day': selectedDay,
              'timeslot': selectedTimeslot,
              'subject': subject,
              'teacher': teacher,
              'teacherId': teacherId, // Include the teacher's ID
            });

            _dismissBottomSheetAndShowDialog(
                'Timetable entry created successfully!', false);

            setState(() {
              createSelectedYear = null;
              selectedDay = null;
              selectedTimeslot = null;
              subject = '';
              teacher = null;
              isTimeslotAvailable = true; // Reset availability status
            });
          }
        }
      } catch (e) {
        print('Error creating timetable entry: $e');
        _dismissBottomSheetAndShowDialog(
            'Error creating timetable entry.', true);
      }
    } else {
      _dismissBottomSheetAndShowDialog(
          'Please fill in all fields before creating the timetable entry.',
          true);
    }
  }

  void _dismissBottomSheetAndShowDialog(
      String message, bool reopenBottomSheet) {
    // Dismiss the bottom sheet
    Navigator.pop(context);

    // Show the Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Colors.black.withOpacity(0.8), // Black transparent background
          title: const Text(
            'Message',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text color
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white, // White text color
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Close the dialog
                if (reopenBottomSheet) {
                  // After the dialog is closed, reopen the BottomSheet if needed
                  _showBottomSheet();
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white, // White text color
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildBottomContainer(context),
            ),
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
          'Timetable',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildTopContainer(),
                const SizedBox(height: 20),
                const SizedBox(height: 100), // Placeholder to push content up
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8A2387),
                      Color(0xFFE94057),
                      Color(0xFFF27121)
                    ],
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 24.0),
                  ),
                  onPressed: _showBottomSheet,
                  child: const Text(
                    'Create Timetable',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopContainer() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'View Timetable',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildDropdownRow(
              'Year', viewSelectedYear, ['Year 4', 'Year 5', 'Year 6'],
              (newValue) {
            setState(() {
              viewSelectedYear = newValue;
            });
          }),
          const SizedBox(height: 16.0),
          _buildViewButton(),
        ],
      ),
    );
  }

  Widget _buildBottomContainer(BuildContext parentContext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create Timetable',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16.0),
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: [
                _buildDropdownRow(
                    'Year', createSelectedYear, ['Year 4', 'Year 5', 'Year 6'],
                    (newValue) {
                  setState(() {
                    createSelectedYear = newValue;
                  });
                }),
                const SizedBox(height: 20),
                _buildDropdownRow('Day', selectedDay, [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday'
                ], (newValue) {
                  setState(() {
                    selectedDay = newValue;
                    selectedTimeslot = null;
                    isTimeslotAvailable = true;
                  });
                }),
                const SizedBox(height: 20),
                _buildDropdownRow('Timeslot', selectedTimeslot, [
                  '8.00-9.00',
                  '9.00-9.30',
                  '9.30-10.30',
                  '10.30-11.30',
                  '11.30-12.00',
                ], (newValue) {
                  setState(() {
                    selectedTimeslot = newValue;
                    _checkTimeslotAvailability();
                  });
                }, isDisabled: !isTimeslotAvailable),
                const SizedBox(height: 20),
                _buildSubjectInput(),
                const SizedBox(height: 20),
                _buildDropdownRow(
                    'Teacher',
                    teacher,
                    teachers.isNotEmpty
                        ? teachers.map((t) => t['name']).toList()
                        : [null], (newValue) {
                  setState(() {
                    teacher = newValue;
                  });
                }),
                _buildCreateButton(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDropdownRow(String label, String? value, List<String?> items,
      ValueChanged<String?> onChanged,
      {bool isDisabled = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDropdownButton(
                hint: 'Select $label',
                value: value,
                items: items,
                onChanged: isDisabled ? (_) {} : onChanged),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownButton({
    required String hint,
    required String? value,
    required List<String?> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white, // Set the background color to white
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
          value: value,
          isExpanded: true,
          items: items.map<DropdownMenuItem<String?>>((String? item) {
            return DropdownMenuItem<String?>(
              value: item,
              child: Container(
                color: Colors.white, // Ensure the menu item background is white
                child: Text(
                  item ?? 'None',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          dropdownColor:
              Colors.white, // Set the dropdown menu background to white
        ),
      ),
    );
  }

  Widget _buildSubjectInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Subject',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (value) {
                  subject = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Enter subject',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8A2387),
                  Color(0xFFE94057),
                  Color(0xFFF27121)
                ],
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
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
              ),
              onPressed: () {
                if (viewSelectedYear != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimetableViewAdminPage(
                          selectedYear: viewSelectedYear!),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Please select a year to view the timetable.'),
                    ),
                  );
                }
              },
              child: const Text(
                'View',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
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
            onPressed: _createTimetableEntry,
            child: const Text(
              'Create',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
