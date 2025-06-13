// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceTakingPage extends StatefulWidget {
  final String selectedClass;
  final String selectedDate;

  const AttendanceTakingPage({
    super.key,
    required this.selectedClass,
    required this.selectedDate,
  });

  @override
  _AttendanceTakingPageState createState() => _AttendanceTakingPageState();
}

class _AttendanceTakingPageState extends State<AttendanceTakingPage> {
  final Map<String, String?> attendanceStatus = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildStudentList(),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Attendance Taking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            widget.selectedDate,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildStudentList() {
    return FutureBuilder<List<Map<String, String>>>(
      future: fetchChildList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching data'));
        }

        final children = snapshot.data;

        if (children == null || children.isEmpty) {
          return const Center(child: Text('No students found for this class'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              final childId = child['id']!;
              attendanceStatus.putIfAbsent(childId, () => null);

              return _buildStudentTile(childId);
            },
          ),
        );
      },
    );
  }

  Widget _buildStudentTile(String childId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchChildData(childId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(title: Text('Loading...'));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const ListTile(title: Text('Error loading data'));
        }

        final childData = snapshot.data!;
        final childName = childData['nameC'] as String;
        final profileImage = childData['profileImage'] as String;

        return _buildStudentCard(childId, childName, profileImage);
      },
    );
  }

  Widget _buildStudentCard(
      String childId, String childName, String profileImage) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: profileImage.isNotEmpty
                ? NetworkImage(profileImage)
                : const AssetImage('assets/images/default_avatar.png')
                    as ImageProvider,
            radius: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          _buildDropdown(childId),
        ],
      ),
    );
  }

  Widget _buildDropdown(String childId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: attendanceStatus[childId] == 'present'
            ? Colors.grey[200]
            : attendanceStatus[childId] == 'absent'
                ? Colors.grey[100]
                : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String?>(
        value: attendanceStatus[childId],
        hint: const Text('Status', style: TextStyle(color: Colors.black54)),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
        dropdownColor: Colors.white,
        items: const [
          DropdownMenuItem(
            value: 'present',
            child: Text('Present', style: TextStyle(color: Colors.black87)),
          ),
          DropdownMenuItem(
            value: 'absent',
            child: Text('Absent', style: TextStyle(color: Colors.black87)),
          ),
        ],
        onChanged: (String? newValue) {
          setState(() {
            attendanceStatus[childId] = newValue;
          });
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
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
          onPressed: submitAttendance,
          child: const Text(
            'Submit',
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

  Future<List<Map<String, String>>> fetchChildList() async {
    final snapshot = await FirebaseFirestore.instance.collection('child').get();
    return snapshot.docs.where((doc) {
      return doc['SectionA']['yearID'] == widget.selectedClass;
    }).map((doc) {
      return {
        'id': doc.id,
      };
    }).toList();
  }

  Future<Map<String, dynamic>> fetchChildData(String childId) async {
    String? childName = await fetchChildName(childId);
    String profileImage = await fetchChildProfileImage(childId);
    return {
      'nameC': childName ?? 'Unknown',
      'profileImage': profileImage,
    };
  }

  Future<String?> fetchChildName(String childId) async {
    DocumentSnapshot childDoc =
        await FirebaseFirestore.instance.collection('child').doc(childId).get();
    return childDoc.exists ? childDoc['SectionA']['nameC'] as String : null;
  }

  Future<String> fetchChildProfileImage(String childId) async {
    DocumentSnapshot childDoc =
        await FirebaseFirestore.instance.collection('child').doc(childId).get();
    if (childDoc.exists) {
      final data = childDoc.data() as Map<String, dynamic>;
      if (data.containsKey('profileImage')) {
        return data['profileImage'] as String;
      }
    }
    return ''; // Return an empty string if no image exists
  }

  void submitAttendance() async {
    bool allStatusSelected =
        attendanceStatus.entries.every((entry) => entry.value != null);

    if (!allStatusSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please choose a status for all children first!')),
      );
      return;
    }

    CollectionReference timetableCollection =
        FirebaseFirestore.instance.collection('attendance');
    DocumentReference attendanceDoc =
        timetableCollection.doc(widget.selectedClass);
    DocumentSnapshot timetableSnapshot = await attendanceDoc.get();

    List<dynamic> attendanceHistory = [];
    List<dynamic> attendanceRecord = [];

    if (timetableSnapshot.exists) {
      attendanceHistory = timetableSnapshot['attendanceHistory'];
      attendanceRecord = timetableSnapshot['attendanceRecord'];
    }

    Timestamp currentTimestamp = Timestamp.now();

    await Future.forEach(attendanceStatus.entries, (entry) async {
      final childId = entry.key;
      final status = entry.value;

      if (status == null) return;

      await updateAttendanceHistory(
          attendanceHistory, childId, status, currentTimestamp);
      await updateAttendanceRecord(
          attendanceRecord, attendanceHistory, childId);
    });

    await attendanceDoc.set(
      {
        'yearID': widget.selectedClass,
        'attendanceHistory': attendanceHistory,
        'attendanceRecord': attendanceRecord,
      },
      SetOptions(merge: true),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Attendance submitted successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );

    setState(() {
      attendanceStatus.clear();
    });
  }

  Future<void> updateAttendanceHistory(List<dynamic> attendanceHistory,
      String childId, String status, Timestamp timestamp) async {
    var childRecordHistory = attendanceHistory.firstWhere(
        (record) => record['childID'] == childId,
        orElse: () => null);

    if (childRecordHistory != null) {
      var recordForDate = childRecordHistory['records'].firstWhere(
          (record) => record['date'] == widget.selectedDate,
          orElse: () => null);

      if (recordForDate != null) {
        recordForDate['status'] = status;
        recordForDate['arrivedAt'] = timestamp; // Rename to arrivedAt
        recordForDate['returnAt'] = null; // Add returnAt field
      } else {
        childRecordHistory['records'].add({
          'date': widget.selectedDate,
          'status': status,
          'arrivedAt': timestamp,
          'returnAt': null,
        });
      }
    } else {
      attendanceHistory.add({
        'childID': childId,
        'records': [
          {
            'date': widget.selectedDate,
            'status': status,
            'arrivedAt': timestamp,
            'returnAt': null,
          }
        ],
      });
    }
  }

  Future<void> updateAttendanceRecord(List<dynamic> attendanceRecord,
      List<dynamic> attendanceHistory, String childId) async {
    int totalDays = 0;
    int daysPresent = 0;

    var updatedChildRecordHistory = attendanceHistory.firstWhere(
        (record) => record['childID'] == childId,
        orElse: () => null);

    if (updatedChildRecordHistory != null) {
      totalDays = updatedChildRecordHistory['records'].length;
      daysPresent = updatedChildRecordHistory['records']
          .where((record) => record['status'] == 'present')
          .length;
    }

    var childRecordAttendance = attendanceRecord.firstWhere(
        (record) => record['childID'] == childId,
        orElse: () => null);

    if (childRecordAttendance != null) {
      childRecordAttendance['totalDays'] = totalDays;
      childRecordAttendance['daysPresent'] = daysPresent;
      childRecordAttendance['attendancePercentage'] =
          (totalDays > 0) ? (daysPresent / totalDays) * 100 : 0;
    } else {
      attendanceRecord.add({
        'childID': childId,
        'totalDays': totalDays,
        'daysPresent': daysPresent,
        'attendancePercentage':
            (totalDays > 0) ? (daysPresent / totalDays) * 100 : 0,
      });
    }
  }
}
