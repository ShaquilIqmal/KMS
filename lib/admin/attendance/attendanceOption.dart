import 'package:flutter/material.dart';
import 'attendanceByWeek.dart';
import 'attendanceManagementAdmin.dart';

class AttendanceOption extends StatelessWidget {
  const AttendanceOption({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Attendance Options',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildOptionCard(
              context,
              'Individual Attendance',
              Icons.person,
              () {
                // Navigate to Individual Attendance page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceManagementAdminPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            _buildOptionCard(
              context,
              'Attendance by Week',
              Icons.calendar_today,
              () {
                // Navigate to By Week Attendance page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceByWeekPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String label, IconData icon,
      VoidCallback onPressed) {
    return Card(
      elevation: 4.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 40.0, color: Colors.grey[800]),
              const SizedBox(width: 16.0),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
