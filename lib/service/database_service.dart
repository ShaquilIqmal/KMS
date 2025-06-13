// lib/services/database_service.dart

// ignore_for_file: avoid_print, avoid_single_cascade_in_expression_statements, await_only_futures, unnecessary_brace_in_string_interps, use_rethrow_when_possible, unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kms2/service/zmodel/childmodel.dart';
import 'package:kms2/service/zmodel/teachermodel.dart'; // Import the teacher model
import 'package:kms2/service/zmodel/usermodel.dart';

class DatabaseService {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference teacherCollection = FirebaseFirestore.instance
      .collection('teachers'); // Add teacher collection
  final CollectionReference attendanceCollection =
      FirebaseFirestore.instance.collection('attendance');
  final CollectionReference childCollection =
      FirebaseFirestore.instance.collection('child');
  final CollectionReference timetableCollection =
      FirebaseFirestore.instance.collection('timetable');
  final CollectionReference adminCollection =
      FirebaseFirestore.instance.collection('admins');
  final CollectionReference notificationsCollection =
      FirebaseFirestore.instance.collection('notifications');
  final CollectionReference milestoneCollection =
      FirebaseFirestore.instance.collection('milestones');
  final CollectionReference reportsCollection =
      FirebaseFirestore.instance.collection('reports');
  final CollectionReference receiptsCollection =
      FirebaseFirestore.instance.collection('reports');

  Future<DocumentReference> addUser(Map<String, dynamic> userData) async {
    return await userCollection.add(userData);
  }

