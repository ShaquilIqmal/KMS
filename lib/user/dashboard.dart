// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, avoid_print, unused_element, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kms2/user/dailySnap.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';
import '../service/database_service.dart';
import 'attendance/checkAttendance.dart';
import 'childMilestone.dart';
import 'childTimetable/childTimetable.dart';
import 'notifications/userNotification.dart';
import 'payment/paymentOverview.dart';
import 'registerchild/registerchildA.dart';
import 'userProfile/userProfile.dart';

class DashboardPage extends StatefulWidget {
  final String docId;

  const DashboardPage({super.key, required this.docId});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String name = '';
  String? profileImageUrl;
  bool isLoading = true;
  List<String> childrenNames = [];
  List<String> childrenIds = [];
  int? selectedCardIndex;
  String? selectedChildId;

  @override
  void initState() {
    super.initState();

    fetchUserNameAndChildren();
    checkNotificationCollection();
  }

  void checkNotificationCollection() {}

  Future<void> fetchUserNameAndChildren() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });
    print('Fetching user name and children...');
    try {
      String? fetchedName = await DatabaseService.fetchUserData(widget.docId);
      print('Fetched name: $fetchedName');

      profileImageUrl =
          await DatabaseService().fetchUserProfileImage(widget.docId);
      print('Fetched profile image URL: $profileImageUrl');

      List<String> fetchedChildrenIds =
          await DatabaseService().getChildrenIds(widget.docId);
      print('Fetched children IDs: $fetchedChildrenIds');

      List<String> fetchedChildrenNames = [];
      if (fetchedChildrenIds.isNotEmpty) {
        fetchedChildrenNames = await Future.wait(
          fetchedChildrenIds
              .map((id) => DatabaseService().getChildNameById(id))
              .toList(),
        );
      } else {
        print("No child IDs found.");
      }

      setState(() {
        name = fetchedName ?? 'N/A';
        childrenNames = fetchedChildrenNames;
        childrenIds = fetchedChildrenIds;
        selectedCardIndex = childrenNames.isNotEmpty ? 0 : null;
        selectedChildId =
            selectedCardIndex != null ? childrenIds[selectedCardIndex!] : null;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Close dialog without logging out
              },
              child: const Text('Cancel'),
            ),
            // Confirm button
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Close dialog and confirm logout
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[100], // White background for the main content
      body: RefreshIndicator(
        onRefresh: fetchUserNameAndChildren,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false, // Remove the back button
                    backgroundColor: Colors.white,
                    expandedHeight: 100.0, // Height when fully expanded
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                children: [
                                  _buildProfileSection(),
                                  const Spacer(),
                                  // Notification button
                                  IconButton(
                                    icon: const Icon(Icons.notifications),
                                    color: Colors.black,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UserNotificationPage(
                                                  userDocId: widget.docId),
                                        ),
                                      );
                                    },
                                  ),
                                  // Logout button
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
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            backgroundColor: Colors.black54,
                                            title: const Row(
                                              children: [
                                                Icon(Icons.logout,
                                                    color: Colors.white),
                                                SizedBox(width: 8.0),
                                                Text(
                                                  'Logout',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                            content: const Text(
                                              'Are you sure you want to log out?',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: const Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                      color: Colors.white70),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  // Remove session data on logout
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  await prefs.remove('userId');
                                                  await prefs.remove('role');

                                                  // Navigate to LoginPage
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const LoginPage()),
                                                  );
                                                },
                                                child: const Text(
                                                  'Confirm',
                                                  style: TextStyle(
                                                      color: Colors.red),
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.05),
                              _buildDueAmountSection(),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.05),
                              _buildConnectedStudentsSection(context),
                            ],
                          ),
                        ),
                        const Spacer(),
                        _buildMainMenuSection(),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Widget _buildProfileSection() {
    String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    String displayName =
        name.length > 15 ? '${name.substring(0, 15)}...' : name;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(docId: widget.docId),
              ),
            );
          },
          child: CircleAvatar(
            radius: 30.0,
            backgroundColor: Colors.black,
            backgroundImage:
                (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                    ? NetworkImage(profileImageUrl!)
                    : null,
            child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                ? Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
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
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              displayName,
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

  Widget _buildDueAmountSection() {
    return FutureBuilder<double>(
      future: selectedChildId != null
          ? DatabaseService().fetchTotalDueAmount(selectedChildId!)
          : Future.value(0.0),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching due amount'));
        } else {
          double totalDueAmount = snapshot.data ?? 0.0;
          Color amountColor = totalDueAmount == 0.0 ? Colors.black : Colors.red;

          return GestureDetector(
            onTap: () {
              if (selectedChildId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentOverviewPage(
                      docId: widget.docId,
                      childId: selectedChildId!,
                    ),
                  ),
                );
              } else {
                print('No child selected for Payment Overview');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 6,
                    offset: const Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RM ${totalDueAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: amountColor, // Dynamically change text color
                        ),
                      ),
                      const Text(
                        'Due Amount',
                        style: TextStyle(fontSize: 16.0, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward,
                      color: amountColor), // Match icon color
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildConnectedStudentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Children Registered',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...childrenNames.asMap().entries.map((entry) {
                int index = entry.key;
                String name = entry.value;
                return _buildStudentCardAndAddButton(
                    context, name, index, false);
              }).toList(),
              _buildStudentCardAndAddButton(
                  context, '', childrenNames.length, true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCardAndAddButton(
      BuildContext context, String childName, int index, bool isAddButton) {
    bool isSelected = selectedCardIndex == index;
    String initial = isAddButton ? '+' : childName[0].toUpperCase();

    // Limit the displayed child name to 10 characters
    String truncatedChildName =
        childName.length > 10 ? '${childName.substring(0, 10)}...' : childName;

    Future<String?>? childProfileImageFuture;
    if (!isAddButton) {
      String childId = childrenIds[index];
      childProfileImageFuture = DatabaseService().getChildProfileImage(childId);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          if (isAddButton) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterChildPage(docId: widget.docId),
              ),
            );
          } else {
            setState(() {
              selectedCardIndex = isSelected ? null : index;
              selectedChildId = isSelected ? null : childrenIds[index];
            });
          }
        },
        child: FutureBuilder<String?>(
          future: childProfileImageFuture,
          builder: (context, snapshot) {
            Widget avatarContent;

            if (isAddButton) {
              avatarContent = Text(
                initial,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              avatarContent = const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              );
            } else if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.isNotEmpty) {
              avatarContent = CircleAvatar(
                radius: 30.0,
                backgroundImage: NetworkImage(snapshot.data!),
              );
            } else {
              avatarContent = Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: isAddButton
                        ? Colors.white
                        : (isSelected ? Colors.black : Colors.grey[200]),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? Colors.black54.withOpacity(0.3)
                            : Colors.black12,
                        blurRadius: 8.0,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Center(child: avatarContent),
                ),
                const SizedBox(height: 4.0),
                if (!isAddButton)
                  Text(
                    truncatedChildName, // Use the truncated name here
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.black54,
                      fontSize: isSelected ? 15.0 : 13.0,
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                if (isAddButton)
                  const Text(
                    '',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainMenuSection() {
    String selectedChildName =
        selectedCardIndex != null ? childrenNames[selectedCardIndex!] : '';
    String truncatedChildName = selectedChildName.length > 10
        ? '${selectedChildName.substring(0, 10)}...'
        : selectedChildName;

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              16.0, 0, 16.0, 40.0), // Add bottom padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Adjusted Row for the "Main Menu" text
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 8.0), // Add padding to the left
                      child: Text(
                        'Main Menu (Hello) - ',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Black text for contrast
                        ),
                      ),
                    ),
                    Text(
                      truncatedChildName,
                      style: const TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54, // Grey text for contrast
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(
                  height: 16.0), // Space between the text and the grid

              // StaggeredGrid with no padding pushing it down
              StaggeredGrid.count(
                crossAxisCount: 2, // Number of columns
                mainAxisSpacing: 15.0, // Spacing between rows
                crossAxisSpacing: 15.0, // Spacing between columns
                children: [
                  StaggeredGridTile.fit(
                    crossAxisCellCount: 2,
                    child: _buildMainMenuItem(
                      Icons.bar_chart,
                      'Attendance',
                      () async {
                        String selectedYear = '';
                        if (selectedChildId != null) {
                          selectedYear = await DatabaseService()
                                  .getChildYearID(selectedChildId!) ??
                              '';
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckAttendancePage(
                              childId: selectedChildId!,
                              selectedYear: selectedYear,
                            ),
                          ),
                        );
                      },
                      'assets/dinoooo.jpg',
                      [Colors.pink, Colors.redAccent],
                    ),
                  ),
                  StaggeredGridTile.fit(
                    crossAxisCellCount: 1,
                    child: _buildMainMenuItem(
                      Icons.calendar_today,
                      'Timetable',
                      () async {
                        String selectedYear = '';
                        if (selectedChildId != null) {
                          selectedYear = await DatabaseService()
                                  .getChildYearID(selectedChildId!) ??
                              '';
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChildTimetablePage(
                              childId: selectedChildId!,
                              selectedYear: selectedYear,
                            ),
                          ),
                        );
                      },
                      'assets/dino 2.png',
                      [Colors.blue, Colors.lightBlueAccent],
                    ),
                  ),
                  StaggeredGridTile.fit(
                    crossAxisCellCount: 1,
                    child: _buildMainMenuItem(
                      Icons.star,
                      'Milestone',
                      () {
                        if (selectedChildId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MilestonePage(childId: selectedChildId!),
                            ),
                          );
                        }
                      },
                      'assets/dino 3.png',
                      [Colors.green, Colors.teal],
                    ),
                  ),
                  StaggeredGridTile.fit(
                    crossAxisCellCount: 1,
                    child: _buildMainMenuItem(
                      Icons.book,
                      'Daily Snap',
                      () {
                        if (selectedChildId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DailySnapPage(childId: selectedChildId!),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please select a child first.')),
                          );
                        }
                      },
                      'assets/dino 4.png',
                      [Colors.orange, Colors.deepOrangeAccent],
                    ),
                  ),
                  StaggeredGridTile.fit(
                    crossAxisCellCount: 1,
                    child: _buildMainMenuItem(
                      Icons.attach_money,
                      'Fees',
                      () {
                        if (selectedChildId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentOverviewPage(
                                docId: widget.docId,
                                childId: selectedChildId!,
                              ),
                            ),
                          );
                        }
                      },
                      'assets/dino 5.png',
                      [Colors.purple, Colors.deepPurpleAccent],
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

  Widget _buildMainMenuItem(IconData icon, String title, VoidCallback onTap,
      String imagePath, List<Color> gradientColors) {
    double screenWidth = MediaQuery.of(context).size.width;

    double iconSize = screenWidth < 360
        ? 28.0
        : (screenWidth < 480 ? 32.0 : 35.0); // Smaller for smaller screens
    double fontSize =
        screenWidth < 360 ? 11.0 : (screenWidth < 480 ? 14.0 : 16.0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ), // Gradient background
          image: DecorationImage(
            image: AssetImage(imagePath), // Path to your background image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.grey.withOpacity(0.3),
              BlendMode.dstATop,
            ), // Apply the gradient color filter
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: Colors.white, // White icon for better contrast
            ),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: TextStyle(
                color: Colors.white, // White text for better contrast
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
