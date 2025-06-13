// ignore_for_file: file_names, use_super_parameters, avoid_print, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kms2/user/notifications/notificationDetails.dart';

class UserNotificationPage extends StatefulWidget {
  final String userDocId;

  const UserNotificationPage({Key? key, required this.userDocId})
      : super(key: key);

  @override
  State<UserNotificationPage> createState() => _UserNotificationPageState();
}

class _UserNotificationPageState extends State<UserNotificationPage> {
  late Future<List<Map<String, dynamic>>> notifications;

  @override
  void initState() {
    super.initState();
    notifications = fetchNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notifications =
        fetchNotifications(); // Refresh notifications when revisited
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      // Fetch notifications from the user's subcollection
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userDocId)
          .collection('notifications')
          .get();

      List<Map<String, dynamic>> notificationList = [];
      for (var doc in snapshot.docs) {
        notificationList.add({
          ...doc.data() as Map<String, dynamic>,
          'notificationId': doc.id, // Include the notification ID
        });
      }

      notificationList.sort((a, b) {
        Timestamp timestampA = a['timestamp'];
        Timestamp timestampB = b['timestamp'];
        return timestampB.seconds.compareTo(timestampA.seconds);
      });

      return notificationList;
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  void markNotificationAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userDocId)
          .collection('notifications')
          .doc(notificationId) // Reference the notification document
          .update({'isRead': true}); // Update isRead status to true
    } catch (e) {
      print('Error updating notification: $e');
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
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var notification = snapshot.data![index];

              String title = notification['title'] ?? 'No Title';
              String message = notification['message'] ?? 'No Message';
              Timestamp timestamp = notification['timestamp'];
              String timestampStr = DateFormat('yyyy-MM-dd – kk:mm').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      timestamp.seconds * 1000));

              // Truncate the message to display a preview
              String truncatedMessage = message.length > 50
                  ? message.substring(0, 50) + '...'
                  : message;

              return GestureDetector(
                  onTap: () {
                    // Mark the notification as read
                    markNotificationAsRead(notification['notificationId']);

                    // Navigate to the notification detail page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationDetailPage(
                          notification: notification,
                        ),
                      ),
                    ).then((_) {
                      // Refresh notifications after returning from detail page
                      setState(() {
                        notifications = fetchNotifications();
                      });
                    });
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sent on: $timestampStr',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              if (notification['isRead'] ==
                                  false) // Check if isRead is false
                                const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 20,
                                ),
                            ],
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