  Future<bool> doesEmailExist(String email) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return result
        .docs.isNotEmpty; // Returns true if there's at least one document
  }

  /*Future<QuerySnapshot> getTeachersByEmail(String email,
      {String collection = 'teachers'}) async {
    return await FirebaseFirestore.instance
        .collection(collection)
        .where('email', isEqualTo: email)
        .get();
  }*/

  Future<QuerySnapshot> getUserByEmail(String email,
      {String collection = 'users'}) async {
    if (collection == 'teachers') {
      return await FirebaseFirestore.instance
          .collection(collection)
          .where('contactInfo.email',
              isEqualTo: email) // Use dot notation for nested fields
          .get();
    } else {
      return await FirebaseFirestore.instance
          .collection(collection)
          .where('email', isEqualTo: email) // Top-level email field
          .get();
    }
  }

  Future<DocumentSnapshot> getUserById(String docId) async {
    return await userCollection.doc(docId).get();
  }

  Future<void> deleteUser(String userId) async {
    await userCollection.doc(userId).delete();
  }

  Future<void> updateUser(
      String userId, Map<String, dynamic> updatedData) async {
    await userCollection.doc(userId).update(updatedData);
  }

  Future<void> editUser(String userId, Map<String, dynamic> newData) async {
    await userCollection.doc(userId).update(newData);
  }

  Future<void> deleteChild(String childId, String userId) async {
    // Deleting the child document from the "child" collection
    await childCollection.doc(childId).delete();

    // Removing the child's ID from the user's "childIds" array
    await userCollection.doc(userId).update({
      'childIds': FieldValue.arrayRemove([childId]),
    });

// Removing the child's attendance data from the "attendance" collection
    await removeChildAttendanceData(childId);
  }

  Future<void> removeChildAttendanceData(String childId) async {
    try {
      // Fetch all attendance documents
      QuerySnapshot attendanceSnapshot = await attendanceCollection.get();

      for (var doc in attendanceSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Check attendanceHistory for the specific childID
        List<dynamic> updatedHistory = [];
        if (data['attendanceHistory'] != null) {
          for (var history in data['attendanceHistory']) {
            if (history['childID'] == childId) {
              // Skip this history for deletion
              continue;
            }
            updatedHistory.add(history);
          }
        }

        // Update the attendanceHistory if any history was removed
        if (updatedHistory.length != (data['attendanceHistory']?.length ?? 0)) {
          await attendanceCollection.doc(doc.id).update({
            'attendanceHistory': updatedHistory,
          });
        }

        // Check attendanceRecord for the specific childID
        List<dynamic> updatedRecords = [];
        if (data['attendanceRecord'] != null) {
          for (var record in data['attendanceRecord']) {
            if (record['childID'] == childId) {
              // Skip this record for deletion
              continue;
            }
            updatedRecords.add(record);
          }
        }

        // Update the attendanceRecord if any records were removed
        if (updatedRecords.length != (data['attendanceRecord']?.length ?? 0)) {
          await attendanceCollection.doc(doc.id).update({
            'attendanceRecord': updatedRecords,
          });
        }
      }
    } catch (e) {
      print('Error removing child attendance data: $e');
    }
  }

  Stream<List<User>> getUsersWithChildren() {
    //viewUserInfoPage.dart
    return userCollection.snapshots().asyncMap((snapshot) async {
      List<User> users = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>?; // Safely cast data
        if (data != null) {
          var user = User.fromDocument(doc);
          // Check if the user has childIds and it's not empty
          if (data.containsKey('childIds') &&
              (data['childIds'] as List).isNotEmpty) {
            List<String> childIds = List<String>.from(data['childIds']);
            // Fetch child documents only if childIds is not empty
            var childrenSnapshot = await FirebaseFirestore.instance
                .collection('child')
                .where(FieldPath.documentId, whereIn: childIds)
                .get();
            user.children = childrenSnapshot.docs
                .map((childDoc) => Child.fromDocument(childDoc))
                .toList();
          }
          users.add(user);
        }
      }
      return users;
    }).asBroadcastStream();
  }

  Future<DocumentReference> addTeacher(Map<String, dynamic> teacherData) async {
    return await teacherCollection.add(teacherData);
  }

  Future<QuerySnapshot> getTeacherByName(String name) async {
    return await teacherCollection.where('name', isEqualTo: name).get();
  }

  Future<DocumentSnapshot> getTeacherById(String docId) async {
    return await teacherCollection.doc(docId).get();
  }

  /* Future<void> deleteTeacher(String teacherId) async {
    await teacherCollection.doc(teacherId).delete();
  }*/

  Future<void> deleteTeacher(String teacherId) async {
    // Delete associated timetable entries
    await FirebaseFirestore.instance
        .collection('timetable')
        .where('teacherId',
            isEqualTo: teacherId) // Assuming you have a field for teacherId
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete(); // Delete each associated entry
      }
    });

    // Now delete the teacher
    await FirebaseFirestore.instance
        .collection('teachers')
        .doc(teacherId)
        .delete();
  }

  Future<void> editTeacher(
      String teacherId, Map<String, dynamic> newData) async {
    await teacherCollection.doc(teacherId).update(newData);
  }

  Stream<List<Teacher>> getTeachers() {
    return teacherCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Teacher.fromDocument(doc)).toList();
    });
  }

  Future<List<String>> getChildrenNames(String userId) async {
    List<String> childrenNames = [];
    QuerySnapshot childrenSnapshot =
        await userCollection.doc(userId).collection('child').get();
    for (var doc in childrenSnapshot.docs) {
      childrenNames.add(doc['SectionA']['nameC']);
    }
    return childrenNames;
  }

  Future<List<String>> getChildrenIds(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Ensure that the document exists and cast the data to a Map<String, dynamic>
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Access the 'childIds' field safely, and default to an empty list if it doesn't exist
      List<String> childIds = List<String>.from(userData['childIds'] ?? []);

      // Log the fetched child IDs
      print('Fetched child IDs for user $userId: $childIds');

      return childIds;
    } catch (e) {
      print('Error fetching child IDs for user $userId: $e');
      return []; // Return an empty list if there's an error
    }
  }

  // Ensure the collection name matches
  Future<String> getChildNameById(String childId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('child')
          .doc(childId)
          .get();
      if (doc.exists) {
        // Accessing the nested field 'nameC' within 'SectionA'
        var data =
            doc.data() as Map<String, dynamic>; // Ensure to cast the data
        return data['SectionA']?['nameC'] ??
            'Name not available'; // Use null safety
      } else {
        print('Child document does not exist for ID: $childId');
        return 'Unknown Child';
      }
    } catch (e) {
      print('Error fetching child name for ID: $childId - $e');
      return 'Error';
    }
  }

  Future<Map<String, dynamic>> getChildDetailsById(String childId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('child')
          .doc(childId)
          .get();
      if (doc.exists) {
        var data =
            doc.data() as Map<String, dynamic>; // Ensure to cast the data
        return {
          'name': data['SectionA']?['nameC'] ?? 'Name not available',
          'profileImage': data['profileImage'] ??
              '', // Assuming 'profileImage' is a top-level field
        };
      } else {
        print('Child document does not exist for ID: $childId');
        return {'name': 'Unknown Child', 'profileImage': ''};
      }
    } catch (e) {
      print('Error fetching child details for ID: $childId - $e');
      return {'name': 'Error', 'profileImage': ''};
    }
  }

  Future<String?> getChildProfileImage(String childId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('child')
          .doc(childId)
          .get();
      if (doc.exists) {
        var data =
            doc.data() as Map<String, dynamic>; // Ensure to cast the data
        return data[
            'profileImage']; // Assuming 'profileImage' is the field in Firestore
      } else {
        print('Child document does not exist for ID: $childId');
        return null; // Return null if the document does not exist
      }
    } catch (e) {
      print('Error fetching child profile image for ID: $childId - $e');
      return null; // Return null in case of an error
    }
  }

