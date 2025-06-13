// ignore_for_file: unnecessary_const, avoid_print, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kms2/service/database_service.dart';

class ApprovalDetailPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  final String adminDocId;

  ApprovalDetailPage({
    required this.docId,
    required this.data,
    required this.adminDocId,
  });

  @override
  State<ApprovalDetailPage> createState() => _ApprovalDetailPageState();
}

class _ApprovalDetailPageState extends State<ApprovalDetailPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    print('Data: ${widget.data}');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.white,
                  title: const Text(
                    'Applicant Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  pinned: true,
                  floating: false,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Material(
                        color: Colors.white,
                        child: Row(
                          children: [
                            _buildNavigationButton('Child\'s Info', 0),
                            _buildNavigationButton('Guardian\'s Info', 1),
                            _buildNavigationButton('Medical Info', 2),
                            _buildNavigationButton('Emergency Contact', 3),
                            _buildNavigationButton('Transport Needs', 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: [
                        _buildChildInfoSection(
                            context, widget.data['SectionA']),
                        _buildGuardianInfoSection(
                            context, widget.data['SectionB']),
                        _buildMedicalInfoSection(
                            context, widget.data['SectionC']),
                        _buildEmergencyContactSection(
                            context, widget.data['SectionD']),
                        _buildTransportNeedsSection(
                            context, widget.data['SectionE']),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildApprovalButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(String label, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton(
        onPressed: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            color: _selectedIndex == index ? Colors.black : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildChildInfoSection(
      BuildContext context, Map<String, dynamic> sectionA) {
    return ListView(
      children: [
        _buildSectionHeader('Section A - Child\'s Particulars'),
        _buildDetailRow('Name', sectionA['nameC']),
        _buildDetailRow('Gender', sectionA['genderC']),
        _buildDetailRow('Address', sectionA['addressC']),
        _buildDetailRow('Date of Birth', sectionA['dateOfBirthC']),
        _buildDetailRow('Age', sectionA['yearID']),
        _buildDetailRow('MyKid', sectionA['myKidC']),
        _buildDetailRow('Religion', sectionA['religionC']),
      ],
    );
  }

  Widget _buildGuardianInfoSection(
      BuildContext context, Map<String, dynamic> sectionB) {
    return ListView(
      children: [
        _buildSectionHeader('Section B - Guardian\'s Particulars'),
        _buildDetailRow('Father\'s Name', sectionB['nameF']),
        _buildDetailRow('Father\'s IC', sectionB['icF']),
        _buildDetailRow('Father\'s Income', sectionB['incomeF']),
        _buildDetailRow('Father\'s Address', sectionB['addressF']),
        _buildDetailRow('Father\'s Home Tel', sectionB['homeTelF']),
        _buildDetailRow('Father\'s Handphone', sectionB['handphoneF']),
        _buildDetailRow('Father\'s Email', sectionB['emailF']),
      ],
    );
  }

  Widget _buildMedicalInfoSection(
      BuildContext context, Map<String, dynamic> sectionC) {
    return ListView(
      children: [
        _buildSectionHeader('Section C - Medical Information'),
        _buildDetailRow('Medical Condition', sectionC['medicalCondition']),
        _buildDetailRow('Doctor\'s Tel', sectionC['doctorTel']),
        _buildDetailRow('Clinic/Hospital', sectionC['clinicHospital']),
      ],
    );
  }

  Widget _buildEmergencyContactSection(
      BuildContext context, Map<String, dynamic> sectionD) {
    return ListView(
      children: [
        _buildSectionHeader('Section D - Emergency Contact'),
        _buildDetailRow('Emergency Name', sectionD['nameM']),
        _buildDetailRow('Emergency Tel', sectionD['telM']),
        _buildDetailRow('Relationship', sectionD['relationshipM']),
      ],
    );
  }

  Widget _buildTransportNeedsSection(
      BuildContext context, Map<String, dynamic> sectionE) {
    return ListView(
      children: [
        _buildSectionHeader('Section E - Transportation Needs'),
        _buildDetailRow('Transportation', sectionE['transportation']),
        if (sectionE['transportation'] == 'school') ...[
          _buildDetailRow('Pickup Address', sectionE['pickupAddress']),
          _buildDetailRow('Drop Address', sectionE['dropAddress']),
        ],
      ],
    );
  }

  Widget _buildApprovalButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF8A2387),
                Color(0xFFE94057),
                Color(0xFFF27121)
              ], // Gradient colors for Approve button
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ElevatedButton(
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.black
                        .withOpacity(0.8), // Black transparent background
                    title: const Text(
                      'Confirm Approval',
                      style: TextStyle(
                        color: Colors.white, // White text color
                      ),
                    ),
                    content: const Text(
                      'Are you sure you want to approve this registration?',
                      style: TextStyle(
                        color: Colors.white, // White text color
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Return false
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white, // White text color
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Return true
                        },
                        child: const Text(
                          'Approve',
                          style: TextStyle(
                            color: Colors.green, // White text color
                          ),
                        ),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  );
                },
              );

              if (result == true) {
                await approveRegistration(widget.docId, widget.data);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text(
              'Approve',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFe52d27),
                Color(0xFFb31217)
              ], // Gradient colors for Deny button
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ElevatedButton(
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.black
                        .withOpacity(0.8), // Black transparent background
                    title: const Text(
                      'Confirm Deletion',
                      style: TextStyle(
                        color: Colors.white, // White text color
                      ),
                    ),
                    content: const Text(
                      'Are you sure you want to deny this registration? This action cannot be undone.',
                      style: TextStyle(
                        color: Colors.white, // White text color
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Return false
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white, // White text color
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Return true
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.red, // White text color
                          ),
                        ),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  );
                },
              );

              if (result == true) {
                // Extract userId from data
                String userId = widget.data['userId'];

                // Call denyRegistration with the docId and userId
                await denyRegistration(widget.docId, userId);

                // Send notification about the denial
                notifyUserAboutRegistrationDenied(widget.adminDocId, userId);

                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text(
              'Deny',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _getIconForLabel(label),
            color: Colors.blueGrey[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Child Name':
        return Icons.child_care;
      case 'Year':
        return Icons.calendar_today;
      case 'My Kid':
        return Icons.badge;
      case 'Gender':
        return Icons.wc;
      case 'Date Of Birth':
        return Icons.cake;
      case 'Address':
        return Icons.home;
      case 'Name':
        return Icons.person;
      case 'Email':
        return Icons.email;
      case 'Tel No':
        return Icons.phone;
      case 'Home Tel No':
        return Icons.home_filled;
      case 'IC':
        return Icons.credit_card;
      case 'Income':
        return Icons.money;
      case 'Clinic/Hospital Name':
        return Icons.local_hospital;
      case 'Doctor Tel':
        return Icons.local_phone;
      case 'Medical Condition':
        return Icons.medical_services;
      case 'Relationship':
        return Icons.family_restroom;
      case 'Emergency Tel':
        return Icons.phone_in_talk;
      case 'Drop Address':
        return Icons.location_on;
      case 'Pickup Address':
        return Icons.location_on;
      case 'Transportation':
        return Icons.directions_bus;
      default:
        return Icons.info_outline;
    }
  }

  //DATABASE BACKEND
  Future<void> approveRegistration(
      String docId, Map<String, dynamic> data) async {
    print('Entering approveRegistration with docId: $docId');

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a unique child ID using Firestore's document ID generation
      String newChildId = firestore.collection('child').doc().id;
      print('Generated new child ID: $newChildId');

      // Create a new document in the 'child' collection with the generated ID
      DocumentReference childRef =
          firestore.collection('child').doc(newChildId);

      // Store the userId in the child's document
      String userId = data['userId'];
      print('User ID to be linked: $userId');

      // Add data to the 'child' collection
      await childRef.set(data);
      print('Child document created with data: $data');

      // Extract the 'yearID' from sectionA
      String? yearID = data['SectionA']?['yearID'];
      print('YearID for child: $yearID');

      if (yearID == null) {
        throw Exception(
            'YearID is null. Please ensure the data contains a valid yearID.');
      }

      // Milestone Generation
      QuerySnapshot milestoneSnapshot =
          await firestore.collection('milestones').get();
      List<Map<String, dynamic>> milestones =
          []; // Prepare an array for milestones

      for (var milestoneDoc in milestoneSnapshot.docs) {
        Map<String, dynamic> milestoneData =
            milestoneDoc.data() as Map<String, dynamic>;
        print('Checking milestone document: ${milestoneDoc.id}');

        // Compare the yearID with the 'year' field in the milestone document
        if (milestoneData['year'] == yearID) {
          print('Milestone matches yearID: ${milestoneDoc.id}');

          String milestoneId = milestoneDoc.id;
          Timestamp targetAchievedDate = milestoneData['targetAchievedDate'];

          // Create a milestone entry to add to the array
          milestones.add({
            'milestoneId': milestoneId,
            'targetAchievedDate': targetAchievedDate,
            'achieved': false, // Set achieved to false
          });
          print(
              'Milestone added: {milestoneId: $milestoneId, targetAchievedDate: $targetAchievedDate}');
        }
      }

      // Update the child's document with the milestones array
      if (milestones.isNotEmpty) {
        await childRef.update({'milestones': milestones});
        print('Milestones added to the child document: $milestones');
      } else {
        print('No milestones found for yearID: $yearID.');
      }

      // Fee Generation
      QuerySnapshot feeSnapshot = await firestore
          .collection('fees')
          .where('category', isEqualTo: 'New Registration')
          .get();

      if (feeSnapshot.docs.isNotEmpty) {
        DocumentSnapshot feeDoc = feeSnapshot.docs.first;
        Map<String, dynamic> feeData = feeDoc.data() as Map<String, dynamic>;
        print('Fee data fetched: $feeData');

        // Calculate the due date (one month after the current date)
        DateTime dueDate = DateTime.now().add(Duration(days: 30));
        String formattedDueDate =
            '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';
        print('Formatted due date: $formattedDueDate');

        // Create a new payment document in the payments subcollection
        DocumentReference paymentRef = childRef.collection('payments').doc();
        print('Creating payment document with reference: ${paymentRef.id}');

        // Insert only the specified fields
        await paymentRef.set({
          'amount': feeData['amount'],
          'category': feeData['category'],
          'dueDate': formattedDueDate,
          'feeType': feeData['feeType'],
          'paid': false,
        });
        print('Payment document created successfully.');
      } else {
        print('No fee found for category "New Registration".');
      }

      // Updating the user's document
      DocumentReference userRef = firestore.collection('users').doc(userId);
      print('Updating user document for userId: $userId');

      // Add child ID to the user's document
      print(
          'Attempting to add newChildId: $newChildId to user\'s childIds array');
      try {
        await userRef.update({
          'childIds': FieldValue.arrayUnion([newChildId]),
        });
        print('User document updated with new child ID: $newChildId');
      } catch (e) {
        print('Failed to update user document: $e');
      }

      // Delete the document from the 'pending_approvals' collection
      await firestore.collection('pending_approvals').doc(docId).delete();
      print('Pending approval document deleted for docId: $docId');

      notifyUserAboutRegistrationApproved(widget.adminDocId, userId);
      print(
          'Registration approved and moved to child collection with ID: $newChildId');
    } catch (e) {
      print('Failed to approve registration: $e');
    } finally {
      print('Exiting approveRegistration method.');
    }
  }

  Future<void> denyRegistration(String docId, String userId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Delete the document from the 'pending_approvals' collection
      await firestore.collection('pending_approvals').doc(docId).delete();
      //notifyUserAboutRegistrationDenied(widget.adminDocId, userId);

      print('Registration denied and removed from pending approvals');
    } catch (e) {
      print('Failed to deny registration: $e');
    }
  }

  /////////////////////////////////////AUTO NOTIFICATION////////////////////////////////////////

  void notifyUserAboutRegistrationApproved(String adminDocId, String userId) {
    String title = "Registration Approved"; // Customize the title
    String message =
        "Your child’s registration has been approved."; // Customize the message

    try {
      DatabaseService().sendNotification(
        adminDocId: 'GENERATED',
        userIds: [userId],
        title: title,
        message: message,
      );
      print("Notification sent successfully to user ID: $userId");
    } catch (e) {
      print("Failed to send notification: $e");
    }
  }

///////
  void notifyUserAboutRegistrationDenied(String adminDocId, String userId) {
    String title = "Registration Denied"; // Customize the title
    String message =
        "Your child’s registration has been denied. This is because the information you input in the registration form may be incorrect and not complete. Register again or kindly come to Little IMAN Kids to register!"; // Customize the message

    try {
      DatabaseService().sendNotification(
        adminDocId: 'GENERATED',
        userIds: [userId],
        title: title,
        message: message,
      );
      print("Notification sent successfully to user ID: $userId");
    } catch (e) {
      print("Failed to send notification: $e");
    }
  }
}
