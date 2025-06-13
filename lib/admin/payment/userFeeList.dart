import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../service/zmodel/usermodel.dart';
import 'userFeeListInfo.dart';

class UserFeesListPage extends StatelessWidget {
  final String adminDocId;

  const UserFeesListPage({Key? key, required this.adminDocId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'User Fees List',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users =
              snapshot.data?.docs.map((doc) => User.fromDocument(doc)).toList();

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchUnpaidAmounts(users),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (futureSnapshot.hasError) {
                return Center(child: Text('Error: ${futureSnapshot.error}'));
              }

              final unpaidAmounts = futureSnapshot.data;

              return ListView.builder(
                itemCount: users?.length ?? 0,
                itemBuilder: (context, index) {
                  final user = users![index];
                  final unpaidAmount =
                      unpaidAmounts![index]['totalUnpaidAmount'] as double;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 4,
                    color: Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.profileImage != null &&
                                user.profileImage!.isNotEmpty
                            ? NetworkImage(user.profileImage!)
                            : null,
                        child: user.profileImage == null ||
                                user.profileImage!.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      title: Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      subtitle: Text(user.email),
                      trailing: Text(
                        unpaidAmount > 0
                            ? 'RM${unpaidAmount.toStringAsFixed(2)}'
                            : 'No unpaid fees',
                        style: TextStyle(
                          color: unpaidAmount > 0
                              ? Colors.redAccent
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        // Navigate to UserFeeListInfoPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserFeeListInfoPage(
                              userId: user.id,
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
    );
  }

  Future<List<Map<String, dynamic>>> _fetchUnpaidAmounts(
      List<User>? users) async {
    List<Map<String, dynamic>> unpaidAmounts = [];

    if (users == null) return unpaidAmounts;

    for (User user in users) {
      double totalUnpaidAmount = 0.0;

      for (String childId in user.childIds) {
        QuerySnapshot paymentSnapshot = await FirebaseFirestore.instance
            .collection('child')
            .doc(childId)
            .collection('payments')
            .where('paid', isEqualTo: false)
            .get();

        for (QueryDocumentSnapshot paymentDoc in paymentSnapshot.docs) {
          totalUnpaidAmount += paymentDoc['amount'] ?? 0.0;
        }
      }

      unpaidAmounts
          .add({'userId': user.id, 'totalUnpaidAmount': totalUnpaidAmount});
    }

    return unpaidAmounts;
  }
}
