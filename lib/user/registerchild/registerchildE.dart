// ignore_for_file: use_build_context_synchronously, file_names, use_super_parameters, prefer_const_constructors_in_immutables, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../dashboard.dart';
import 'step_progress.dart';

class RegisterChildEPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> dataA;
  final Map<String, dynamic> dataB;
  final Map<String, dynamic> dataC;
  final Map<String, dynamic> dataD;

  RegisterChildEPage({
    Key? key,
    required this.docId,
    required this.dataA,
    required this.dataB,
    required this.dataC,
    required this.dataD,
  }) : super(key: key);

  @override
  State<RegisterChildEPage> createState() => _RegisterChildEPageState();
}

class _RegisterChildEPageState extends State<RegisterChildEPage> {
  final _formKey = GlobalKey<FormState>();
  String? transportation;
  final TextEditingController pickupAddressController = TextEditingController();
  final TextEditingController dropAddressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Child Registration",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.grey[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomStepIndicator(
              currentStep: 4,
              stepLabels: const [
                'Child Info',
                'Guardian',
                'Medical',
                'Emergency',
                'Transport'
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(child: _buildFormContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: <Widget>[
          const Center(
            child: Text(
              "E. Transportation",
              style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20.0),
          _buildTransportationSelection(
            groupValue: transportation,
            onChanged: (value) {
              setState(() {
                transportation = value;
              });
            },
          ),
          if (transportation == 'school') ...[
            const SizedBox(height: 16.0),
            _buildTextFormField(
              controller: pickupAddressController,
              labelText: 'Pickup Address (Feature not yet implemented)',
              hintText: 'Enter pickup address',
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter pickup address'
                  : null,
              enabled: transportation !=
                  'school', // Disable the field when transportation is 'school'
            ),
            const SizedBox(height: 16.0),
            _buildTextFormField(
              controller: dropAddressController,
              labelText: 'Drop Address (Feature not yet implemented)',
              hintText: 'Enter drop address',
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter drop address'
                  : null,
              enabled: transportation !=
                  'school', // Disable the field when transportation is 'school'
            ),
          ],
          const SizedBox(height: 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0),
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  shadowColor: Colors.black.withOpacity(0.2),
                  elevation: 4,
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: _submitData,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  shadowColor: Colors.black.withOpacity(0.2),
                  elevation: 4,
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black38),
          ),
          enabled: enabled,
        ),
      ],
    );
  }

  Widget _buildTransportationSelection({
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transportation',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        RadioListTile<String>(
          title: const Text('Own'),
          value: 'own',
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        RadioListTile<String>(
          title: const Text("School's"),
          value: 'school',
          groupValue: groupValue,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _submitData() async {
    if (_formKey.currentState?.validate() ?? false) {
      String? pickupAddress;
      String? dropAddress;
      if (transportation == 'own') {
        pickupAddress = null;
        dropAddress = null;
      } else if (transportation == 'school') {
        pickupAddress = pickupAddressController.text;
        dropAddress = dropAddressController.text;
      }

      Map<String, dynamic> dataE = {
        'transportation': transportation,
        'pickupAddress': pickupAddress,
        'dropAddress': dropAddress,
      };

      Map<String, dynamic> childData = {
        'SectionA': widget.dataA,
        'SectionB': widget.dataB,
        'SectionC': widget.dataC,
        'SectionD': widget.dataD,
        'SectionE': dataE,
        'status': 'pending',
        'userId': widget.docId
      };

      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        DocumentReference pendingRef =
            firestore.collection('pending_approvals').doc();

        await pendingRef.set(childData);

        print('Child data successfully submitted for approval');

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Pending'),
            content: const Text(
                'Your child registration is pending. Please wait for the admin to approve the registration.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(docId: widget.docId),
          ),
        );
      } catch (e) {
        print('Failed to submit child data for approval: $e');
      }
    }
  }
}
