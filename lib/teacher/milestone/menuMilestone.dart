// ignore_for_file: file_names, use_super_parameters

import 'package:flutter/material.dart';

import 'childListMilestone.dart';

class TeacherMenuMilestonePage extends StatefulWidget {
  final String teacherId; // Add this parameter to the constructor

  const TeacherMenuMilestonePage({Key? key, required this.teacherId})
      : super(key: key);

  @override
  State<TeacherMenuMilestonePage> createState() => _SelectYearPageState();
}

class _SelectYearPageState extends State<TeacherMenuMilestonePage> {
  final List<String> years = ['Year 4', 'Year 5', 'Year 6'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Milestones',
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
                      builder: (context) => ChildListPage(
                        year: years[index],
                        teacherId: widget.teacherId,
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
