import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../user/notifications/notificationDetails.dart';
import 'notification.dart';

class SentNotificationsPage extends StatefulWidget {
  final String adminDocId;

  const SentNotificationsPage({Key? key, required this.adminDocId})
      : super(key: key);

  @override
  _SentNotificationsPageState createState() => _SentNotificationsPageState();
}

class _SentNotificationsPageState extends State<SentNotificationsPage> {
  Future<List<QueryDocumentSnapshot>> fetchNotifications() async {
    // Query to fetch only notifications sent by the admin
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('senderId', isEqualTo: widget.adminDocId)
        .get();

    // Sort notifications by timestamp in descending order
    List<QueryDocumentSnapshot> sortedNotifications = querySnapshot.docs;
    sortedNotifications.sort((a, b) {
      Timestamp timestampA = a['timestamp'];
      Timestamp timestampB = b['timestamp'];
      return timestampB.compareTo(timestampA); // Descending order
    });

    return sortedNotifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Sent Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No notifications sent yet."));
          }

          // Display list of sent notifications
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final notification = snapshot.data![index];
              final title = notification['title'] ?? 'No Title';
              final message = notification['message'] ?? 'No Message';
              final timestamp = notification['timestamp'] as Timestamp?;
              final recipients = notification['recipients'] ?? [];

              // Format recipients' names as a comma-separated string
              final recipientNames = recipients
                  .map((recipient) => recipient['name'] ?? 'Unknown')
                  .join(', ');

              return GestureDetector(
                onTap: () {
                  // Navigate to NotificationDetailPage when the card is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationDetailPage(
                        notification:
                            notification.data() as Map<String, dynamic>,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.white,
                  child: ListTile(
                    isThreeLine: true,
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          message.length > 50
                              ? '${message.substring(0, 50)}...'
                              : message,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sent To: $recipientNames',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sent on: ${timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch).toLocal().toString() : 'Unknown'}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Navigate to the NotificationPage to send a new notification
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NotificationPage(adminDocId: widget.adminDocId),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          tooltip: 'Send New Notification',
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
