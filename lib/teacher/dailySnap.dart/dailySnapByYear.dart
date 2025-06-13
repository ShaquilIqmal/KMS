// ignore_for_file: file_names, prefer_const_constructors_in_immutables, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kms2/service/cloudinary_service.dart';
import 'package:kms2/service/database_service.dart';

class DailySnapByYearPage extends StatefulWidget {
  final String teacherId;
  final String yearId;

  DailySnapByYearPage(
      {super.key, required this.teacherId, required this.yearId});

  @override
  _DailySnapByYearPageState createState() => _DailySnapByYearPageState();
}

class _DailySnapByYearPageState extends State<DailySnapByYearPage> {
  final DatabaseService databaseService = DatabaseService();
  final CloudinaryService cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();

  String get currentDate => DateFormat('dd-MM-yyyy').format(DateTime.now());

  Future<void> _captureAndSubmitPhoto(
      BuildContext context, String childId) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1920,
      );

      if (image != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading photo...')),
        );

        final imageUrl = await cloudinaryService.uploadImage(image.path);
        await databaseService.saveDailySnapForChild(
            childId, imageUrl, currentDate);

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo submitted for child ID: $childId')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture or upload photo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Daily Snap - ${widget.yearId}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                currentDate,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: databaseService.getChildrenByYear(widget.yearId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data.'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No children found for this year.'));
                  }

                  final children = snapshot.data!;

                  return ListView.builder(
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      final child = children[index];
                      final childId = child['id'] ?? '';
                      final childName = child['nameC'] ?? 'Unknown';
                      final profileImage = child['profileImage'] ?? '';

                      return FutureBuilder<Map<String, dynamic>?>(
                        future: databaseService.getDailySnapForChild(childId),
                        builder: (context, dailySnapSnapshot) {
                          if (dailySnapSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const ListTile(title: Text('Loading...'));
                          }

                          final dailySnapData = dailySnapSnapshot.data;
                          final hasDailySnap = dailySnapData != null &&
                              dailySnapData['dailySnap'] != null &&
                              dailySnapData['currentDate'] == currentDate;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 2,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[400],
                                radius: 30,
                                backgroundImage: profileImage.isNotEmpty
                                    ? NetworkImage(profileImage)
                                    : null,
                                child: profileImage.isEmpty
                                    ? const Icon(Icons.person,
                                        size: 30, color: Colors.white)
                                    : null,
                              ),
                              title: Text(
                                childName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text('Year: ${widget.yearId}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (hasDailySnap)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Image.network(
                                        dailySnapData['dailySnap'],
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else if (!hasDailySnap &&
                                      currentDate !=
                                          DateFormat('dd-MM-yyyy')
                                              .format(DateTime.now()))
                                    const Icon(Icons.warning,
                                        color: Colors.red, size: 20)
                                  else
                                    Container(),
                                  IconButton(
                                    icon: const Icon(Icons.camera_alt),
                                    onPressed: () => _captureAndSubmitPhoto(
                                        context, childId),
                                  ),
                                ],
                              ),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Tapped on $childName')),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
