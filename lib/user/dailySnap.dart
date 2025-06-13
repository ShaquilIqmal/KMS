// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailySnapPage extends StatelessWidget {
  final String childId;

  const DailySnapPage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display today's date
            Text(
              'Date: $todayDate',
              style: const TextStyle(
                fontSize: 18,
                //fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // Fetch and display the daily snap
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('dailySnap4Children')
                  .doc(childId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching data.'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('No daily snap available.'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final dailySnapUrl = data['dailySnap'] ?? '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display daily snap label
                    const Text(
                      'Daily Snap:',
                      style: TextStyle(
                        fontSize: 18,
                        //fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (dailySnapUrl.isNotEmpty)
                      // Display the image using its actual size
                      Center(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                          child: Image.network(
                            dailySnapUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    else
                      const Text('No image available.'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Daily Snap',
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