// Method to get the child's year
  Future<String?> getChildYearID(String childId) async {
    try {
      // Fetching the document
      DocumentSnapshot childDoc = await FirebaseFirestore.instance
          .collection('child')
          .doc(childId)
          .get();

      if (childDoc.exists) {
        // Accessing the nested field 'yearID' within 'SectionA'
        var data = childDoc.data() as Map<String, dynamic>?; // Cast the data
        if (data != null) {
          var sectionA = data['SectionA'];
          if (sectionA != null) {
            var yearID = sectionA['yearID']; // Fetch yearID directly

            // Return yearID as it is already a String
            if (yearID is String) {
              return yearID; // Already a String
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching child yearID for ID: $childId - $e');
    }

    return null; // Return null if not found or an error occurred
  }

  static Future<String?> fetchAdminData(String docId) async {
    //dashboard admin
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(docId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'N/A';
        print('docId: ${docId}');
        print('Name: $name');
        return name;
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (error) {
      print('Error fetching user data: $error');
      return null;
    }
  }

  static Future<String?> fetchUserData(String docId) async {
    //dashboard user
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(docId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'N/A';
        print('docId: ${docId}');
        print('Name: $name');
        return name;
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (error) {
      print('Error fetching user data: $error');
      return null;
    }
  }

  static Future<String?> fetchUserName(String docId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('teachers')
          .doc(docId)
          .get();

      if (doc.exists) {
        return doc['name'];
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (error) {
      print('Error fetching user data: $error');
      return null;
    }
  }

  static Future<Teacher?> fetchTeacherData(String docId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('teachers')
          .doc(docId)
          .get();

      if (doc.exists) {
        return Teacher.fromDocument(doc); // Return the Teacher object
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (error) {
      print('Error fetching teacher data: $error');
      return null;
    }
  }

  static Future<List<String>> fetchAssignedClasses(String teacherId) async {
    //attendance module
    try {
      DocumentSnapshot teacherDoc = await FirebaseFirestore.instance
          .collection('teachers')
          .doc(teacherId)
          .get();

      if (teacherDoc.exists) {
        List<dynamic> classes = teacherDoc['assignedClasses'];
        return List<String>.from(classes);
      }
    } catch (e) {
      print('Error fetching assigned classes: $e');
    }
    return [];
  }

  // Method to fetch attendance records by yearID
  Future<List<Map<String, dynamic>>> getAttendanceByYear(String yearID) async {
    try {
      QuerySnapshot snapshot = await attendanceCollection
          .where('yearID', isEqualTo: yearID) // Filter by yearID
          .get();

      // Extract the attendanceRecord field from the document
      List<Map<String, dynamic>> attendanceRecords = [];
      for (var doc in snapshot.docs) {
        var records = doc['attendanceRecord'] as List<dynamic>;
        attendanceRecords.addAll(
            records.cast<Map<String, dynamic>>()); // Add records to list
      }
      return attendanceRecords;
    } catch (e) {
      print('Error fetching attendance records: $e');
      return [];
    }
  }

  // Method to add a milestone
  Future<void> addMilestone(
      String milestoneId, Map<String, dynamic> milestoneData) async {
    await FirebaseFirestore.instance
        .collection('milestones')
        .doc(milestoneId)
        .set(milestoneData);
  }

  // Method to fetch milestones for a specific child
// Method to fetch milestones for a specific child
  Future<List<Map<String, dynamic>>> getChildMilestones(String childId) async {
    try {
      // Query the 'child' collection for the specific child document
      DocumentSnapshot snapshot = await childCollection.doc(childId).get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;

        // Fetch the 'milestones' field
        var milestones = data['milestones'] as List<dynamic>?;

        if (milestones != null) {
          // Convert the List<dynamic> to List<Map<String, dynamic>>
          return milestones.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      print('Error fetching milestones for child ID: $childId - $e');
    }

    return []; // Return an empty list in case of error or no milestones
  }

  Future<void> updateChildDetails(
      String childId, Map<String, dynamic> updatedDetails) async {
    try {
      await childCollection.doc(childId).update(updatedDetails);
    } catch (e) {
      print('Error updating child details: $e');
      throw e;
    }
  }

///////////////////////////////////////////////////////////////////////////
  // Method to fetch and print all documents in the 'attendance' collection
  Future<void> checkAttendanceCollection() async {
    try {
      QuerySnapshot snapshot = await attendanceCollection.get();
      for (var doc in snapshot.docs) {
        print('Attendance ID: ${doc.id}');
        print('Data: ${doc.data()}');
      }
    } catch (e) {
      print('Error fetching attendance collection: $e');
    }
  }

  // Method to fetch and print all documents in the 'child' collection
  Future<void> checkChildCollection() async {
    try {
      QuerySnapshot snapshot = await childCollection.get();
      for (var doc in snapshot.docs) {
        print('Child ID: ${doc.id}');
        print('Data: ${doc.data()}');
      }
    } catch (e) {
      print('Error fetching child collection: $e');
    }
  }

  // Method to fetch and print all documents in the 'teachers' collection
  Future<void> checkTeacherCollection() async {
    try {
      QuerySnapshot snapshot = await teacherCollection.get();
      for (var doc in snapshot.docs) {
        print('Teacher ID: ${doc.id}');
        print('Data: ${doc.data()}');
      }
    } catch (e) {
      print('Error fetching teacher collection: $e');
    }
  }

  // Method to fetch and print all documents in the 'timetable' collection
  Future<void> checkTimetableCollection() async {
    try {
      QuerySnapshot snapshot = await timetableCollection.get();
      for (var doc in snapshot.docs) {
        print('Timetable ID: ${doc.id}');
        print('Data: ${doc.data()}');
      }
    } catch (e) {
      print('Error fetching timetable collection: $e');
    }
  }

  // Method to fetch and print all documents in the 'users' collection
  static Future<void> checkUserCollection() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      for (var doc in snapshot.docs) {
        print('User ID: ${doc.id}');
        print('Data: ${doc.data()}');
      }
    } catch (e) {
      print('Error fetching user collection: $e');
    }
  }

  // Method to fetch and print all documents in the 'admins' collection
  Future<void> checkAdminCollection() async {
    try {
      QuerySnapshot snapshot = await adminCollection.get();
      for (var doc in snapshot.docs) {
        print('Admin ID: ${doc.id}');
        print('Data: ${doc.data()}');
      }
    } catch (e) {
      print('Error fetching admin collection: $e');
    }
  }

  // Method to fetch and print all documents in the 'notifications' collection
  Future<void> checkNotificationCollection() async {
    try {
      QuerySnapshot snapshot = await notificationsCollection.get();
      for (var doc in snapshot.docs) {
        print('Notification ID: ${doc.id}');
        print('Data: ${doc.data()}');
      }
    } catch (e) {
      print('Error fetching notification collection: $e');
    }
  }

  // Method to call all the collection check methods and print data in the terminal
  Future<void> checkCollection() async {
    print('\n--- Checking Child Collection ---');
    await checkAttendanceCollection();
  }

  Future<String?> fetchUserProfileImage(String docId) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(docId).get();
      if (userDoc.exists) {
        return userDoc['profileImage']; // Adjust the field name if necessary
      } else {
        print("User document does not exist.");
        return null;
      }
    } catch (e) {
      print("Error fetching profile image: $e");
      return null;
    }
  }

  Future<Child> fetchUpdatedChildData(String childId) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('child').doc(childId).get();

    if (doc.exists) {
      return Child.fromDocument(doc);
    } else {
      throw Exception('Child not found');
    }
  }

  // Method to update user profile image
  Future<void> updateUserProfileImage(String userId, String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profileImage': imageUrl,
      });
    } catch (e) {
      print("Error updating user profile image: $e");
      throw e; // Optionally, rethrow the error for further handling
    }
  }

  // Method to update user data
  Future<void> updateUserData(
      String userId, String name, String email, String phone) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': name,
        'email': email,
        'noTel': phone,
      });
    } catch (e) {
      print("Error updating user data: $e");
      throw e; // Optionally, rethrow the error for further handling
    }
  }

  // Method to create a report
  Future<void> createReport({
    required String reportId,
    required String generatedBy,
    required DateTime periodStart,
    required DateTime periodEnd,
    required double totalPaid,
    required double totalUnpaid,
    required List<String> reportData, // Array of userIds or paymentIds
  }) async {
    try {
      await FirebaseFirestore.instance
        ..collection('reports').doc(reportId).set({
          'generatedBy': generatedBy,
          'periodStart': Timestamp.fromDate(periodStart),
          'periodEnd': Timestamp.fromDate(periodEnd),
          'totalPaid': totalPaid,
          'totalUnpaid': totalUnpaid,
          'reportData': reportData,
        });
      print('Report created successfully: $reportId');
    } catch (e) {
      print('Failed to create report: $e');
    }
  }

  Future<double> fetchTotalDueAmount(String childId) async {
    double totalAmount = 0.0;

    try {
      QuerySnapshot paymentSnapshot = await FirebaseFirestore.instance
          .collection('child') // Adjust collection path as necessary
          .doc(childId)
          .collection('payments')
          .where('paid', isEqualTo: false) // Filter for unpaid amounts
          .get();

      for (var paymentDoc in paymentSnapshot.docs) {
        totalAmount +=
            (paymentDoc.data() as Map<String, dynamic>)['amount'] ?? 0.0;
      }
    } catch (e) {
      print('Error fetching payment data: $e');
    }

    return totalAmount;
  }

  Future<Map<String, dynamic>?> fetchPaymentIntentDetails(
      String paymentIntentId) async {
    try {
      DocumentSnapshot paymentIntentDoc = await FirebaseFirestore.instance
          .collection('payment_Intent')
          .doc(paymentIntentId)
          .get();

      if (paymentIntentDoc.exists) {
        return paymentIntentDoc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error fetching payment intent details: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchPaymentRecords(String childId) async {
    List<Map<String, dynamic>> paymentRecords = [];

    try {
      QuerySnapshot paymentSnapshot = await FirebaseFirestore.instance
          .collection('child') // Main collection
          .doc(childId) // Specific child document
          .collection('payments') // Subcollection
          .get();

      for (var paymentDoc in paymentSnapshot.docs) {
        // Safely access the document data
        var data = paymentDoc.data() as Map<String, dynamic>?;

        paymentRecords.add({
          'id': paymentDoc.id, // Add the document ID
          'description': data?['description'], // Match your Firestore fields
          'amount': data?['amount'],
          'dueDate': data?['dueDate'],
          'paid':
              data?['paid'], // Match your Firestore field for payment status
          'category': data?['category'],
          'feeType': data?['feeType'],
          'datePaid': data != null && data.containsKey('datePaid')
              ? data['datePaid']
              : null, // Check if the field exists safely
          'paymentIntentId': data?['paymentIntentId'], // New field
        });
      }
    } catch (e) {
      print('Error fetching payment records: $e');
    }

    return paymentRecords;
  }

  Future<List<Map<String, dynamic>>> fetchPaymentsForChild(
      String childId) async {
    try {
      // Reference to the payments subcollection for the specified child
      CollectionReference paymentsRef = FirebaseFirestore.instance
          .collection('child')
          .doc(childId)
          .collection('payments');

      // Fetch the documents from the payments subcollection
      QuerySnapshot snapshot = await paymentsRef.get();

      // Map the documents to a list of payment records
      List<Map<String, dynamic>> payments = snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Document ID
          ...doc.data() as Map<String, dynamic>, // Document data
        };
      }).toList();

      return payments;
    } catch (e) {
      print("Error fetching payments for child ID $childId: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchPaymentIntents(String childId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('child') // Access the 'child' collection
          .doc(childId) // Specify the child document
          .collection(
              'payment_Intent') // Access the 'payment_Intent' subcollection
          .get(); // Fetch the documents

      return querySnapshot.docs.map((doc) {
        return {
          'id_pi': doc.id, // Document ID
          ...doc.data() as Map<String, dynamic>, // Document data
        };
      }).toList();
    } catch (e) {
      print("Error fetching payment intents: $e");
      return []; // Return an empty list on error
    }
  }

  Future<Map<String, dynamic>?> fetchPaymentIntentForReceipt(
      String childId, String paymentId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('child')
          .doc(childId)
          .collection('payment_Intent')
          .doc(paymentId) // Fetch the specific payment intent document
          .get();

      if (docSnapshot.exists) {
        return {
          'id_pi': docSnapshot.id, // Document ID
          ...docSnapshot.data() as Map<String, dynamic>, // Document data
        };
      }
    } catch (e) {
      print("Error fetching payment intent: $e");
    }
    return null; // Return null if not found
  }

  Future<void> createReceipt(
      List<Map<String, dynamic>> selectedPayments) async {
    for (var payment in selectedPayments) {
      try {
        // Create a reference to the receipt document
        final receiptRef = FirebaseFirestore.instance
            .collection('receipts')
            .doc(); // Automatically generate a document ID

        // Create a receipt object
        Map<String, dynamic> receiptData = {
          'childId': payment['childId'],
          'paymentId': payment['id'],
          'amount': payment['amount'], // Ensure amount is passed
          'currency': 'MYR', // Change if necessary
          'date': DateTime.now(),
          'status': 'paid',
        };

        // Store the receipt in Firestore
        await receiptRef.set(receiptData);
        print("Receipt created for Payment ID: ${payment['id']}");
      } catch (e) {
        print(
            "Error creating receipt for Payment ID: ${payment['id']}. Error: $e");
      }
    }
  }

  Future<int> getUsersCount() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get(); // Fetch all documents in the 'users' collection

      int count = querySnapshot.size; // Get the number of documents
      print("Number of users: $count");
      return count;
    } catch (e) {
      print("Error fetching users count: $e");
      return 0; // Return 0 in case of error
    }
  }

  Future<int> getChildrenCount() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('child').get();

      int count = querySnapshot.size;
      for (var doc in querySnapshot.docs) {
        print(
            "Document ID: ${doc.id}, Data: ${doc.data()}"); // Log each document's ID and data
      }
      print("Total Number of Children: $count");
      return count;
    } catch (e) {
      print("Error fetching children: $e");
      return 0;
    }
  }

  Future<int> getPendingApprovalsCount() async {
    try {
      // Reference to the 'pending_approvals' collection
      CollectionReference collection =
          FirebaseFirestore.instance.collection('pending_approvals');

      // Get the documents in the collection
      QuerySnapshot querySnapshot = await collection.get();

      // Return the count of documents
      return querySnapshot
          .size; // Returns 0 if the collection doesn't exist or is empty
    } catch (e) {
      print("Error fetching pending approvals: $e");
      return 0; // Return 0 in case of error
    }
  }

  Future<List<double>> fetchMonthlyIncomeData() async {
    List<double> monthlyIncome = List<double>.filled(12, 0.0); // Initialize

    try {
      // Get current year
      final now = DateTime.now();
      final currentYear = now.year.toString();

      // Debugging: Print current year
      //print("Fetching data for year: $currentYear");

      // Iterate through all months to fetch data
      for (int month = 1; month <= 12; month++) {
        final documentId = '$currentYear-$month';

        // Debugging: Print document ID
        //print("Fetching data for document ID: $documentId");

        final snapshot = await FirebaseFirestore.instance
            .collection('incomePerMonth')
            .doc(documentId)
            .get();

        // Check if document exists and handle potential null values
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final incomeList = data['incomeList'];

          // Ensure incomeList is a List
          if (incomeList is List<dynamic>) {
            // Debugging: Print retrieved income list
            //print("Income List for $documentId: $incomeList");

            for (var income in incomeList) {
              int incomeMonth = (income['date'] as Timestamp).toDate().month;

              // Handle amount as double or int
              num amount =
                  income['amount']; // Use num to capture both int and double
              monthlyIncome[incomeMonth - 1] +=
                  amount.toDouble(); // Convert to double

              // Debugging: Print aggregated values
              //print(
              //"Aggregating for month $incomeMonth: Amount = $amount, Total = ${monthlyIncome[incomeMonth - 1]}");
            }

            // Debugging: Print monthly income after aggregation
            //print("Monthly Income after $documentId: $monthlyIncome");
          } else {
            //print(
            //"No incomeList found or it is not a List for document ID: $documentId");
          }
        } else {
          //print("Document does not exist for ID: $documentId");
        }
      }
    } catch (e) {
      // print("Error fetching monthly income data: $e");
    }

    return monthlyIncome; // Return the aggregated monthly income
  }

  // Method to fetch children by yearId
  Stream<List<Map<String, dynamic>>> getChildrenByYear(String yearId) {
    return FirebaseFirestore.instance
        .collection('child')
        .where('SectionA.yearID', isEqualTo: yearId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, // Include document ID
          'nameC': data['SectionA']['nameC'] ?? 'Unknown',
          'yearID': data['SectionA']['yearID'] ?? 'Unknown',
          'profileImage': data['profileImage'] ?? '', // Add profileImage
        };
      }).toList();
    });
  }

  Future<void> saveDailySnapForChild(
      String childId, String imageUrl, String currentDate) async {
    try {
      final dailySnapCollection =
          FirebaseFirestore.instance.collection('dailySnap4Children');

      await dailySnapCollection.doc(childId).set({
        'currentDate': currentDate, // Use the formatted date here
        'dailySnap': imageUrl,
      });

      print('Daily snap saved for child ID: $childId');
    } catch (e) {
      print('Error saving daily snap: $e');
      throw e;
    }
  }

  // Method to get daily snap for a specific child and date
  Future<Map<String, dynamic>?> getDailySnapForChild(String childId) async {
    try {
      print('Fetching daily snap for child ID: $childId');

      final documentSnapshot = await FirebaseFirestore.instance
          .collection('dailySnap4Children')
          .doc(childId) // Use childId as the document ID
          .get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        return data; // Return the entire document data
      } else {
        print('No document found for child ID: $childId');
        return null; // No document found
      }
    } catch (e) {
      print('Error fetching daily snap: $e');
      return null; // Return null in case of error
    }
  }

  Future<void> sendNotification({
    // Auto Notification
    required String adminDocId,
    required List<String> userIds, // List of user IDs to notify
    required String title,
    required String message,
  }) async {
    try {
      // Add notification document to the Firestore 'notifications' collection
      DocumentReference notificationRef =
          await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'message': message,
        'senderId': adminDocId, // Admin ID who sends the notification
        'timestamp': FieldValue.serverTimestamp(),
        'recipients': userIds
            .map((id) => {'id': id, 'isRead': false})
            .toList(), // Recipients' IDs with isRead field
      });

      // Send notification to each user
      for (String userId in userIds) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(notificationRef.id)
            .set({
          'notificationId':
              notificationRef.id, // Reference to the main notification
          'title': title,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false, // Set isRead to false for each user's notification
        });
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}
