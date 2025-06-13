// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors, deprecated_member_use, use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:pdf/pdf.dart'; // For PdfPageFormat
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../service/database_service.dart';

class ReceiptsPage extends StatelessWidget {
  final String childId;
  final String paymentId;

  ReceiptsPage({required this.childId, required this.paymentId});

  Future<Map<String, dynamic>?> _fetchPaymentIntent() async {
    return await DatabaseService()
        .fetchPaymentIntentForReceipt(childId, paymentId);
  }

  Future<Uint8List> _generatePdf() async {
    final receipt =
        await _fetchPaymentIntent(); // Fetch the specific payment intent
    final pdf = pw.Document();

    if (receipt != null) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Little I.M.A.N Kids',
                    style: pw.TextStyle(
                        fontSize: 30, fontWeight: pw.FontWeight.bold)),
                pw.Text('No 8 Jalan Pelindung Perdana, 26100 Kuantan',
                    style: pw.TextStyle(fontSize: 14)),
                pw.Text('Hp: 019-331 2823', style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 20),
                pw.Text('Nama: ${receipt['name'] ?? 'N/A'}',
                    style: pw.TextStyle(fontSize: 14)),
                pw.Text('Resit No: ${receipt['receiptNo'] ?? 'N/A'}',
                    style: pw.TextStyle(fontSize: 14)),
                pw.Text(
                  'Tarikh: ${receipt['date'] != null ? DateFormat('MMMM d, yyyy').format(receipt['date'].toDate()) : 'No Date Available'}',
                  style: pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Perkara',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                // Here you can add the fee table similar to before
                // Example for fees:
                pw.Table.fromTextArray(
                  context: context,
                  data: <List<String>>[
                    <String>['ITEM', 'RM'],
                    ...((receipt['fees'] as List?)?.map((fee) {
                          return [
                            fee['feeType'] ?? 'No Description',
                            (fee['amount'] != null
                                ? fee['amount'].toString()
                                : '0.00'),
                          ];
                        }) ??
                        []),
                    // Ensure at least 10 rows
                    ...List.generate(
                      (10 - ((receipt['fees'] as List?)?.length ?? 0))
                          .clamp(0, 10),
                      (index) => [' ', ' '],
                    ),
                    <String>[
                      'Total',
                      (receipt['totalAmount'] ?? 0.0).toString(),
                    ],
                  ],
                  cellStyle: pw.TextStyle(fontSize: 14),
                  headerStyle: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ],
            );
          },
        ),
      );
    }

    return await pdf.save(); // Return the PDF as Uint8List
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Receipts')),
      body: FutureBuilder<Uint8List>(
        future: _generatePdf(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No receipts found.'));
          }

          final pdfData = snapshot.data;

          return Column(
            children: [
              Expanded(
                child: PdfPreview(
                  build: (format) => pdfData!,
                  allowPrinting: false,
                  allowSharing: false,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Handle button press to print the PDF
                  try {
                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async => pdfData!,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Printing...')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to print: $e')),
                    );
                  }
                },
                child: const Text('Print Receipt'),
              ),
            ],
          );
        },
      ),
    );
  }
}
