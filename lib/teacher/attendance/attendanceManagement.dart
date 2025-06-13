// ignore_for_file: file_names, use_super_parameters

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'attendanceEdit.dart';
import 'attendanceTaking.dart';

class AttendanceTeacherPage extends StatefulWidget {
  final String docId; // Teacher ID

  const AttendanceTeacherPage({Key? key, required this.docId})
      : super(key: key);

  @override
  State<AttendanceTeacherPage> createState() => _AttendanceTeacherPageState();
}

class _AttendanceTeacherPageState extends State<AttendanceTeacherPage> {
  String? selectedClass = 'Year 4';
  List<String> assignedClasses = [];
  DateTime selectedDate = DateTime.now();
  String? formattedDate;
  List<String> attendanceDates = [];

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchAssignedClasses();
    fetchAttendanceRecords();
  }

  Future<void> fetchAssignedClasses() async {
    var doc = await FirebaseFirestore.instance
        .collection('teachers')
        .doc(widget.docId)
        .get();

    setState(() {
      assignedClasses = List<String>.from(doc['assignedClasses']);
    });
  }

  Future<void> fetchAttendanceRecords() async {
    if (selectedClass == null) return;

    var attendanceSnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .doc(selectedClass)
        .get();

    if (attendanceSnapshot.exists) {
      List<dynamic> attendanceHistory = attendanceSnapshot['attendanceHistory'];

      // Extract unique dates from the attendance history records
      Set<String> uniqueDates = {};
      for (var record in attendanceHistory) {
        for (var attendance in record['records']) {
          uniqueDates.add(attendance['date']);
        }
      }

      setState(() {
        // Sort the dates in descending order to display the most recent first
        attendanceDates = uniqueDates.toList()
          ..sort((a, b) => b.compareTo(a)); // Sort in descending order
      });
    } else {
      setState(() {
        attendanceDates = []; // Clear if no records exist
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Ensure the initial date does not exceed the last date
    DateTime lastDate = DateTime.now();
    DateTime initialDate =
        selectedDate.isAfter(lastDate) ? lastDate : selectedDate;

    // Ensure the initial date is a valid weekday
    while (initialDate.weekday == DateTime.saturday ||
        initialDate.weekday == DateTime.sunday) {
      initialDate = initialDate
          .subtract(const Duration(days: 1)); // Move to the previous weekday
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year, 1, 1),
      lastDate: lastDate,
      selectableDayPredicate: (DateTime day) {
        // Disable Saturdays (weekday == 6) and Sundays (weekday == 7)
        return day.weekday != DateTime.saturday &&
            day.weekday != DateTime.sunday;
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  void _navigateToAttendanceTaking() {
    if (selectedClass != null && formattedDate != null) {
      if (attendanceDates.contains(formattedDate)) {
        _showSnackBar('Attendance has already been created for this date.');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceTakingPage(
              selectedClass: selectedClass!,
              selectedDate: formattedDate!,
            ),
          ),
        );
      }
    } else {
      _showSnackBar('Please select a class and a date.');
    }
  }

  void _onDateSelected(String date) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceEditPage(
          selectedClass: selectedClass!,
          selectedDate: date,
        ),
      ),
    );

    if (result == true) {
      fetchAttendanceRecords();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Attendance Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCreateAttendanceCard(),
              const SizedBox(height: 20.0),
              if (attendanceDates.isNotEmpty) _buildAttendanceRecordsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAttendanceCard() {
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
          const Text(
            'Create Attendance',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12.0),
          _buildClassSelector(),
          const SizedBox(height: 16.0),
          _buildDateSelector(),
          const SizedBox(height: 20.0),
          Center(
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
                  onPressed: _navigateToAttendanceTaking,
                  child: const Text(
                    'Create Attendance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
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

  Widget _buildClassSelector() {
    return Container(
      padding: const EdgeInsets.all(12.0),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Select Class',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButton<String>(
              value: selectedClass,
              hint: const Text('Select',
                  style: TextStyle(color: Colors.blueAccent)),
              onChanged: (String? newValue) {
                setState(() {
                  selectedClass = newValue;
                });
                fetchAttendanceRecords();
              },
              dropdownColor: Colors.white,
              items: assignedClasses
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ))
                  .toList(),
              underline: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(12.0),
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
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formattedDate ?? 'Select Date',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRecordsCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
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
          const Text(
            'Attendance Records',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10.0),
          const Text(
            '*Click any date to view attendance details.',
            style: TextStyle(
              fontSize: 13.0,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            height: 350.0,
            child: ListView.builder(
              itemCount: attendanceDates.length,
              itemBuilder: (context, index) {
                String date = attendanceDates[index];
                String displayDate =
                    DateFormat('dd MMM yyyy').format(DateTime.parse(date));
                if (date == DateFormat('yyyy-MM-dd').format(DateTime.now())) {
                  displayDate += ' (Today)';
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    title: Text(
                      displayDate,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black,
                    ),
                    onTap: () => _onDateSelected(date),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
