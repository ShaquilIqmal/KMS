import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';
import '../service/database_service.dart';
import 'approval/adminApproval.dart';
import 'attendance/attendanceOption.dart';
import 'barChart.dart';
import 'milestone/menuMilestone.dart';
import 'notification/sentNotification.dart';
import 'payment/paymentOption.dart';
import 'timetable/timetablePage.dart';
import 'viewTeachers/viewTeacher.dart';
import 'viewUsers/viewUser.dart';

class AdminDashboardPage extends StatefulWidget {
  final String docId;

  // ignore: use_super_parameters
  const AdminDashboardPage({Key? key, required this.docId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String name = '';
  int usersCount = 0; // State variable for user count
  int childrenCount = 0;
  int pendingApprovalsCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdminData();
    _fetchUsersCount();
    _fetchChildrenCount();
    _fetchPendingApprovalsCount();
  }

  Future<void> fetchAdminData() async {
    String? fetchedName = await DatabaseService.fetchAdminData(widget.docId);
    setState(() {
      name = fetchedName ?? 'N/A';
      isLoading = false;
    });
  }

  Future<void> _fetchUsersCount() async {
    DatabaseService dbService = DatabaseService(); // Create an instance
    int count =
        await dbService.getUsersCount(); // Call the method on the instance
    setState(() {
      usersCount = count; // Update the state with the user count
    });
  }

  Future<void> _fetchChildrenCount() async {
    DatabaseService dbService = DatabaseService(); // Create an instance
    int count1 =
        await dbService.getChildrenCount(); // Call the method on the instance
    setState(() {
      childrenCount = count1; // Update the state with the children count
    });
  }

  Future<void> _fetchPendingApprovalsCount() async {
    DatabaseService dbService = DatabaseService(); // Create an instance
    int count = await dbService
        .getPendingApprovalsCount(); // Call the method on the instance
    setState(() {
      pendingApprovalsCount =
          count; // Update the state with the pending approvals count
    });
  }

  Future<List<double>> _fetchMonthlyIncomeData() async {
    DatabaseService dbService = DatabaseService(); // Create an instance

    try {
      // Call the instance method without parameters
      List<double> monthlyIncome = await dbService.fetchMonthlyIncomeData();
      return monthlyIncome; // Return the fetched data
    } catch (e) {
      return List<double>.filled(12, 0.0); // Return default if error occurs
    }
  }

  // Function to handle the pull-to-refresh action
  Future<void> _refreshData() async {
    await fetchAdminData();
    await _fetchUsersCount();
    await _fetchChildrenCount();
    await _fetchPendingApprovalsCount();
    // Optionally, you can also refetch the monthly income data if needed
    await _fetchMonthlyIncomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomHeader(),
          const SizedBox(height: 16.0),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData, // Trigger the refresh action
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildMonthlyIncomeStatistics(),
                      const SizedBox(height: 16.0),
                      _buildDashboardMetricsSection(),
                      const SizedBox(height: 20.0),
                      _buildMainMenuSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
                          SentNotificationsPage(adminDocId: widget.docId),
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 30.0,
          backgroundColor: Colors.grey[200], // Optional background color
          child: Icon(
            Icons.admin_panel_settings, // Admin icon
            size: 30.0, // Icon size
            color: Colors.grey[700], // Icon color
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
              name,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16.0),
      ],
    );
  }

  Widget _buildDashboardMetricsSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6.0,
            offset: const Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: _buildMetricCardChildren(
              'Pending Approvals',
              pendingApprovalsCount.toString(),
              Icons.approval,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: _buildMetricCardBottom(
                  'Total Users',
                  usersCount.toString(),
                  Icons.people,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: _buildMetricCardBottom(
                  'Total Children',
                  childrenCount.toString(),
                  Icons.child_care,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCardChildren(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 30.0, color: Colors.grey[800]),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCardBottom(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30.0, color: Colors.grey[800]),
              const SizedBox(width: 8.0),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Bar chart integration for Monthly Income Statistics
  Widget _buildMonthlyIncomeStatistics() {
    return FutureBuilder<List<double>>(
      future: _fetchMonthlyIncomeData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 250.0,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: 250.0,
            child: Center(child: Text("Error: ${snapshot.error}")),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 250.0,
            child: Center(child: Text("No income data available.")),
          );
        } else {
          List<double> incomeData = snapshot.data!;
          return Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Monthly Income Statistics',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333)),
                  ),
                ),
                const SizedBox(height: 12.0),
                SizedBox(
                  height: 250.0,
                  child: BarChartSample2(
                    monthlyIncome: incomeData,
                  ), // Pass the fetched data
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildMainMenuSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
                8.0, 0.0, 8.0, 0.0), // Reduced bottom padding
            child: Text(
              'Main Menu',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 8.0), // Reduced margin
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero, // Removed padding around GridView
              children: [
                _buildMainMenuItem(Icons.approval, 'Approval', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AdminApprovalPage(adminDocId: widget.docId)),
                  );
                }),
                _buildMainMenuItem(Icons.people, 'Parents', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ViewUserPage()),
                  );
                }),
                _buildMainMenuItem(Icons.work, 'Teachers', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewTeacherPage()),
                  );
                }),
                _buildMainMenuItem(Icons.attach_money, "User Fees", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FeeOptionPage(adminDocId: widget.docId)),
                  );
                }),
                _buildMainMenuItem(Icons.bar_chart, 'Attendance', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AttendanceOption(),
                    ),
                  );
                }),
                _buildMainMenuItem(Icons.table_chart, 'Timetable', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminTimetablePage(),
                    ),
                  );
                }),
                _buildMainMenuItem(Icons.star, 'Milestone', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MenuMilestone(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenuItem(IconData icon, String label, VoidCallback onTap) {
    // Get the screen width from MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;

    // Scale the icon and text size based on the screen width
    double iconSize = screenWidth < 360
        ? 28.0
        : (screenWidth < 480 ? 32.0 : 35.0); // Smaller for smaller screens
    double fontSize = screenWidth < 360
        ? 11.0
        : (screenWidth < 480 ? 12.0 : 13.0); // Adjust text size accordingly

    return Padding(
      padding: const EdgeInsets.all(8.0), // Adjust padding as needed
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(8.0), // Rounded corners for the tap area
        child: Container(
          padding: const EdgeInsets.all(
              10.0), // Increased padding for better spacing
          decoration: BoxDecoration(
            color: Colors.white, // Clean background
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0)
                    .withOpacity(0.2), // Light shadow for depth
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), // Shadow position
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                      Color(0xFF8A2387),
                      Color(0xFFE94057),
                      Color(0xFFF27121)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Icon(
                  icon,
                  size: iconSize, // Adjust icon size based on screen width
                  color: Colors.white, // The color will be masked by the shader
                ),
              ),
              const SizedBox(height: 9.0), // Increased spacing
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize, // Adjust text size based on screen width
                  color: Colors.black, // Dark color for contrast
                ),
                textAlign: TextAlign.center, // Center text alignment
              ),
            ],
          ),
        ),
      ),
    );
  }
}
