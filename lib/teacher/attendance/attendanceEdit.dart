// ignore_for_file: file_names, use_super_parameters, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceEditPage extends StatefulWidget {
  final String selectedClass;
  final String selectedDate;

  const AttendanceEditPage({
    Key? key,
    required this.selectedClass,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _AttendanceEditPageState createState() => _AttendanceEditPageState();
}

class _AttendanceEditPageState extends State<AttendanceEditPage> {
  final Map<String, String?> attendanceStatus = {};
  final Map<String, String?> returnAtStatus = {};
  final List<Map<String, dynamic>> children = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChildList();
  }

  Future<void> fetchChildList() async {
    try {
      var attendanceSnapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.selectedClass)
          .get();

      if (attendanceSnapshot.exists) {
        List<dynamic> attendanceHistory =
            attendanceSnapshot['attendanceHistory'];

        for (var record in attendanceHistory) {
          String childId = record['childID'];
          var childSnapshot = await FirebaseFirestore.instance
              .collection('child')
              .doc(childId)
              .get();

          if (childSnapshot.exists) {
            String childName = childSnapshot['SectionA']['nameC'] as String;

            // Check if profileImage field exists, otherwise use an empty string
            String? profileImage = childSnapshot.data()?['profileImage'] ?? '';

            List<dynamic> records = record['records'] ?? [];
            var arrivedAt = records.firstWhere(
              (attendance) => attendance['date'] == widget.selectedDate,
              orElse: () => null,
            )?['arrivedAt'];

            var returnAt = records.firstWhere(
              (attendance) => attendance['date'] == widget.selectedDate,
              orElse: () => null,
            )?['returnAt'];

            children.add({
              'id': childId,
              'name': childName,
              'profileImage': profileImage,
              'arrivedAt': arrivedAt is Timestamp ? arrivedAt : null,
              'returnAt': returnAt is Timestamp ? returnAt : null,
            });

            // Ensure status is nullable (String?)
            String? status = records.firstWhere(
              (attendance) => attendance['date'] == widget.selectedDate,
              orElse: () => {'status': null},
            )['status'];

            attendanceStatus[childId] = status;

            if (status == 'absent') {
              returnAtStatus[childId] = null;
            } else {
              returnAtStatus[childId] = returnAt == null ? null : 'Yes';
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching child list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refreshChildData(String childId) async {
    try {
      var attendanceSnapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.selectedClass)
          .get();

      if (attendanceSnapshot.exists) {
        List<dynamic> attendanceHistory =
            attendanceSnapshot['attendanceHistory'];

        for (var record in attendanceHistory) {
          if (record['childID'] == childId) {
            List<dynamic> records = record['records'] ?? [];

            var arrivedAt = records.firstWhere(
              (attendance) => attendance['date'] == widget.selectedDate,
              orElse: () => null,
            )?['arrivedAt'];

            var returnAt = records.firstWhere(
              (attendance) => attendance['date'] == widget.selectedDate,
              orElse: () => null,
            )?['returnAt'];

            setState(() {
              int index =
                  children.indexWhere((child) => child['id'] == childId);
              if (index != -1) {
                children[index]['arrivedAt'] =
                    arrivedAt is Timestamp ? arrivedAt : null;
                children[index]['returnAt'] =
                    returnAt is Timestamp ? returnAt : null;
              }
            });
            break;
          }
        }
      }
    } catch (e) {
      print('Error refreshing child data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error refreshing data')),
      );
    }
  }

  Future<void> updateAttendanceStatus(String childId, String? newStatus) async {
    try {
      var attendanceSnapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.selectedClass)
          .get();

      if (attendanceSnapshot.exists) {
        List<dynamic> attendanceHistory =
            attendanceSnapshot['attendanceHistory'];

        for (var record in attendanceHistory) {
          if (record['childID'] == childId) {
            List<dynamic> records = record['records'] ?? [];

            for (var attendance in records) {
              if (attendance['date'] == widget.selectedDate) {
                if (newStatus == 'absent') {
                  attendance['arrivedAt'] = null;
                } else {
                  attendance['arrivedAt'] = Timestamp.now();
                }
                attendance['status'] = newStatus;
                break;
              }
            }
            break;
          }
        }

        await FirebaseFirestore.instance
            .collection('attendance')
            .doc(widget.selectedClass)
            .update({
          'attendanceHistory': attendanceHistory,
        });

        await updateAttendanceRecord(childId);
      }
    } catch (e) {
      print('Error updating attendance status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating status')),
      );
    }
  }

  Future<void> updateReturnStatus(
      String childId, String? newReturnStatus) async {
    try {
      var attendanceSnapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.selectedClass)
          .get();

      if (attendanceSnapshot.exists) {
        List<dynamic> attendanceHistory =
            attendanceSnapshot['attendanceHistory'];

        for (var record in attendanceHistory) {
          if (record['childID'] == childId) {
            List<dynamic> records = record['records'] ?? [];

            for (var attendance in records) {
              if (attendance['date'] == widget.selectedDate) {
                attendance['returnAt'] =
                    newReturnStatus == 'Yes' ? Timestamp.now() : null;
                break;
              }
            }
            break;
          }
        }

        await FirebaseFirestore.instance
            .collection('attendance')
            .doc(widget.selectedClass)
            .update({
          'attendanceHistory': attendanceHistory,
        });

        await updateAttendanceRecord(childId);
      }
    } catch (e) {
      print('Error updating return status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating return status')),
      );
    }
  }

  Future<void> updateAttendanceRecord(String childId) async {
    try {
      var attendanceSnapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.selectedClass)
          .get();

      if (attendanceSnapshot.exists) {
        List<dynamic> attendanceHistory =
            attendanceSnapshot['attendanceHistory'];

        var childRecord = attendanceHistory.firstWhere(
          (record) => record['childID'] == childId,
          orElse: () => null,
        );

        if (childRecord != null) {
          int totalDays = childRecord['records'].length;
          int daysPresent = childRecord['records']
              .where((record) => record['status'] == 'present')
              .length;

          var attendanceRecord = attendanceSnapshot['attendanceRecord'] ?? [];
          var childAttendanceRecord = attendanceRecord.firstWhere(
            (record) => record['childID'] == childId,
            orElse: () => null,
          );

          if (childAttendanceRecord != null) {
            childAttendanceRecord['totalDays'] = totalDays;
            childAttendanceRecord['daysPresent'] = daysPresent;
            childAttendanceRecord['attendancePercentage'] =
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

          await FirebaseFirestore.instance
              .collection('attendance')
              .doc(widget.selectedClass)
              .update({
            'attendanceRecord': attendanceRecord,
          });
        }
      }
    } catch (e) {
      print('Error updating attendance record: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating attendance record')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: children.length,
                      itemBuilder: (context, index) {
                        final child = children[index];
                        return _buildChildItem(child);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Edit Attendance',
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context, true);
        },
      ),
      backgroundColor: Colors.white,
    );
  }

  Container _buildChildItem(Map<String, dynamic> child) {
    final childId = child['id']!;
    final childName = child['name']!;
    final profileImage = child['profileImage']!;
    final timestamp =
        child['arrivedAt'] != null && child['arrivedAt'] is Timestamp
            ? (child['arrivedAt'] as Timestamp).toDate()
            : null;
    final returnTimestamp =
        child['returnAt'] != null && child['returnAt'] is Timestamp
            ? (child['returnAt'] as Timestamp).toDate()
            : null;

    String formattedArrivedTime = timestamp != null
        ? "${timestamp.add(const Duration(hours: 8)).hour.toString().padLeft(2, '0')}:${timestamp.add(const Duration(hours: 8)).minute.toString().padLeft(2, '0')}"
        : "  ";

    String formattedReturnTime = returnTimestamp != null
        ? "${returnTimestamp.add(const Duration(hours: 8)).hour.toString().padLeft(2, '0')}:${returnTimestamp.add(const Duration(hours: 8)).minute.toString().padLeft(2, '0')}"
        : " N/A";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  Colors.grey, // Set the background color for the icon
              radius: 30,
              child: profileImage.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        profileImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
            ),

            const SizedBox(width: 12.0), // Add spacing between avatar and text
            Expanded(
              child: _buildChildTitle(
                  childName, formattedArrivedTime, formattedReturnTime),
            ),
            _buildChildActions(childId),
          ],
        ),
      ),
    );
  }

  Column _buildChildTitle(String childName, String formattedArrivedTime,
      String formattedReturnTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          childName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16, // Increased font size for better readability
          ),
        ),
        const SizedBox(height: 4.0), // Added spacing between texts
        Text(
          "Arrived: $formattedArrivedTime",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2.0), // Added spacing between texts
        Text(
          "Returned: $formattedReturnTime",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Column _buildChildActions(String childId) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionLabel('Attendance'),
        _buildAttendanceDropdown(childId),
        const SizedBox(height: 8),
        _buildActionLabel('Return Status'),
        _buildReturnStatusDropdown(childId),
      ],
    );
  }

  Widget _buildActionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAttendanceDropdown(String childId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: attendanceStatus[childId] == 'present'
            ? Colors.greenAccent.withOpacity(0.4)
            : attendanceStatus[childId] == 'absent'
                ? Colors.redAccent.withOpacity(0.4)
                : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: attendanceStatus[childId],
          hint: const Text(
            'Select Status',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          items: const [
            DropdownMenuItem(
              value: 'present',
              child: Text(
                'Present',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400),
              ),
            ),
            DropdownMenuItem(
              value: 'absent',
              child: Text(
                'Absent',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
          onChanged: (String? newValue) {
            setState(() {
              attendanceStatus[childId] = newValue;
              if (newValue == 'absent') {
                returnAtStatus[childId] = null;
              }
            });
            updateAttendanceStatus(childId, newValue);
            refreshChildData(childId);
          },
          dropdownColor: Colors.white,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildReturnStatusDropdown(String childId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: returnAtStatus[childId] == 'Yes'
            ? Colors.greenAccent.withOpacity(0.4)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: returnAtStatus[childId],
          hint: const Text(
            '-',
            style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w400),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          items: const [
            DropdownMenuItem(
              value: 'Yes',
              child: Text(
                'Yes',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400),
              ),
            ),
            DropdownMenuItem(
              value: 'No',
              child: Text(
                'No',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
          onChanged: attendanceStatus[childId] == 'absent'
              ? null
              : (String? newValue) {
                  setState(() {
                    returnAtStatus[childId] = newValue;
                  });
                  updateReturnStatus(childId, newValue);
                  refreshChildData(childId);
                },
          dropdownColor: Colors.white,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }
}
