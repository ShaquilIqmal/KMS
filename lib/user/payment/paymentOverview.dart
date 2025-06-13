// ignore_for_file: file_names, prefer_final_fields, use_super_parameters, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../service/database_service.dart';
import '../../service/stripe_service.dart';
import 'paymentReceipt.dart';

class PaymentOverviewPage extends StatefulWidget {
  final String docId;
  final String childId;

  const PaymentOverviewPage({
    Key? key,
    required this.docId,
    required this.childId,
  }) : super(key: key);

  @override
  State<PaymentOverviewPage> createState() => _PaymentOverviewPageState();
}

class _PaymentOverviewPageState extends State<PaymentOverviewPage> {
  String _filter = "Current";
  List<Map<String, dynamic>> _selectedPayments = [];
  List<Map<String, dynamic>> _pastPayments = [];

  Future<double> _fetchTotalDueAmount() async {
    try {
      return await DatabaseService().fetchTotalDueAmount(widget.childId);
    } catch (e) {
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPaymentRecords() async {
    try {
      return await DatabaseService().fetchPaymentRecords(widget.childId);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPastPayments() async {
    try {
      List<Map<String, dynamic>> payments =
          await DatabaseService().fetchPaymentIntents(widget.childId);

      // Sort payments by date, latest first
      payments.sort((a, b) {
        DateTime dateA = a['date'].toDate(); // Assuming 'date' is a Timestamp
        DateTime dateB = b['date'].toDate();
        return dateB.compareTo(dateA); // Latest first
      });

      return payments;
    } catch (e) {
      return [];
    }
  }

  double _calculateSelectedAmount() {
    return _selectedPayments.fold(
        0.0, (total, payment) => total + (payment['amount'] ?? 0.0));
  }

  bool _isPaymentSelected(Map<String, dynamic> payment) {
    return _selectedPayments.any((selected) =>
        selected['description'] == payment['description'] &&
        selected['amount'] == payment['amount'] &&
        selected['dueDate'] == payment['dueDate']);
  }

  void _toggleSelection(Map<String, dynamic> payment) {
    setState(() {
      if (_isPaymentSelected(payment)) {
        _selectedPayments.removeWhere((selected) =>
            selected['description'] == payment['description'] &&
            selected['amount'] == payment['amount'] &&
            selected['dueDate'] == payment['dueDate']);
      } else {
        _selectedPayments.add({
          'id': payment['id'],
          'childId': widget.childId,
          'amount': payment['amount'],
          'feeType': payment['feeType'],
          ...payment,
        });
      }
    });
  }

  Future<void> _handlePayment() async {
    // Check if no payment items are selected
    if (_selectedPayments.isEmpty) {
      // Show Snackbar if no payment item is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8.0),
              Expanded(
                  child:
                      Text('Please select a payment item before proceeding.')),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.black54,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      );

      return; // Exit the function if no items are selected
    }

    // Calculate the payment amount from selected payments
    double paymentAmount = _calculateSelectedAmount();

    // If the calculated amount is greater than 0, proceed with payment
    if (paymentAmount > 0) {
      List<String> selectedFeeTypes = _selectedPayments
          .map((payment) => payment['feeType'] as String? ?? 'N/A')
          .toList()
          .cast<String>();

      try {
        // Call the payment service to make the payment
        await StripeService.instance
            .makePayment(paymentAmount, _selectedPayments, selectedFeeTypes);

        // Clear selected payments after successful payment
        setState(() {
          _selectedPayments.clear();
        });

        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Payment Successful'),
              content: const Text(
                'Your payment has been processed successfully. Thank you!',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Handle payment failure (optional)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8.0),
                Expanded(child: Text('Payment failed. Please try again.')),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        );
      }
    }
  }

  void _navigateToPastPayments() async {
    List<Map<String, dynamic>> pastPayments = await _fetchPastPayments();
    setState(() {
      _pastPayments = pastPayments;
      _filter = "Past";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildDueAmountSection(),
          _buildFilterButtons(),
          Expanded(
            child: _filter == "Past"
                ? _buildPastPaymentsList()
                : _buildCurrentPaymentsList(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Payment Overview',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildDueAmountSection() {
    return FutureBuilder<double>(
      future: _fetchTotalDueAmount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching due amount'));
        } else {
          double dueAmount = snapshot.data ?? 0.0;
          double selectedAmount = _calculateSelectedAmount();

          return Container(
            padding: const EdgeInsets.all(20.0),
            margin:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAmountRow('Due Amount', dueAmount, 18.0, Colors.red),
                const SizedBox(height: 5.0),
                _buildAmountRow(
                    'Selected Amount', selectedAmount, 18.0, Colors.red),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8A2387),
                          Color(0xFFE94057),
                          Color(0xFFF27121),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Pay Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildAmountRow(
      String label, double amount, double fontSize, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            'RM${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: amount == 0.0 ? Colors.grey : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterButton('Current', () {
            setState(() {
              _filter = "Current";
              _pastPayments.clear();
            });
          }),
          _buildFilterButton('Past', _navigateToPastPayments),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _filter == label ? Colors.black87 : Colors.grey[200],
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 28.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        elevation: _filter == label ? 5 : 0,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16.0,
          color: _filter == label ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCurrentPaymentCard(
      Map<String, dynamic> payment, bool isSelected, Function onTap) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 5.0,
      shadowColor: Colors.black.withOpacity(0.3),
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment['feeType'],
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16.0, color: Colors.grey),
                      const SizedBox(width: 4.0),
                      Text(
                        'Due Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(payment['dueDate']))}',
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'RM${(payment['amount'] ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.green : Colors.grey,
                    size: 24.0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPaymentsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchPaymentRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching payment records'));
        } else {
          List<Map<String, dynamic>> paymentRecords = snapshot.data ?? [];
          List<Map<String, dynamic>> filteredPayments =
              paymentRecords.where((payment) {
            return _filter == "Current" && !payment['paid'] ||
                _filter == "Past";
          }).toList();

          if (_filter == "Current") {
            filteredPayments.sort((a, b) {
              DateTime dueDateA = DateTime.parse(a['dueDate']);
              DateTime dueDateB = DateTime.parse(b['dueDate']);
              return dueDateA.compareTo(dueDateB);
            });
            filteredPayments = filteredPayments.reversed.toList();
          }

          return filteredPayments.isEmpty
              ? const Center(child: Text('No payment records found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredPayments.length,
                  itemBuilder: (context, index) {
                    final payment = filteredPayments[index];
                    bool isSelected = _isPaymentSelected(payment);

                    return _buildCurrentPaymentCard(payment, isSelected, () {
                      _toggleSelection(payment);
                    });
                  },
                );
        }
      },
    );
  }

  Widget _buildPastPaymentCard(
      Map<String, dynamic> payment, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 5.0,
      shadowColor: Colors.black.withOpacity(0.3),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'RM${payment['totalAmount'] ?? 0.0}',
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.receipt_long,
                    color: Colors.black,
                  ),
                  tooltip:
                      'View Receipt', // Adds a tooltip for additional context
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiptsPage(
                          childId: widget.childId,
                          paymentId: payment['id_pi'],
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
            const Text(
              'PAID',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 16.0,
              ),
            ),
            if (payment['fees'] != null && payment['fees'] is List)
              ...payment['fees'].map<Widget>((fee) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16.0)),
                      Expanded(
                        child: Text(
                          '${fee['feeType']}: RM${fee['amount']}',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            const SizedBox(height: 8.0),
            Column(
              children: [
                const Text(
                  'Date Issued',
                  style: TextStyle(fontSize: 14.0, color: Colors.black87),
                ),
                Text(
                  ' ${DateFormat('yyyy-MM-dd').format(payment['date'].toDate())} ',
                  style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastPaymentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _pastPayments.length,
      itemBuilder: (context, index) {
        final payment = _pastPayments[index];

        return _buildPastPaymentCard(payment, context);
      },
    );
  }
}
