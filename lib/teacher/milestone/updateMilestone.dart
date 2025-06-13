// ignore_for_file: file_names, use_super_parameters, avoid_print, use_build_context_synchronously, unnecessary_to_list_in_spreads, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kms2/service/database_service.dart';

class UpdateMilestonePage extends StatefulWidget {
  final String childId;
  final String childName;

  const UpdateMilestonePage(
      {Key? key, required this.childId, required this.childName})
      : super(key: key);

  @override
  State<UpdateMilestonePage> createState() => _UpdateMilestonePageState();
}

class _UpdateMilestonePageState extends State<UpdateMilestonePage> {
  List<Map<String, dynamic>> milestones = [];
  bool isLoading = true;

  final DatabaseService _databaseService = DatabaseService();
  @override
  void initState() {
    super.initState();
    fetchMilestones();
  }

  // Fetch milestones from the 'child' document and the corresponding details from the 'milestones' collection
  Future<void> fetchMilestones() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('child')
          .doc(widget.childId)
          .get();

      final data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> milestoneEntries = data['milestones'] ?? [];
      List<Map<String, dynamic>> fetchedMilestones = [];

      for (var milestoneData in milestoneEntries) {
        if (milestoneData is Map<String, dynamic>) {
          String milestoneId = milestoneData['milestoneId'] ?? '';

          DocumentSnapshot milestoneDoc = await FirebaseFirestore.instance
              .collection('milestones')
              .doc(milestoneId)
              .get();

          if (milestoneDoc.exists) {
            var milestoneDocData = milestoneDoc.data() as Map<String, dynamic>;

            fetchedMilestones.add({
              'milestoneId': milestoneId,
              'title': milestoneDocData['title'],
              'description': milestoneDocData['description'],
              'criteria': milestoneDocData['criteria'],
              'year': milestoneDocData['year'],
              'milestoneLevel': milestoneDocData['milestoneLevel'],
              'category': milestoneDocData['category'],
              'achieved': milestoneData['achieved'] ?? false,
              'lastUpdated': milestoneData['lastUpdated'],
              'targetAchievedDate':
                  milestoneDocData['targetAchievedDate'], // Add this line
              'comment': milestoneData['comment'] ??
                  milestoneDocData['comment'] ??
                  'null', // Ensure comment is fetched
            });
            print(
                'Fetched milestone: $milestoneId, Comment: ${milestoneData['comment']}');
            ;
          }
        }
      }

      setState(() {
        milestones = fetchedMilestones;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching milestones: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

// Update the status of a milestone
  Future<void> updateMilestoneStatus(int index, bool achieved) async {
    // Update the achieved status
    milestones[index]['achieved'] = achieved;
    milestones[index]['lastUpdated'] =
        Timestamp.now(); // Update last updated timestamp

    // Set comment to null if achieved is false
    if (!achieved) {
      milestones[index]['comment'] = null; // Set comment to null
    }

    try {
      await FirebaseFirestore.instance
          .collection('child')
          .doc(widget.childId)
          .update({'milestones': milestones});

      // If milestone is achieved, find the user document ID and send notification
      if (achieved) {
        await findUserIdByChildId(
          widget.childId,
          milestones[index]['title'],
          widget.childName, // Pass childName here
        );
      }

      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Milestone updated')),
      );
    } catch (e) {
      print('Error updating milestone: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update milestone')),
      );
    }
  }

