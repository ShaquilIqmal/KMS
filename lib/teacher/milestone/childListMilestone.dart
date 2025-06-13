// ignore_for_file: file_names, use_super_parameters

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'updateMilestone.dart';

class ChildListPage extends StatelessWidget {
  final String year;
  final String teacherId;

  const ChildListPage({
    Key? key,
    required this.year,
    required this.teacherId,
  }) : super(key: key);

  // Fetch children based on the selected year
  Future<List<QueryDocumentSnapshot>> fetchChildren() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('child')
        .where('SectionA.yearID', isEqualTo: year)
        .get();
    return snapshot.docs;
  }

  Future<Map<String, dynamic>> fetchChildData(String childId) async {
    String? childName = await fetchChildName(childId);
    String profileImage = await fetchChildProfileImage(childId);
    return {
      'nameC': childName ?? 'Unknown',
      'profileImage': profileImage,
    };
  }

  Future<String?> fetchChildName(String childId) async {
    DocumentSnapshot childDoc =
        await FirebaseFirestore.instance.collection('child').doc(childId).get();
    return childDoc.exists ? childDoc['SectionA']['nameC'] as String : null;
  }

  Future<String> fetchChildProfileImage(String childId) async {
    DocumentSnapshot childDoc =
        await FirebaseFirestore.instance.collection('child').doc(childId).get();
    if (childDoc.exists) {
      final data = childDoc.data() as Map<String, dynamic>;
      if (data.containsKey('profileImage')) {
        return data['profileImage'] as String;
      }
    }
    return ''; // Return an empty string if no image exists
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Children in $year',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: fetchChildren(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No children found.'));
            }

            final children = snapshot.data!;
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: Future.wait(children.map((child) async {
                final childId = child.id;
                return await fetchChildData(childId);
              }).toList()),
              builder: (context, childDataSnapshot) {
                if (childDataSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!childDataSnapshot.hasData ||
                    childDataSnapshot.data!.isEmpty) {
                  return const Center(child: Text('No children found.'));
                }

                final childDataList = childDataSnapshot.data!;
                return ListView.builder(
                  itemCount: childDataList.length,
                  itemBuilder: (context, index) {
                    final childData = childDataList[index];
                    final String childName = childData['nameC'] ?? 'No Name';
                    final String childId = children[index].id;
                    final String profileImage = childData['profileImage'] ?? '';

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
                          backgroundColor: Colors.grey,
                          radius: 30,
                          child: profileImage.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    profileImage,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.white,
                                ),
                        ),
                        title: Text(
                          childName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.black),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateMilestonePage(
                                childId: childId,
                                childName: childName,
                              ),
                            ),
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
    );
  }
}
