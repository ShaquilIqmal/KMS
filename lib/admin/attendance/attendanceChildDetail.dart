import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceChildDetailPage extends StatefulWidget {
  final String childID;
  final String yearID;

  const AttendanceChildDetailPage({
    Key? key,
    required this.childID,
    required this.yearID,
  }) : super(key: key);

  @override
  State<AttendanceChildDetailPage> createState() =>
      _AttendanceChildDetailPageState();
}

class _AttendanceChildDetailPageState extends State<AttendanceChildDetailPage> {
  final CollectionReference attendanceCollection =
      FirebaseFirestore.instance.collection('attendance');

  List<Map<String, dynamic>> attendanceRecords = [];
  String childName = 'Loading...';
  String profileImage = '';

  @override
  void initState() {
    super.initState();
    fetchChildDetails();
    checkAttendanceCollection();
  }

  Future<void> fetchChildDetails() async {
    childName = await fetchChildName(widget.childID);
    profileImage = await fetchChildProfileImage(widget.childID);
    setState(() {}); // Refresh UI after fetching details
  }

  Future<void> checkAttendanceCollection() async {
    try {
      QuerySnapshot snapshot = await attendanceCollection.get();
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Check if attendanceHistory is not null and is a list before iterating
        if (data['attendanceHistory'] != null &&
            data['attendanceHistory'] is List) {
          for (var history in data['attendanceHistory']) {
            if (history['childID'] == widget.childID) {
              for (var record in history['records']) {
                // Check if attendanceRecord exists and is a list before accessing it
                if (data['attendanceRecord'] != null &&
                    data['attendanceRecord'] is List) {
                  var attendanceRecord = data['attendanceRecord'].firstWhere(
                      (rec) => rec['childID'] == history['childID'],
                      orElse: () => null);

                  if (attendanceRecord != null) {
                    // Calculate daysPresent
                    int presentCount = 0;
                    for (var rec in history['records']) {
                      if (rec['status'] == 'present') {
                        presentCount++;
                      }
                    }

                    // Calculate attendancePercentage
                    attendanceRecord['daysPresent'] = presentCount;
                    attendanceRecord['attendancePercentage'] =
                        (attendanceRecord['daysPresent'] /
                                attendanceRecord['totalDays']) *
                            100;

                    // Add the calculated attendance percentage to the local record
                    attendanceRecords.add({
                      'date': record['date'],
                      'status': record['status'],
                      'docId': doc.id, // Store document ID for updates
                      'historyId':
                          history['childID'], // To identify the correct history
                      'attendancePercentage': attendanceRecord[
                          'attendancePercentage'], // Add attendance percentage
                    });
                  }
                }
              }
            }
          }
        }
      }
      setState(() {}); // Refresh the UI after fetching data
    } catch (e) {
      print('Error fetching attendance collection: $e');
    }
  }

  Future<void> updateStatus(
      String date, String newStatus, String docId, String historyId) async {
    try {
      // Get the reference to the document
      DocumentReference docRef = attendanceCollection.doc(docId);

      // Fetch the current data
      DocumentSnapshot snapshot = await docRef.get();
      var data = snapshot.data() as Map<String, dynamic>;

      // Locate the specific history entry
      Map<String, dynamic>? targetHistory;
      for (var history in data['attendanceHistory']) {
        if (history['childID'] == historyId) {
          targetHistory = history;
          break;
        }
      }

      // Update the status in the records
      if (targetHistory != null) {
        for (var record in targetHistory['records']) {
          if (record['date'] == date) {
            // Update the status
            record['status'] = newStatus;
            break;
          }
        }

        // Update daysPresent based on the new status
        var attendanceRecord = data['attendanceRecord']
            .firstWhere((rec) => rec['childID'] == historyId);

        // Count the number of "present" statuses
        int presentCount = 0;
        for (var record in targetHistory['records']) {
          if (record['status'] == 'present') {
            presentCount++;
          }
        }

        // Update daysPresent
        attendanceRecord['daysPresent'] = presentCount;

        // Update attendancePercentage
        attendanceRecord['attendancePercentage'] =
            (attendanceRecord['daysPresent'] / attendanceRecord['totalDays']) *
                100;

        // Save the updated data back to Firestore
        await docRef.update(data);

        // Update the local attendanceRecords to reflect the new status and percentage
        for (var record in attendanceRecords) {
          if (record['date'] == date && record['docId'] == docId) {
            record['status'] = newStatus; // Update the local record's status
            record['attendancePercentage'] = attendanceRecord[
                'attendancePercentage']; // Update the local record's percentage
            break;
          }
        }
      }

      // Refresh the local state to reflect the change
      setState(() {});
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  // Fetch child's name from Firestore using childID
  Future<String> fetchChildName(String childID) async {
    DocumentSnapshot childDoc =
        await FirebaseFirestore.instance.collection('child').doc(childID).get();
    return childDoc.exists
        ? childDoc['SectionA']['nameC'] as String
        : 'Unknown';
  }

  // Fetch child's profile image from Firestore using childID
  Future<String> fetchChildProfileImage(String childID) async {
    DocumentSnapshot childDoc =
        await FirebaseFirestore.instance.collection('child').doc(childID).get();
    if (childDoc.exists) {
      final data = childDoc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('profileImage')) {
        return data['profileImage'] as String;
      }
    }
    return ''; // Return an empty string if no image exists or document does not exist
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Attendance Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            Navigator.pop(
                context, true); // Pass true to indicate changes were made
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildChildInfo(),
            attendanceRecords.isEmpty
                ? const Center(
                    child:
                        CircularProgressIndicator(), // Show loading indicator while fetching data
                  )
                : _buildAttendanceList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChildInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
            child: profileImage.isEmpty
                ? const Icon(Icons.person, size: 30, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            childName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center, // Center-align the text
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    return Column(
      children: attendanceRecords.map((record) {
        return _buildAttendanceListItem(record);
      }).toList(),
    );
  }

  Widget _buildAttendanceListItem(Map<String, dynamic> record) {
    final attendancePercentage = record['attendancePercentage'] ?? 0.0;
    final percentageColor =
        attendancePercentage > 50.00 ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: ${record['date']}',
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Status:',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: record['status'],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            updateStatus(
                              record['date'],
                              newValue,
                              record['docId'],
                              record['historyId'],
                            );
                          }
                        },
                        items: <String>['present', 'absent']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Text(
                    '${attendancePercentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: percentageColor,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
