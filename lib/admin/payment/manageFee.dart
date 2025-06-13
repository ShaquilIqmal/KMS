// ignore_for_file: file_names, use_super_parameters, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageFeesPage extends StatefulWidget {
  final String adminDocId;

  const ManageFeesPage({Key? key, required this.adminDocId}) : super(key: key);

  @override
  _ManageFeesPageState createState() => _ManageFeesPageState();
}

class _ManageFeesPageState extends State<ManageFeesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _feeTypeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = [
    'Additional Items',
    'MonthlyFees',
    'New Registration',
  ];

  List<DocumentSnapshot> _feesList = [];
  List<DocumentSnapshot> _feeHistoryList = []; // To store deleted fees
  String? _editingFeeId; // To store the ID of the fee being edited

  @override
  void initState() {
    super.initState();
    _fetchFees();
    _fetchFeeHistory(); // Fetch fee history
  }

  Future<void> _fetchFees() async {
    QuerySnapshot snapshot = await _firestore.collection('fees').get();
    setState(() {
      _feesList = snapshot.docs;
    });
  }

  Future<void> _fetchFeeHistory() async {
    QuerySnapshot snapshot = await _firestore.collection('feeHistory').get();
    setState(() {
      _feeHistoryList = snapshot.docs; // Store deleted fees
    });
  }

  Future<void> _addOrUpdateFee() async {
    final feeType = _feeTypeController.text;
    final amount = double.tryParse(_amountController.text);

    if (feeType.isNotEmpty && amount != null && _selectedCategory != null) {
      // Generate initials from the feeType
      String initials =
          feeType.split(' ').map((word) => word[0].toUpperCase()).join('');

      if (_editingFeeId == null) {
        // Adding a new fee
        DocumentReference newDocRef = _firestore.collection('fees').doc();
        String feeId = '${initials}_${newDocRef.id}';

        await newDocRef.set({
          'feeId': feeId,
          'feeType': feeType,
          'amount': amount,
          'category': _selectedCategory,
          'dueDate': Timestamp.now(),
        });
      } else {
        // Updating an existing fee
        await _firestore.collection('fees').doc(_editingFeeId).update({
          'feeType': feeType,
          'amount': amount,
          'category': _selectedCategory,
        });
        _editingFeeId = null; // Reset the editing fee ID after update
      }

      _feeTypeController.clear();
      _amountController.clear();
      setState(() {
        _selectedCategory = null;
      });
      await _fetchFees();
      await _fetchFeeHistory(); // Refresh fee history
    }
  }

  Future<void> _deleteFee(String feeId) async {
    DocumentSnapshot feeDoc =
        await _firestore.collection('fees').doc(feeId).get();

    // Move the fee to feeHistory
    await _firestore
        .collection('feeHistory')
        .doc(feeId)
        .set(feeDoc.data() as Map<String, dynamic>);

    // Delete the fee from the fees collection
    await _firestore.collection('fees').doc(feeId).delete();

    await _fetchFees();
    await _fetchFeeHistory(); // Refresh fee history
  }

  void _editFee(DocumentSnapshot fee) {
    final data = fee.data() as Map<String, dynamic>;

    _feeTypeController.text = data['feeType'];
    _amountController.text = data['amount'].toString();
    _selectedCategory = data['category'];

    setState(() {
      _editingFeeId = fee.id; // Set the ID of the fee being edited
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Manage Fees',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchFees();
              _fetchFeeHistory(); // Refresh both lists
            },
            tooltip: 'Update Existing Fees',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeeInputForm(),
              const SizedBox(height: 16.0),
              _buildFeesList(),
              const SizedBox(height: 16.0),
              _buildFeeHistoryList(), // Display fee history
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeInputForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _feeTypeController,
            decoration: InputDecoration(
              labelText: 'Fee Type',
              labelStyle: const TextStyle(color: Colors.grey),
              floatingLabelStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              labelStyle: const TextStyle(color: Colors.grey),
              floatingLabelStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            ),
          ),
          const SizedBox(height: 16.0),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Select Category',
              labelStyle: const TextStyle(color: Colors.grey),
              floatingLabelStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            ),
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
            isExpanded: true,
          ),
          const SizedBox(height: 24.0),
          _buildFeeActionButton(),
        ],
      ),
    );
  }

  Widget _buildFeeActionButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          ),
          onPressed: _addOrUpdateFee,
          child: Text(
            _editingFeeId == null ? 'Add Fee' : 'Update Fee',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeesList() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fee List (Current)',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8.0), // Space between title and list
          ListView.builder(
            shrinkWrap: true, // Important to make it scrollable
            physics:
                const NeverScrollableScrollPhysics(), // Disable scrolling for this list
            itemCount: _feesList.length,
            itemBuilder: (context, index) {
              final fee = _feesList[index];
              final data = fee.data() as Map<String, dynamic>?;

              String category = (data != null && data.containsKey('category'))
                  ? data['category']
                  : 'N/A';

              return Card(
                color: Colors.grey.shade50,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(data?['feeType'] ?? 'N/A',
                      style: const TextStyle(color: Colors.black87)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: RM${data?['amount'] ?? 0}',
                          style: const TextStyle(color: Colors.black54)),
                      Text('Category: $category',
                          style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black54),
                        onPressed: () => _editFee(fee),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _showDeleteConfirmationDialog(context, fee.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeeHistoryList() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fee List (Deleted)',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8.0), // Space between title and list
          ListView.builder(
            shrinkWrap: true, // Important to make it scrollable
            physics:
                const NeverScrollableScrollPhysics(), // Disable scrolling for this list
            itemCount: _feeHistoryList.length,
            itemBuilder: (context, index) {
              final fee = _feeHistoryList[index];
              final data = fee.data() as Map<String, dynamic>?;

              return Card(
                color: Colors.grey.shade50,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(data?['feeType'] ?? 'N/A',
                      style: const TextStyle(color: Colors.black87)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fee ID: ${data?['feeId'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.black54)),
                      Text('Amount: RM${data?['amount'] ?? 0}',
                          style: const TextStyle(color: Colors.black54)),
                      Text('Category: ${data?['category'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(
                          height: 4.0), // Space before "Deleted Fees"
                      const Text(
                        'Deleted Fees',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 10), // Highlight in red
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String feeId) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.6),
          title: const Text('Confirm Deletion',
              style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to delete this fee?',
              style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Color of the delete button
              ),
              onPressed: () {
                _deleteFee(feeId); // Delete the fee
                Navigator.of(context).pop(); // Close the dialog
              },
              child:
                  const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15.0), // Rounded corners for the dialog
          ),
        );
      },
    );
  }
}
