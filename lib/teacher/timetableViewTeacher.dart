// ignore_for_file: file_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../service/database_service.dart';

class TeacherTimetablePage extends StatefulWidget {
  final String teacherId;

  const TeacherTimetablePage({super.key, required this.teacherId});

  @override
  State<TeacherTimetablePage> createState() => _TeacherTimetablePageState();
}

class _TeacherTimetablePageState extends State<TeacherTimetablePage> {
  List<String> timetableData = [];
  String selectedDay = 'Monday';
  bool isLoading = false;
  Map<String, List<String>> timetableCache = {};
  String? teacherName; // To hold the teacher's name

  @override
  void initState() {
    super.initState();
    _fetchTeacherName(); // Fetch teacher's name
  }

  // Fetch the teacher's name using DatabaseService
  Future<void> _fetchTeacherName() async {
    teacherName = await DatabaseService.fetchUserName(widget.teacherId);
    if (teacherName != null) {
      print('Teacher Name: $teacherName'); // Print the teacher's name
      _fetchTimetableForDay(
          selectedDay); // Fetch timetable data after getting the teacher's name
    } else {
      print('Teacher not found for ID: ${widget.teacherId}');
    }
  }

  // Fetch timetable data for the selected day
  Future<void> _fetchTimetableForDay(String day) async {
    if (timetableCache.containsKey(day)) {
      timetableData = timetableCache[day]!;
      setState(() {});
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot timeslotsSnapshot = await FirebaseFirestore.instance
          .collection('timetable') // Collection name
          .where('day', isEqualTo: day) // Filter by day
          .where('teacher', isEqualTo: teacherName) // Filter by teacher's name
          .get();

      timetableData.clear();

      for (var doc in timeslotsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String timeslot = data['timeslot'] ?? 'No timeslot';
        String subject = data['subject'] ?? 'No subject';
        String year = data['year'] ?? 'No year';

        String timetableEntry = '$timeslot - $subject -  $year';
        timetableData.add(timetableEntry);
      }

      timetableData.sort((a, b) {
        String timeA = a.split(' - ')[0]; // Extract timeslot for sorting
        String timeB = b.split(' - ')[0];
        return double.parse(timeA.split('-')[0])
            .compareTo(double.parse(timeB.split('-')[0]));
      });

      timetableCache[day] = List.from(timetableData);
      setState(() {});
    } catch (e) {
      print('Error fetching timetable for $day: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Timetable',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDaySelector(),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTimetableList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                .map((day) => _buildDayButton(day))
                .toList(),
          ),
        ),
      );

  Widget _buildDayButton(String day) {
    bool isSelected = selectedDay == day;
    LinearGradient selectedGradient;
    LinearGradient unselectedGradient;

    final dayColor = {
      'Monday': [Colors.blue, Colors.blueAccent],
      'Tuesday': [Colors.green, Colors.lightGreen],
      'Wednesday': [Colors.orange, Colors.deepOrange],
      'Thursday': [Colors.purple, Colors.purpleAccent],
      'Friday': [Colors.red, Colors.redAccent],
    };

    selectedGradient = LinearGradient(colors: dayColor[day]!);
    unselectedGradient = LinearGradient(colors: [
      dayColor[day]![0].withOpacity(0.1),
      dayColor[day]![1].withOpacity(0.1)
    ]);

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            selectedDay = day;
          });
          _fetchTimetableForDay(day);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 18.0),
        decoration: BoxDecoration(
          gradient: isSelected ? selectedGradient : unselectedGradient,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ]
              : [],
        ),
        child: Text(
          day.substring(0, 3),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTimetableList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 6.0, offset: Offset(2, 2))
            ],
          ),
          child: Row(
            children: ['Time', 'Subject', '           Year']
                .map((text) => _buildTimetableField(text))
                .toList(),
          ),
        ),
        Expanded(
          child: timetableData.isEmpty
              ? const Center(child: Text('No timetable available'))
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: timetableData.length,
                  itemBuilder: (context, index) {
                    final entry = timetableData[index].split(' - ');
                    return _buildTimetableEntry(entry);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTimetableEntry(List<String> entry) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 6.0, offset: Offset(2, 2))
        ],
      ),
      child: Row(
        children: [
          _buildTimetableField(entry[0], flex: 3),
          _buildTimetableField(entry[1], flex: 4, fontWeight: FontWeight.bold),
          _buildTimetableField(entry[2], flex: 2),
        ],
      ),
    );
  }

  Widget _buildTimetableField(String text,
      {int flex = 1, FontWeight fontWeight = FontWeight.normal}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
            fontSize: 15, fontWeight: fontWeight, color: Colors.black),
      ),
    );
  }
}
