// ignore_for_file: file_names, use_super_parameters, avoid_print, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../user/notifications/notificationDetails.dart';

class TeacherNotificationPage extends StatefulWidget {
  final String teacherDocId;

  const TeacherNotificationPage({Key? key, required this.teacherDocId})
      : super(key: key);

  @override
  State<TeacherNotificationPage> createState() =>
      _TeacherNotificationPageState();
}

class _TeacherNotificationPageState extends State<TeacherNotificationPage> {
  late Future<List<Map<String, dynamic>>> notifications;

  @override
  void initState() {
    super.initState();
    print('Teacher Doc ID: ${widget.teacherDocId}'); // Verify teacherDocId
    notifications = fetchNotifications();
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      // Query the notifications collection without any filtering
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('notifications').get();

      // Log the snapshot
      print('Snapshot received: ${snapshot.docs.length} document(s) found.');

      List<Map<String, dynamic>> notificationList = [];
      // Filter notifications based on the teacher's ID in the recipients array
      for (var doc in snapshot.docs) {
        List<dynamic> recipients = doc['recipients'];
        for (var recipient in recipients) {
          if (recipient['id'] == widget.teacherDocId) {
            print(
                'Displaying notification: ${doc['title']} - ${doc['message']}');
            notificationList.add(doc.data() as Map<String, dynamic>);
            break; // No need to check further recipients if we found the teacher
          }
        }
      }

      // Sort the notification list based on timestamp (descending order)
      notificationList.sort((a, b) {
        Timestamp timestampA = a['timestamp'];
        Timestamp timestampB = b['timestamp'];
        // Compare timestamps in descending order (latest first)
        return timestampB.seconds.compareTo(timestampA.seconds);
      });

      return notificationList;
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: notifications,
        builder: (context, snapshot) {
          // Check if the snapshot is still waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Loading notifications...');
            return const Center(child: CircularProgressIndicator());
          }

          // Check if there is an error
          if (snapshot.hasError) {
            print('Error occurred: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Check if there is no data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print(
                'No notifications found for teacherDocId: ${widget.teacherDocId}');
            return const Center(child: Text('No notifications found.'));
          }

          // List the notifications
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var notification = snapshot.data![index];

              String title = notification['title'] ?? 'No Title';
              String message = notification['message'] ?? 'No Message';
              Timestamp timestamp = notification['timestamp'];
              String timestampStr =
                  DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000)
                      .toString();

              // Truncate the message to display a preview
              String truncatedMessage = message.length > 50
                  ? message.substring(0, 50) + '...'
                  : message;

              // Log each notification being displayed
              print('Displaying notification: $title - $message');

              return GestureDetector(
                  onTap: () {
                    // Debugging message to check if onTap is triggered
                    print('Card tapped!'); // Ensure this message is printed
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationDetailPage(
                          notification: notification,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      side: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            truncatedMessage,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sent on: $timestampStr',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
            },
          );
        },
      ),
    );
  }
}
