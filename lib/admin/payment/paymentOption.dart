import 'package:flutter/material.dart';

import 'generateFee.dart';
import 'manageFee.dart';
import 'userFeeList.dart';

class FeeOptionPage extends StatelessWidget {
  final String adminDocId;

  const FeeOptionPage({Key? key, required this.adminDocId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Fee Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildOptionCard(
              context,
              'Manage Fees',
              Icons.attach_money,
              () {
                // Navigate to the Fee Management Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ManageFeesPage(adminDocId: adminDocId)),
                );
              },
            ),
            const SizedBox(height: 16.0),
            _buildOptionCard(
              context,
              'Generate Fees',
              Icons.receipt,
              () {
                // Navigate to Generate Fees Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GenerateFeesPage(adminDocId: adminDocId)),
                );
              },
            ),
            const SizedBox(height: 16.0),
            _buildOptionCard(
              context,
              'User Fees',
              Icons.people,
              () {
                // Navigate to User Fees Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UserFeesListPage(adminDocId: adminDocId)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String label, IconData icon,
      VoidCallback onPressed) {
    return Card(
      elevation: 4.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 40.0, color: Colors.grey[800]),
              const SizedBox(width: 16.0),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 15.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
