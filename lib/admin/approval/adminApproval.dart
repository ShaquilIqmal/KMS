import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'approvalDetail.dart';

class AdminApprovalPage extends StatelessWidget {
  final String adminDocId;
  const AdminApprovalPage({Key? key, required this.adminDocId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pending Approvals',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('pending_approvals')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final pendingApprovals = snapshot.data!.docs;

          // Check if there are no pending approvals
          if (pendingApprovals.isEmpty) {
            return const Center(
              child: Text(
                'No Approval Request',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            itemCount: pendingApprovals.length,
            itemBuilder: (context, index) {
              final approval = pendingApprovals[index];
              final approvalData = approval.data() as Map<String, dynamic>;
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 5,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    approvalData['SectionA']['nameC'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Status: ${approvalData['status']}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                    ),
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApprovalDetailPage(
                          docId: approval.id,
                          data: approvalData,
                          adminDocId: adminDocId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
