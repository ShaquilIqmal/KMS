// ignore_for_file: library_private_types_in_public_api, unused_local_variable, prefer_const_constructors, deprecated_member_use, sort_child_properties_last, unnecessary_this, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../service/database_service.dart';
import '../../teacher/attendance/attendanceEdit.dart';

class AttendanceByWeekPage extends StatefulWidget {
  const AttendanceByWeekPage({Key? key}) : super(key: key);

  @override
  _AttendanceByWeekPageState createState() => _AttendanceByWeekPageState();
}

class _AttendanceByWeekPageState extends State<AttendanceByWeekPage> {
  DateTime startOfWeek;
  String? selectedYear = 'Year 4';
  List<Map<String, dynamic>> attendanceDetails = [];
  DateTime? selectedDate;
  final DatabaseService dbService = DatabaseService();
  List<double> attendanceRatios = []; // To store attendance ratios

  _AttendanceByWeekPageState()
      : startOfWeek =
            DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // Set the default selected date to today
    fetchAttendance(selectedDate!); // Fetch attendance for today
    checkAttendance();
  }

  Future<void> checkAttendance() async {
    await dbService.checkAttendanceCollection();
  }

  Future<void> fetchAttendance(DateTime date) async {
    String yearDocumentId = selectedYear == 'Year 4'
        ? 'Year 4'
        : selectedYear == 'Year 5'
            ? 'Year 5'
            : 'Year 6';

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .doc(yearDocumentId)
        .get();

    if (snapshot.exists) {
      List<dynamic> attendanceHistory = snapshot['attendanceHistory'];
      List<Map<String, dynamic>> details = [];
      String formattedSelectedDate = DateFormat('yyyy-MM-dd').format(date);
      attendanceRatios.clear(); // Clear previous ratios

      for (var i = 0; i < 5; i++) {
        // Check past 5 days
        DateTime checkDate = startOfWeek.add(Duration(days: i));
        int totalChildren = 0;
        int presentChildren = 0;

        for (var record in attendanceHistory) {
          String childID = record['childID'];

          for (var childRecord in record['records']) {
            String recordDate = childRecord['date'];

            if (recordDate == DateFormat('yyyy-MM-dd').format(checkDate)) {
              totalChildren++;
              if (childRecord['status'] == 'present') {
                presentChildren++;
              }
            }
          }
        }

        // Calculate the ratio and add it to the list
        double ratio =
            totalChildren > 0 ? presentChildren / totalChildren : 0.0;
        attendanceRatios.add(ratio);
      }

      // Now fetch details for the selected date
      for (var record in attendanceHistory) {
        String childID = record['childID'];

        for (var childRecord in record['records']) {
          String recordDate = childRecord['date'];

          if (recordDate == formattedSelectedDate) {
            var childInfo = await _getChildInfo(childID);
            details.add({
              'childName': childInfo['name'],
              'profileImage': childInfo['profileImage'],
              'arrivedAt': childRecord['arrivedAt'] != null
                  ? DateFormat('HH:mm').format(
                      childRecord['arrivedAt'].toDate().add(Duration(hours: 8)))
                  : 'N/A',
              'returnAt': childRecord['returnAt'] != null
                  ? DateFormat('HH:mm').format(
                      childRecord['returnAt'].toDate().add(Duration(hours: 8)))
                  : 'N/A',
              'status': childRecord['status'],
            });
          }
        }
      }

      setState(() {
        attendanceDetails = details;
      });
    } else {
      print('No document found for year: $yearDocumentId');
    }
  }

  Future<Map<String, String>> _getChildInfo(String childID) async {
    DocumentSnapshot childSnapshot =
        await FirebaseFirestore.instance.collection('child').doc(childID).get();

    if (childSnapshot.exists) {
      return {
        'name': childSnapshot['SectionA']['nameC'] ?? 'Unknown',
        'profileImage': childSnapshot['profileImage'] ?? '',
      };
    } else {
      return {
        'name': 'Unknown',
        'profileImage': '',
      };
    }
  }

  void _onAttendanceUpdated() {
    fetchAttendance(
        selectedDate!); // Refetch the attendance data after the update
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime currentWeekStart =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

    bool isCurrentWeek = startOfWeek.year == currentWeekStart.year &&
        startOfWeek.month == currentWeekStart.month &&
        startOfWeek.day == currentWeekStart.day;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Weekly Attendance',
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
        physics:
            const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when content is smaller
        child: Column(
          children: [
            _buildHeader(isCurrentWeek),
            _buildWeekDays(),
            const SizedBox(height: 10),
            _buildAttendanceList(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader(bool isCurrentWeek) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Light background color
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // Changes position of shadow
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedYear,
                items:
                    <String>['Year 4', 'Year 5', 'Year 6'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedYear = newValue;
                    selectedDate = DateTime.now(); // Set to current date
                    attendanceDetails.clear();
                    attendanceRatios.clear(); // Clear ratios on year change
                    fetchAttendance(
                        selectedDate!); // Fetch attendance for the current date
                  });
                },
                style: TextStyle(color: Colors.black, fontSize: 16.0),
                dropdownColor: Colors.white, // Dropdown menu background color
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.chevron_left,
                  color: Colors.grey[800]), // Blue color for the icon
              onPressed: _navigateToPreviousWeek,
            ),
            IconButton(
              icon: Icon(Icons.chevron_right,
                  color: isCurrentWeek
                      ? Colors.grey[100]
                      : Colors.grey[800]), // Conditional color
              onPressed: isCurrentWeek ? null : _navigateToNextWeek,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDays() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          DateTime date = startOfWeek.add(Duration(days: index));
          String dayInitials = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'][index];
          String formattedDate = DateFormat('MMM dd').format(date);
          double ratio =
              attendanceRatios.length > index ? attendanceRatios[index] : 0.0;
          String ratioText =
              ratio > 0 ? '${(ratio * 100).toStringAsFixed(0)}%' : '0%';

          bool isSelectedDate = selectedDate?.isSameDay(date) ?? false;

          return SizedBox(
            width: 55, // Reduced width
            height: 90, // Reduced height
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDate = date;
                });
                fetchAttendance(date);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .transparent, // Make the button background transparent
                padding: const EdgeInsets.all(0), // Remove default padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: isSelectedDate
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF8A2387),
                            Color(0xFFE94057),
                            Color(0xFFF27121)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null, // Gradient for selected state only
                  color: isSelectedDate
                      ? null
                      : Colors.white, // White background for non-selected
                  border: Border.all(
                      color: isSelectedDate ? Colors.transparent : Colors.grey),
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayInitials,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelectedDate
                              ? Colors.white
                              : Colors.black, // Change color if selected
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelectedDate
                              ? Colors.white
                              : Colors.black, // Change color if selected
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ratioText, // Display attendance ratio
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelectedDate
                              ? Colors.white
                              : Colors.black, // Change color if selected
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5, // Set a specific height
      child: ListView.builder(
        itemCount: attendanceDetails.length,
        itemBuilder: (context, index) {
          final attendance = attendanceDetails[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4.0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAttendanceDetail(attendance),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceDetail(Map<String, dynamic> attendance) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: attendance['profileImage'] != ''
              ? NetworkImage(attendance['profileImage'])
              : null,
          child: attendance['profileImage'] == ''
              ? Icon(Icons.person, size: 30, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Child Name: ${attendance['childName']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Arrived At: ${attendance['arrivedAt']}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                'Return At: ${attendance['returnAt']}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4), // Add some space before the status
              Text(
                'Status: ${attendance['status']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: attendance['status'] == 'present'
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        if (selectedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => AttendanceEditPage(
              selectedClass: selectedYear!,
              selectedDate: formattedDate,
            ),
          ))
              .then((_) {
            // Call _onAttendanceUpdated() after returning from the edit page
            _onAttendanceUpdated();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a date first.')),
          );
        }
      },
      backgroundColor: Colors.grey[800], // Background color to match theme
      child: const Icon(
        Icons.edit,
        color: Colors.white, // Ensure the icon color is visible
      ),
      tooltip: 'Edit',
    );
  }

  void _navigateToPreviousWeek() {
    setState(() {
      startOfWeek = startOfWeek.subtract(Duration(days: 7));
    });
    fetchAttendance(selectedDate!); // Fetch attendance for the updated week
  }

  void _navigateToNextWeek() {
    setState(() {
      startOfWeek = startOfWeek.add(Duration(days: 7));
    });
    fetchAttendance(selectedDate!); // Fetch attendance for the updated week
  }
}

extension DateTimeComparison on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
