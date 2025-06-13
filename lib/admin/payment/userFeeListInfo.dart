// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserFeeListInfoPage extends StatefulWidget {
  final String userId; // User ID parameter

  const UserFeeListInfoPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserFeeListInfoPage> createState() => _UserFeeListInfoPageState();
}

class _UserFeeListInfoPageState extends State<UserFeeListInfoPage> {
  late Future<List<Map<String, dynamic>>> _childDetailsFuture;

  @override
  void initState() {
    super.initState();
    _childDetailsFuture = _fetchChildDetails(widget.userId);
  }

  Future<List<Map<String, dynamic>>> _fetchChildDetails(String userId) async {
    List<Map<String, dynamic>> childDetails = [];

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    var data = userDoc.data() as Map<String, dynamic>;
    List<String> childIds = List<String>.from(data['childIds'] ?? []);

    for (String childId in childIds) {
      DocumentSnapshot childDoc = await FirebaseFirestore.instance
          .collection('child')
          .doc(childId)
          .get();
      var childData = childDoc.data() as Map<String, dynamic>;

      String nameC = 'Unknown';
      String yearId = 'Unknown';
      String? profileImage = childData['profileImage']; // Fetch profileImage
      List<Map<String, dynamic>> paymentDetails = [];
      double totalUnpaidAmount = 0.0; // Initialize total unpaid amount

      if (childData.containsKey('SectionA')) {
        var sectionA = childData['SectionA'] as Map<String, dynamic>;
        nameC = sectionA['nameC'] ?? 'Unknown';
        yearId = sectionA['yearID'] ?? 'Unknown';
      }

      QuerySnapshot paymentsSnapshot = await FirebaseFirestore.instance
          .collection('child')
          .doc(childId)
          .collection('payments')
          .get();

      for (var paymentDoc in paymentsSnapshot.docs) {
        var paymentData = paymentDoc.data() as Map<String, dynamic>;
        paymentDetails.add({
          'paymentId': paymentDoc.id,
          'childId': childId,
          'feeType': paymentData['feeType'] ?? 'Unknown',
          'paid': paymentData['paid'] ?? false,
          'amount': paymentData['amount'] ?? 0.0,
        });

        // Calculate total unpaid amount
        if (!paymentData['paid']) {
          totalUnpaidAmount += paymentData['amount'] ?? 0.0;
        }
      }

      paymentDetails.sort((a, b) {
        return (a['paid'] ? 1 : 0).compareTo(b['paid'] ? 1 : 0);
      });

      childDetails.add({
        'nameC': nameC,
        'yearID': yearId,
        'profileImage': profileImage, // Add profileImage to childDetails
        'payments': paymentDetails,
        'totalUnpaidAmount': totalUnpaidAmount, // Add total unpaid amount
      });
    }

    return childDetails;
  }

  void _editPayment(String childId, String paymentId,
      Map<String, dynamic> paymentData) async {
    TextEditingController feeTypeController =
        TextEditingController(text: paymentData['feeType']);
    TextEditingController amountController =
        TextEditingController(text: paymentData['amount'].toString());

    bool isPaid = paymentData['paid'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Colors.black.withOpacity(0.7), // Transparent black background
          title: const Text(
            'Edit Payment',
            style: TextStyle(color: Colors.white), // White text color
          ),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: feeTypeController,
                      style: TextStyle(color: Colors.white), // White text color
                      decoration: InputDecoration(
                        labelText: 'Fee Type',
                        labelStyle: TextStyle(
                            color: Colors.white70), // Light grey label
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white70), // Light grey underline
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white), // White underline on focus
                        ),
                      ),
                    ),
                    TextField(
                      controller: amountController,
                      style: TextStyle(color: Colors.white), // White text color
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        labelStyle: TextStyle(
                            color: Colors.white70), // Light grey label
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white70), // Light grey underline
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white), // White underline on focus
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Paid',
                          style: TextStyle(
                              color: Colors.white), // White text color
                        ),
                        Switch(
                          value: isPaid,
                          onChanged: (value) {
                            setState(() {
                              isPaid = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('child')
                    .doc(childId)
                    .collection('payments')
                    .doc(paymentId)
                    .update({
                  'feeType': feeTypeController.text,
                  'amount': double.tryParse(amountController.text) ?? 0.0,
                  'paid': isPaid,
                });

                setState(() {
                  _childDetailsFuture = _fetchChildDetails(widget.userId);
                });

                Navigator.of(context).pop();
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String childId, String paymentId) async {
    bool confirmDelete = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Colors.black.withOpacity(0.7), // Transparent black background
          title: const Text(
            'Delete Payment',
            style: TextStyle(color: Colors.white), // White text color
          ),
          content: const Text(
            'Are you sure you want to delete this payment?',
            style: TextStyle(color: Colors.white70), // Light grey text color
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      await FirebaseFirestore.instance
          .collection('child')
          .doc(childId)
          .collection('payments')
          .doc(paymentId)
          .delete();
      setState(() {
        _childDetailsFuture = _fetchChildDetails(widget.userId);
      });
    }
  }

  void _deletePayment(String childId, String paymentId) async {
    await _showDeleteConfirmationDialog(context, childId, paymentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'User Fee Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _childDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final childDetails = snapshot.data ?? [];

          return ListView.builder(
            itemCount: childDetails.length,
            itemBuilder: (context, index) {
              final child = childDetails[index];
              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 4,
                color: Colors.white,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  childrenPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: child['profileImage'] != null &&
                                child['profileImage']!.isNotEmpty
                            ? NetworkImage(child['profileImage'])
                            : const AssetImage('assets/placeholder.png')
                                as ImageProvider,
                        child: child['profileImage'] == null ||
                                child['profileImage']!.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(width: 10), // Space between image and text
                      Text(
                        '${child['nameC'].length > 20 ? child['nameC'].substring(0, 20) + '..' : child['nameC']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Year ID: ${child['yearID']}'),
                      Text(
                        'Total Unpaid Amount: RM${child['totalUnpaidAmount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          color: child['totalUnpaidAmount'] > 0
                              ? Colors.red
                              : Colors.black, // Conditional text color
                        ),
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  children: child['payments'].map<Widget>((payment) {
                    return ListTile(
                      title: Text(
                        'Fee: ${payment['feeType']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${payment['paymentId']}'),
                          Text(
                            payment['paid'] ? 'Paid' : 'Unpaid',
                            style: TextStyle(
                              color:
                                  payment['paid'] ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                              'Amount: RM${payment['amount'].toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.black54),
                            onPressed: () => _editPayment(payment['childId'],
                                payment['paymentId'], payment),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePayment(
                                payment['childId'], payment['paymentId']),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
