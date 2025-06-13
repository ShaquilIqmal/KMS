import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../service/database_service.dart';
import 'attendanceChildDetail.dart';

class AttendanceManagementAdminPage extends StatefulWidget {
  const AttendanceManagementAdminPage({super.key});

  @override
  State<AttendanceManagementAdminPage> createState() =>
      _AttendanceManagementAdminPageState();
}

class _AttendanceManagementAdminPageState
    extends State<AttendanceManagementAdminPage> {
  final DatabaseService _databaseService = DatabaseService();
  String selectedYearID = 'Year 4';
  List<Map<String, dynamic>> attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    fetchAttendanceData(selectedYearID);
  }

  // Function to fetch attendance data by yearID
  Future<void> fetchAttendanceData(String yearID) async {
    try {
      List<Map<String, dynamic>> records =
          await _databaseService.getAttendanceByYear(yearID);

      // Fetch child names and profile images from the child document
      List<Map<String, dynamic>> enrichedRecords =
          await Future.wait(records.map((record) async {
        String childID = record['childID'];
        String childName = await fetchChildName(childID); // Fetch child's name
        String profileImage = await fetchChildProfileImage(
            childID); // Fetch child's profile image
        return {
          ...record,
          'nameC': childName, // Add child name to the record
          'profileImage': profileImage, // Add profile image to the record
        };
      }));

      setState(() {
        attendanceRecords =
            enrichedRecords; // Update state with the fetched records
      });
    } catch (e) {
      print('Error fetching attendance data: $e');
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
      // Cast the data to a Map<String, dynamic>
      final data = childDoc.data() as Map<String, dynamic>?;
      // Check if the 'profileImage' field exists
      if (data != null && data.containsKey('profileImage')) {
        return data['profileImage'] as String;
      }
    }
    return ''; // Return an empty string if no image exists or document does not exist
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
        backgroundColor: Colors.grey[100],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildChooseClassContainer(),
            const SizedBox(height: 20),
            _buildAttendanceList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChooseClassContainer() {
    return Card(
      elevation: 1.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Class',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white, // Set the background color to white
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300, width: 1.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Colors
                          .white, // Set the dropdown menu background to white
                      value: selectedYearID,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedYearID = newValue;
                            fetchAttendanceData(newValue);
                          });
                        }
                      },
                      items: <String>['Year 4', 'Year 5', 'Year 6']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      isExpanded: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return Expanded(
      child: attendanceRecords.isNotEmpty
          ? ListView.builder(
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                return _buildAttendanceListItem(index);
              },
            )
          : const Center(
              child: Text('No students available for this year.'),
            ),
    );
  }

  Widget _buildAttendanceListItem(int index) {
    final record = attendanceRecords[index];
    final attendancePercentage = record['attendancePercentage'] ?? 0.0;
    final percentageColor =
        attendancePercentage > 50.00 ? Colors.green : Colors.red;

    return Card(
      elevation: 4.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttendanceChildDetailPage(
                childID: record['childID'],
                yearID: selectedYearID,
              ),
            ),
          ).then((shouldRefresh) {
            if (shouldRefresh == true) {
              fetchAttendanceData(selectedYearID);
            }
          });
        },
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: record['profileImage'] != null &&
                    record['profileImage'].isNotEmpty
                ? NetworkImage(record['profileImage'])
                : null,
            child:
                record['profileImage'] == null || record['profileImage'].isEmpty
                    ? const Icon(Icons.person, size: 30, color: Colors.grey)
                    : null,
          ),
          title: Text(
            record['nameC'] ?? 'Unknown',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          subtitle: Text(
            'Child ID: ${record['childID']}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          trailing: Text(
            '${attendancePercentage.toStringAsFixed(2)}%',
            style: TextStyle(
              color: percentageColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
