import 'dart:math'; // Import the dart:math library

import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:flutter/material.dart';

class TimetableViewAdminPage extends StatefulWidget {
  final String selectedYear; // Field to hold the selected year

  const TimetableViewAdminPage({
    super.key,
    required this.selectedYear, // Require the selected year
  });

  @override
  _TimetableViewAdminPageState createState() => _TimetableViewAdminPageState();
}

class _TimetableViewAdminPageState extends State<TimetableViewAdminPage> {
  List<Map<String, String>> timetableData =
      []; // List to hold timetable data with IDs for the selected day
  String selectedDay = 'Monday'; // Default selected day
  bool isLoading = false; // Loading state variable
  Map<String, List<Map<String, String>>> timetableCache =
      {}; // Local cache for timetable data
  int? selectedIndex; // Track the index of the selected container

  @override
  void initState() {
    super.initState();
    _fetchTimetableForDay(
        selectedDay); // Fetch timetable for the default selected day
  }

  // Delete the selected timetable entry
  Future<void> _deleteTimetableEntry(int index) async {
    final entry = timetableData[index];
    final docId = entry['id']; // Get the document ID

    // Logic to delete the timetable entry from Firestore
    await FirebaseFirestore.instance
        .collection('timetable')
        .doc(docId)
        .delete();

    // Remove it from the local timetableData list
    timetableData.removeAt(index);
    setState(() {
      selectedIndex = null; // Reset selected index
    });
  }

  // Fetch timetable data for the selected year and day
  Future<void> _fetchTimetableForDay(String day) async {
    if (timetableCache.containsKey(day)) {
      timetableData = timetableCache[day]!;
      setState(() {});
      return;
    }

    setState(() {
      isLoading = true; // Start loading
    });

    try {
      await _getTimetableFromFirestore(day);
      _sortTimetableData();
      timetableCache[day] = List.from(timetableData);
      setState(() {});
    } catch (e) {
      print('Error fetching timetable for $day: $e');
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  // Fetch timetable data from Firestore
  Future<void> _getTimetableFromFirestore(String day) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('timetable')
        .where('year', isEqualTo: widget.selectedYear)
        .where('day', isEqualTo: day)
        .get();

    timetableData.clear();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String timeslot = data['timeslot'] ?? 'No timeslot';
      String subject = data['subject'] ?? 'No subject';
      String teacher = data['teacher'] ?? 'No teacher';
      String docId = doc.id; // Get the document ID

      // Store data along with the document ID
      timetableData.add({
        'id': docId,
        'timeslot': timeslot,
        'subject': subject,
        'teacher': teacher,
      });
    }
  }

  // Sort timetable data based on the first numerical value of the timeslot
  void _sortTimetableData() {
    timetableData.sort((a, b) {
      String timeA = a['timeslot'] ?? '';
      String timeB = b['timeslot'] ?? '';
      return double.parse(timeA.split('-')[0])
          .compareTo(double.parse(timeB.split('-')[0]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Timetable - ',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            children: <TextSpan>[
              TextSpan(
                text: widget.selectedYear,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.grey[100],
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDayButton(context, 'Mon', 'Monday'),
              const SizedBox(width: 5),
              _buildDayButton(context, 'Tue', 'Tuesday'),
              const SizedBox(width: 5),
              _buildDayButton(context, 'Wed', 'Wednesday'),
              const SizedBox(width: 5),
              _buildDayButton(context, 'Thu', 'Thursday'),
              const SizedBox(width: 5),
              _buildDayButton(context, 'Fri', 'Friday'),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTimetable(), // Call the timetable build method
          ),
          if (selectedIndex != null)
            _buildDustbinButton(), // Show dustbin button if an entry is selected
        ],
      ),
    );
  }

  // Build the timetable view
  Widget _buildTimetable() {
    return timetableData.isEmpty
        ? const Center(child: Text('No timetable available'))
        : ListView.builder(
            itemCount: timetableData.length,
            itemBuilder: (context, index) {
              return _deleteTimetableData(
                  index); // Use the separate method for each entry
            },
          );
  }

  Widget _deleteTimetableData(int index) {
    final entry = timetableData[index];
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = isSelected ? null : index; // Toggle selection
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: isSelected ? 2 : 1,
                blurRadius: isSelected ? 5 : 2,
                offset: Offset(0, isSelected ? 5 : 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  entry['timeslot'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: Text(
                  entry['subject'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Text(
                  (entry['teacher']?.length ?? 0) > 12
                      ? '${entry['teacher']!.substring(0, min(entry['teacher']!.length, 12))}...'
                      : entry['teacher'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the dustbin button
  Widget _buildDustbinButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          _deleteTimetableEntry(selectedIndex!); // Delete the selected entry
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, // Set the button color to red
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
        child: const Text(
          '🗑️',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  // Build day button with short and full names
  Widget _buildDayButton(
      BuildContext context, String shortDay, String fullDay) {
    bool isSelected = selectedDay == fullDay;

    const LinearGradient selectedGradient = LinearGradient(
      colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final Color unselectedColor =
        Colors.grey[300]!; // Grey color for unselected day

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            selectedDay = fullDay; // Update selected day
            timetableData
                .clear(); // Clear previous timetable data for the new selection
            selectedIndex = null; // Reset selected index
          });
          _fetchTimetableForDay(fullDay); // Fetch timetable for the new day
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          gradient: isSelected ? selectedGradient : null,
          color: isSelected ? null : unselectedColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ]
              : [],
        ),
        child: Text(
          shortDay, // Display short day label (e.g., "Mon")
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
