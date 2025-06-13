// ignore_for_file: avoid_print, avoid_types_as_parameter_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:kms2/service/consts.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<void> makePayment(
      double amount,
      List<Map<String, dynamic>> selectedPayments,
      List<String> selectedFeeTypes) async {
    try {
      var result = await _createPaymentIntent(amount, "myr");
      if (result == null) {
        print("Failed to create payment intent.");
        return;
      }

      String? paymentIntentClientSecret = result["client_secret"];
      String? paymentIntentId = result["payment_intent_id"];

      if (paymentIntentClientSecret == null) {
        print("Failed to create payment intent.");
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Shaquil Iqmal",
        ),
      );

      await _processPayment(selectedPayments, paymentIntentId!,
          selectedFeeTypes); // Assert non-null
    } catch (e) {
      print("Error in makePayment: $e");
    }
  }

  Future<void> _processPayment(List<Map<String, dynamic>> selectedPayments,
      String? paymentIntentId, List<String> selectedFeeTypes) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await _updatePaymentStatus(selectedPayments, paymentIntentId);
      await _createPaymentIntentDocument(selectedPayments, paymentIntentId!,
          selectedFeeTypes); // Assert non-null

      // Track income for the month
      double totalAmount = selectedPayments.fold(
          0, (sum, payment) => sum + (payment['amount'] ?? 0.0));
      await _trackIncome(paymentIntentId, totalAmount); // Assert non-null

      print(
          "Payment successful, status updated, payment intent created, and income tracked.");
    } catch (e) {
      print("Error processing payment: $e");
    }
  }

  Future<void> _updatePaymentStatus(List<Map<String, dynamic>> selectedPayments,
      String? paymentIntentId) async {
    Timestamp currentTimestamp = Timestamp.now();
    for (var payment in selectedPayments) {
      try {
        final paymentRef = FirebaseFirestore.instance
            .collection('child')
            .doc(payment['childId'])
            .collection('payments')
            .doc(payment['id']);

        await paymentRef.update({
          'paid': true,
          'datePaid': currentTimestamp,
          'paymentIntentId': paymentIntentId,
        });

        print(
            "Payment status updated for Payment ID: ${payment['id']} to paid: true");
      } catch (e) {
        print(
            "Error updating payment status for Payment ID: ${payment['id']}. Error: $e");
      }
    }
  }

  Future<Map<String, String>?> _createPaymentIntent(
      double amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency,
      };
      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.data != null) {
        String? clientSecret = response.data["client_secret"];
        String? paymentIntentId = response.data["id"];

        if (clientSecret != null && paymentIntentId != null) {
          return {
            "client_secret": clientSecret,
            "payment_intent_id": paymentIntentId,
          };
        }
      }

      print("No client_secret or payment_intent_id in response.");
      return null;
    } catch (e) {
      print("Error creating payment intent: $e");
      return null;
    }
  }

  Future<void> _createPaymentIntentDocument(
      List<Map<String, dynamic>> selectedPayments,
      String? paymentIntentId,
      List<String> selectedFeeTypes) async {
    try {
      // Assuming childId is available from selectedPayments
      String childId = selectedPayments.first['childId'];

      // Create a reference to the subcollection 'payment_Intent' within the 'child' document
      final paymentIntentRef = FirebaseFirestore.instance
          .collection('child') // Reference to the 'child' collection
          .doc(childId) // Use the specific child ID
          .collection(
              'payment_Intent') // Access the 'payment_Intent' subcollection
          .doc(paymentIntentId); // Document ID for the payment intent

      // Calculate total amount
      double totalAmount = selectedPayments.fold(
          0, (sum, payment) => sum + (payment['amount'] ?? 0.0));

      // Create fee details and payment intent data
      List<Map<String, dynamic>> feeDetails = [];
      for (int j = 0; j < selectedPayments.length; j++) {
        feeDetails.add({
          'paymentId': selectedPayments[j]['id'], // Include the paymentId
          'feeType': selectedFeeTypes[j],
          'amount': selectedPayments[j]['amount'], // Use the specific amount
        });
      }

      // Fetch child's name
      String nameC = await _fetchChildName(childId);

      // Get the new receipt number
      String receiptNo = await _getNewReceiptNo();

      Map<String, dynamic> paymentIntentData = {
        'childId': childId,
        'currency': 'MYR',
        'date': DateTime.now(),
        'status': 'paid',
        'name': nameC,
        'fees': feeDetails, // Store fee details with paymentIds
        'totalAmount': totalAmount, // Save the total amount
        'receiptNo': receiptNo, // Add the receipt number
      };

      await paymentIntentRef.set(paymentIntentData);
      print(
          "Payment intent created with ID: $paymentIntentId for Child ID: $childId with name: $nameC and receipt no: $receiptNo");
    } catch (e) {
      print(
          "Error creating payment intent document for Payment ID: ${selectedPayments.last['id']}. Error: $e");
    }
  }

  Future<void> _initializeReceiptCounter() async {
    final counterRef =
        FirebaseFirestore.instance.collection('counters').doc('receiptCounter');

    // Check if the document already exists
    DocumentSnapshot snapshot = await counterRef.get();
    if (!snapshot.exists) {
      // If it doesn't exist, create it with an initial value
      await counterRef.set({'currentValue': 0});
      print("Initialized receiptCounter with currentValue: 0");
    } else {
      print("receiptCounter already exists.");
    }
  }

  Future<String> _getNewReceiptNo() async {
    // Initialize the counter first
    await _initializeReceiptCounter();

    String newReceiptNo = 'R00000000'; // Default value in case of an error

    try {
      final counterRef = FirebaseFirestore.instance
          .collection('counters')
          .doc('receiptCounter');

      // Run a transaction to increment the counter safely
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(counterRef);
        int newValue = (snapshot['currentValue'] ?? 0) + 1;

        // Update the counter document with the new value
        transaction.set(counterRef, {'currentValue': newValue});

        // Format the receipt number
        newReceiptNo = 'R${newValue.toString().padLeft(8, '0')}';
      });

      return newReceiptNo; // Return the formatted receipt number after transaction
    } catch (e) {
      print("Error getting new receipt number: $e");
      return 'R00000000'; // Return default value if there's an error
    }
  }

  Future<String> _fetchChildName(String childId) async {
    try {
      DocumentSnapshot childDoc = await FirebaseFirestore.instance
          .collection('child')
          .doc(childId)
          .get();

      if (childDoc.exists) {
        var data = childDoc.data() as Map<String, dynamic>;
        return data['SectionA']?['nameC'] ?? 'Unknown';
      } else {
        print("Child document not found for ID: $childId");
        return 'Unknown';
      }
    } catch (e) {
      print("Error fetching child's name for ID: $childId. Error: $e");
      return 'Unknown';
    }
  }

  String _calculateAmount(double amount) {
    final calculatedAmount = (amount * 100).toInt();
    return calculatedAmount.toString();
  }

  Future<void> _trackIncome(String paymentIntentId, double amount) async {
    try {
      // Get the current date and extract month and year
      DateTime now = DateTime.now();
      String month = now.month.toString(); // This will be a string of the month
      String year = now.year.toString(); // This will be the current year

      // Document reference for the month
      final incomeRef = FirebaseFirestore.instance
          .collection('incomePerMonth')
          .doc('$year-$month'); // Document ID as "YYYY-MM"

      // Data to be stored
      Map<String, dynamic> incomeData = {
        'paymentIntentId': paymentIntentId,
        'amount': amount,
        'date': Timestamp.now(),
      };

      // Use a transaction to safely update the document
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get the current document snapshot
        DocumentSnapshot snapshot = await transaction.get(incomeRef);

        if (snapshot.exists) {
          // If document exists, add to the existing array
          List<dynamic> incomes =
              (snapshot.data() as Map<String, dynamic>)['incomeList'] ?? [];
          incomes.add(incomeData);
          transaction.update(incomeRef, {'incomeList': incomes});
        } else {
          // If document does not exist, create it with the first entry
          transaction.set(incomeRef, {
            'incomeList': [incomeData],
          });
        }
      });

      print("Income tracked for Payment Intent ID: $paymentIntentId");
    } catch (e) {
      print("Error tracking income: $e");
    }
  }
}
