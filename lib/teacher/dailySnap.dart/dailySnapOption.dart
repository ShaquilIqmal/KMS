// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:kms2/teacher/dailySnap.dart/dailySnapByYear.dart';

class DailySnapOptionPage extends StatelessWidget {
  final String teacherId;

  const DailySnapOptionPage({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    final List<String> years = ['Year 4', 'Year 5', 'Year 6'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Daily Snap',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Custom app bar color
        elevation: 0, // Flat app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: years.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                title: Text(
                  years[index],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DailySnapByYearPage(
                        teacherId: teacherId,
                        yearId: years[index],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
