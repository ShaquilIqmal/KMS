// ignore_for_file: file_names, use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kms2/teacher/dailySnap.dart/dailySnapOption.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';
import '../service/database_service.dart';
import '../service/zmodel/teachermodel.dart';
import 'attendance/attendanceManagement.dart';
import 'milestone/menuMilestone.dart';
import 'teacherNotification.dart';
import 'teacherProfile.dart';
import 'timetableViewTeacher.dart';

class TeacherDashboardPage extends StatefulWidget {
  final String docId;

  const TeacherDashboardPage({Key? key, required this.docId}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<TeacherDashboardPage> {
  String? name;
  String? profileImage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeacherData();
  }

  Future<void> fetchTeacherData() async {
    Teacher? teacher = await DatabaseService.fetchTeacherData(widget.docId);
    setState(() {
      name = teacher?.name;
      profileImage = teacher?.profileImage;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomHeader(),
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildMainMenuSection(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40.0),
          bottomRight: Radius.circular(40.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              _buildProfileSection(),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TeacherNotificationPage(teacherDocId: widget.docId),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                color: Colors.black,
                onPressed: () {
                  // Show confirmation dialog before logging out
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        backgroundColor: Colors.black54,
                        title: const Row(
                          children: [
                            Icon(Icons.logout, color: Colors.white),
                            SizedBox(width: 8.0),
                            Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        content: const Text(
                          'Are you sure you want to log out?',
                          style: TextStyle(color: Colors.white),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Remove session data on logout
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove('userId');
                              await prefs.remove('role');

                              // Navigate to LoginPage
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                              );
                            },
                            child: const Text(
                              'Confirm',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherProfilePage(docId: widget.docId),
              ),
            );
          },
          child: CircleAvatar(
            radius: 30.0,
            backgroundColor: Colors.grey[100],
            backgroundImage: profileImage != null && profileImage!.isNotEmpty
                ? NetworkImage(profileImage!)
                : null,
            child: (profileImage == null || profileImage!.isEmpty)
                ? const Icon(
                    Icons.person_2_rounded,
                    size: 24,
                    color: Colors.black,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 16.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                  fontWeight: FontWeight.w300),
            ),
            Text(
              name != null && name!.length > 25
                  ? '${name!.substring(0, 15)}...'
                  : (name ?? 'N/A'),
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          children: [
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 2,
              child: _buildMainMenuItem(Icons.table_chart, 'Timetable', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TeacherTimetablePage(teacherId: widget.docId),
                  ),
                );
              }),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 2,
              child: _buildMainMenuItem(Icons.star, 'Child\'s Milestone', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TeacherMenuMilestonePage(teacherId: widget.docId),
                  ),
                );
              }),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 2,
              child: _buildMainMenuItem(Icons.people, 'Attendance', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AttendanceTeacherPage(docId: widget.docId),
                  ),
                );
              }),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 2,
              child: _buildMainMenuItem(Icons.camera, 'Daily Snap', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DailySnapOptionPage(teacherId: widget.docId),
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainMenuItem(IconData icon, String label, VoidCallback onTap) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize =
        screenWidth < 360 ? 28.0 : (screenWidth < 480 ? 32.0 : 35.0);
    double fontSize =
        screenWidth < 360 ? 11.0 : (screenWidth < 480 ? 14.0 : 16.0);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: iconSize, color: Colors.black),
              ),
              const SizedBox(
                  height: 8.0), // Adds space between the icon and text
              Text(
                label,
                style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center, // Aligns the text in the center
              ),
            ],
          ),
        ),
      ),
    );
  }
}
