// ignore_for_file: file_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../service/database_service.dart';

class CheckAttendancePage extends StatefulWidget {
  final String childId;
  final String selectedYear;

  const CheckAttendancePage({
    super.key,
    required this.childId,
    required this.selectedYear,
  });

  @override
  State<CheckAttendancePage> createState() => _CheckAttendancePageState();
}

class _CheckAttendancePageState extends State<CheckAttendancePage> {
  String childName = 'Loading...';
  List<Map<String, dynamic>> attendanceHistory = [];
  double attendancePercentage = 0.0;
  bool isLoading = true;
  String? childProfileImage;

  @override
  void initState() {
    super.initState();
    fetchChildDetails();
    fetchChildAttendance();
  }

  Future<void> fetchChildDetails() async {
    try {
      var childDetails =
          await DatabaseService().getChildDetailsById(widget.childId);
      setState(() {
        childName = childDetails['name'];
        childProfileImage =
            childDetails['profileImage']; // Update the profile image
      });
    } catch (e) {
      print('Error fetching child details: $e');
    }
  }

  Future<void> fetchChildAttendance() async {
    try {
      // Fetch all attendance data
      QuerySnapshot snapshot =
          await DatabaseService().attendanceCollection.get();
      bool attendanceFound = false;

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Fetch attendanceHistory
        List<dynamic> attendanceHistoryData = data['attendanceHistory'];

        for (var record in attendanceHistoryData) {
          if (record['childID'] == widget.childId) {
            setState(() {
              attendanceHistory =
                  List<Map<String, dynamic>>.from(record['records']);
              isLoading = false; // Stop loading once data is fetched
            });
            attendanceFound = true;
            break;
          }
        }

        // Fetch attendancePercentage
        List<dynamic> attendanceRecordData = data['attendanceRecord'];
        for (var record in attendanceRecordData) {
          if (record['childID'] == widget.childId) {
            setState(() {
              attendancePercentage = record['attendancePercentage'];
            });
            break;
          }
        }
      }
      // If no attendance was found for this child
      if (!attendanceFound) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching attendance history: $e');
      setState(() {
        isLoading = false; // Stop loading even if there's an error
      });
    }
  }

  String formatTimestamp(Timestamp timestamp) => DateFormat('hh:mm a')
      .format(timestamp.toDate().add(const Duration(hours: 8)));

  String formatDate(String date) =>
      DateFormat('dd-MM-yyyy').format(DateTime.parse(date));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Attendance Details',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTopSection(),
                  const SizedBox(height: 16),
                  _buildAttendanceRecords(),
                ],
              ),
            ),
    );
  }

  Widget _buildTopSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 40, // Size of the circular icon
          backgroundImage:
              (childProfileImage != null && childProfileImage!.isNotEmpty)
                  ? NetworkImage(
                      childProfileImage!) // Use the child's profile image
                  : null, // No image provided
          backgroundColor: Colors.grey[200], // Background color for fallback
          child: (childProfileImage == null || childProfileImage!.isEmpty)
              ? const Icon(Icons.person,
                  size: 40, color: Colors.grey) // Placeholder icon
              : null, // No child widget if the image is loaded
        ),
        const SizedBox(height: 16),
        Text(
          childName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          widget.selectedYear,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time, color: Colors.blueAccent, size: 20),
            const SizedBox(width: 4),
            Text(
              'Attendance: ${attendancePercentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceRecords() {
    return Expanded(
      child: attendanceHistory.isEmpty
          ? const Center(
              child: Text(
                'No attendance records found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              itemCount: attendanceHistory.length,
              itemBuilder: (context, index) {
                var record = attendanceHistory[index];
                bool isToday = formatDate(record['date']) ==
                    DateFormat('dd-MM-yyyy').format(DateTime.now());

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.blue[50] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: record['status'] == 'present'
                            ? Colors.green
                            : Colors.red,
                        child: Icon(
                          record['status'] == 'present'
                              ? Icons.check
                              : Icons.close,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatDate(record['date']),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Arrived: ${record['arrivedAt'] != null ? formatTimestamp(record['arrivedAt']) : 'N/A'}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Returned: ${record['returnAt'] != null ? formatTimestamp(record['returnAt']) : 'N/A'}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: record['status'] == 'present'
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          record['status'].toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: record['status'] == 'present'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
