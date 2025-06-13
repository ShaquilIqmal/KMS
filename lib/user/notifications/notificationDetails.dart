// ignore_for_file: file_names, use_super_parameters

import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure this import is present
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationDetailPage extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailPage({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = notification['title'] ?? 'No Title';
    String message = notification['message'] ?? 'No Message';
    Timestamp timestamp = notification['timestamp'];
    String timestampStr = DateFormat('EEEE, MMM d, yyyy – hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sent on: $timestampStr',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
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
}
