// ignore_for_file: unnecessary_null_comparison, file_names, use_super_parameters, library_private_types_in_public_api, avoid_print, prefer_const_constructors, unnecessary_to_list_in_spreads

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MilestonePage extends StatefulWidget {
  final String childId;

  const MilestonePage({Key? key, required this.childId}) : super(key: key);

  @override
  _MilestonePageState createState() => _MilestonePageState();
}

class _MilestonePageState extends State<MilestonePage> {
  bool isLoading = true;
  List<Map<String, dynamic>> milestones = [];
  String childName = 'Loading...';
  String profileImage = '';

  @override
  void initState() {
    super.initState();
    fetchMilestones();
    fetchChildData();
  }

  // Fetch milestones for a child
  Future<void> fetchMilestones() async {
    try {
      // Fetch the child document first
      DocumentSnapshot childDoc = await FirebaseFirestore.instance
          .collection('child')
          .doc(widget.childId)
          .get();

      // Check if the child document exists
      if (childDoc.exists) {
        List<dynamic> milestonesArray = childDoc['milestones'] ?? [];

        List<Map<String, dynamic>> milestoneDetails = [];

        for (var milestone in milestonesArray) {
          var milestoneId = milestone['milestoneId'];

          // Fetch milestone details from the milestones collection
          DocumentSnapshot milestoneDoc = await FirebaseFirestore.instance
              .collection('milestones')
              .doc(milestoneId)
              .get();

          if (milestoneDoc.exists) {
            var milestoneData = milestoneDoc.data() as Map<String, dynamic>;

            // Add the comment directly from the child document
            milestoneDetails.add({
              'milestoneId': milestoneId,
              'title': milestoneData['title'],
              'description': milestoneData['description'],
              'criteria': milestoneData['criteria'],
              'milestoneLevel': milestoneData['milestoneLevel'],
              'achieved': milestone['achieved'],
              'lastUpdated': milestone['lastUpdated'],
              'targetAchievedDate': milestoneData['targetAchievedDate'],
              'comment': milestone['comment'] ?? 'No comment',
            });
          }
        }

        setState(() {
          milestones = milestoneDetails;
        });
      }
    } catch (e) {
      print('Error fetching milestones: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch child's name and profile image
  Future<void> fetchChildData() async {
    try {
      DocumentSnapshot childDoc = await FirebaseFirestore.instance
          .collection('child')
          .doc(widget.childId)
          .get();

      if (childDoc.exists) {
        setState(() {
          childName = childDoc['SectionA']['nameC'] ?? 'No Name';
          profileImage = childDoc['profileImage'] ?? ''; // Fetch profile image
        });
      }
    } catch (e) {
      print('Error fetching child data: $e');
    }
  }

  // Format Timestamp to a readable date
  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Not updated';
    DateTime date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Method to get color based on the comparison
  Color getTargetAchievedDateColor(DateTime? targetAchievedDate) {
    if (targetAchievedDate == null) return Colors.grey; // Default color if null
    DateTime currentDate = DateTime.now();
    return currentDate.isBefore(targetAchievedDate)
        ? Colors.green
        : Colors.orange;
  }

  // Show milestone details in a pop-up dialog
  void showMilestoneDetails(Map<String, dynamic> milestone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(milestone['title'] ?? 'No Title'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description: ${milestone['description'] ?? 'No Description'}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Achieved: ',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Icon(
                    milestone['achieved'] == true
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: milestone['achieved'] == true
                        ? Colors.green
                        : Colors.grey,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Last Updated: ${formatDate(milestone['lastUpdated'])}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Target Achieved Date: ${formatDate(milestone['targetAchievedDate'])}',
                style: TextStyle(
                  fontSize: 14,
                  color: getTargetAchievedDateColor(
                    (milestone['targetAchievedDate'] as Timestamp?)?.toDate(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Comment: ${milestone['comment'] ?? 'No comment'}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group milestones by their 'criteria'
    Map<String, List<Map<String, dynamic>>> groupedMilestones = {};

    for (var milestone in milestones) {
      String criteria = milestone['criteria'] ?? 'Other';
      if (!groupedMilestones.containsKey(criteria)) {
        groupedMilestones[criteria] = [];
      }
      groupedMilestones[criteria]!.add(milestone);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Profile Image and Name
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: profileImage.isNotEmpty
                            ? NetworkImage(profileImage)
                            : const AssetImage(
                                    'assets/images/default_avatar.png')
                                as ImageProvider,
                        radius: 30,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        childName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Click the milestone title to see details.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 82, 82, 82),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...groupedMilestones.entries.map((entry) {
                        String criteria = entry.key;
                        List<Map<String, dynamic>> criteriaMilestones =
                            entry.value;

                        // Sort milestones by 'milestoneLevel'
                        criteriaMilestones.sort((a, b) {
                          int levelA =
                              int.tryParse(a['milestoneLevel'] ?? '0') ?? 0;
                          int levelB =
                              int.tryParse(b['milestoneLevel'] ?? '0') ?? 0;
                          return levelA.compareTo(levelB);
                        });

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    criteria,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: List.generate(
                                        criteriaMilestones.length, (index) {
                                      Map<String, dynamic>? milestone =
                                          criteriaMilestones[index];

                                      return Column(
                                        children: [
                                          Icon(
                                            milestone != null &&
                                                    milestone['achieved']
                                                ? Icons.check_circle
                                                : Icons.check_circle_outline,
                                            color: milestone != null &&
                                                    milestone['achieved']
                                                ? Colors.green
                                                : Colors.grey,
                                            size: 30,
                                          ),
                                          if (index <
                                              criteriaMilestones.length - 1)
                                            Container(
                                              width: 2,
                                              height: 30,
                                              color: (milestone != null &&
                                                      milestone['achieved'] &&
                                                      criteriaMilestones[index +
                                                          1]['achieved'])
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                        ],
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          criteriaMilestones.map((milestone) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  showMilestoneDetails(
                                                      milestone);
                                                },
                                                child: Text(
                                                  milestone['title'] ??
                                                      'No Title',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Target Achieved Date: ${formatDate(milestone['targetAchievedDate'])}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      getTargetAchievedDateColor(
                                                    (milestone['targetAchievedDate']
                                                            as Timestamp?)
                                                        ?.toDate(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Milestone',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}