// Function to find user document ID by childId and send notification
  Future<void> findUserIdByChildId(
      String childId, String milestoneTitle, String childName) async {
    try {
      // Query the 'users' collection
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('childIds', arrayContains: childId)
          .get();

      // Check if any user documents match the childId
      if (userSnapshot.docs.isNotEmpty) {
        for (var doc in userSnapshot.docs) {
          String userId = doc.id; // Get the user document ID
          print('Found user document ID: $userId');

          // Send notification to the user
          await _databaseService.sendNotification(
            adminDocId: 'GENERATED', // Replace with actual admin ID if needed
            userIds: [userId],
            title: '$childName has Achieved His Milestone!',
            message:
                'Congratulations! Milestone "$milestoneTitle" has been achieved for $childName. Keep it up!',
          );

          print('Notification sent to user: $userId');
        }
      } else {
        print('No user found for childId: $childId');
      }
    } catch (e) {
      print('Error finding user ID: $e');
    }
  }

  // Format the 'targetAchievedDate' timestamp
  String formatTargetAchievedDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A'; // Return 'N/A' if no date is set
    DateTime date = timestamp.toDate();
    return DateFormat('dd-MM-yyyy').format(date); // Format as DD-MM-YYYY
  }

  // Format the 'lastUpdated' timestamp
  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Not updated';
    DateTime date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  void showMilestoneDetails(Map<String, dynamic> milestone) {
    TextEditingController commentController =
        TextEditingController(text: milestone['comment']);

    // Store the current achieved status
    bool isAchieved = milestone['achieved'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          title: Text(
            milestone['title'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Description: ',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: milestone['description'],
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Last Updated: ',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: formatDate(milestone['lastUpdated']),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: TextField(
                  controller: commentController,
                  style: const TextStyle(color: Colors.white),
                  enabled: isAchieved, // Disable if not achieved
                  decoration: const InputDecoration(
                    labelText: 'Comment',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isAchieved // Disable if not achieved
                  ? () {
                      // Save the edited comment
                      updateComment(
                          milestone['milestoneId'], commentController.text);
                      Navigator.of(context).pop();
                    }
                  : null, // Disable the button
              style: TextButton.styleFrom(
                primary: isAchieved ? Colors.white : Colors.grey, // Text color
              ),
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                primary: Colors.white, // Text color for Close button
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Group milestones by category
  Map<String, List<Map<String, dynamic>>> groupMilestonesByCategory() {
    Map<String, List<Map<String, dynamic>>> groupedMilestones = {};

    for (var milestone in milestones) {
      String category = milestone['criteria'] ?? 'Uncategorized';
      if (!groupedMilestones.containsKey(category)) {
        groupedMilestones[category] = [];
      }
      groupedMilestones[category]!.add(milestone);
    }

    return groupedMilestones;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Milestones for ${widget.childName}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Custom app bar color
        elevation: 0, // Flat app bar
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: groupMilestonesByCategory().entries.map((entry) {
                  String category = entry.key;
                  List<Map<String, dynamic>> milestonesInCategory = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Custom text color
                          ),
                        ),
                      ),
                      ...milestonesInCategory.map((milestone) {
                        final lastUpdated = milestone['lastUpdated'] != null
                            ? DateFormat('yyyy-MM-dd HH:mm').format(
                                (milestone['lastUpdated'] as Timestamp)
                                    .toDate(),
                              )
                            : 'Not updated';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // Rounded corners
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(
                              milestone['milestoneId'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Achieved: ${milestone['achieved'] ? "Yes" : "No"}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color:
                                        Colors.black54, // Subtitle text color
                                  ),
                                ),
                                Text(
                                  'Last Updated: ${formatDate(milestone['lastUpdated'])}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color:
                                        Colors.black54, // Subtitle text color
                                  ),
                                ),
                                Text(
                                  'Target Achieved Date: ${formatTargetAchievedDate(milestone['targetAchievedDate'])}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: (milestone['targetAchievedDate'] !=
                                                null &&
                                            (milestone['targetAchievedDate']
                                                    as Timestamp)
                                                .toDate()
                                                .isAfter(DateTime.now()))
                                        ? Colors
                                            .green // Green if the date is in the future
                                        : Colors
                                            .orange, // Orange if the date is today or in the past
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Button to view milestone details
                                IconButton(
                                  icon: const Icon(Icons.info_outline,
                                      color: Colors.grey),
                                  onPressed: () {
                                    showMilestoneDetails(milestone);
                                  },
                                ),
                                // Switch to update milestone status
                                Switch(
                                  value: milestone['achieved'],
                                  onChanged: (value) {
                                    updateMilestoneStatus(
                                      milestones.indexOf(milestone),
                                      value,
                                    );
                                  },
                                  activeColor: Colors.teal,
                                  inactiveThumbColor: Colors.grey,
                                  inactiveTrackColor: Colors.grey[300],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Future<void> updateComment(String milestoneId, String newComment) async {
    // Find the index of the milestone in the local list
    int index = milestones.indexWhere((m) => m['milestoneId'] == milestoneId);
    if (index == -1) return; // If milestone not found, exit

    // Update the local milestone comment
    milestones[index]['comment'] = newComment;
    milestones[index]['lastUpdated'] =
        Timestamp.now(); // Update last updated timestamp

    try {
      // Update the milestones array in the 'child' document
      await FirebaseFirestore.instance
          .collection('child')
          .doc(widget.childId)
          .update({'milestones': milestones});

      setState(() {
        // Optionally, you can trigger a state refresh
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment updated')),
      );
    } catch (e) {
      print('Error updating comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update comment')),
      );
    }
  }
}
