// ignore_for_file: file_names, use_super_parameters, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

import 'registerchildE.dart';
import 'step_progress.dart';

class RegisterChildDPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> dataA;
  final Map<String, dynamic> dataB;
  final Map<String, dynamic> dataC;

  RegisterChildDPage({
    Key? key,
    required this.docId,
    required this.dataA,
    required this.dataB,
    required this.dataC,
  }) : super(key: key);

  @override
  State<RegisterChildDPage> createState() => _RegisterChildDPageState();
}

class _RegisterChildDPageState extends State<RegisterChildDPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController relationshipController = TextEditingController();

  void _submitData() {
    if (_formKey.currentState?.validate() ?? false) {
      String emergencyName = nameController.text;
      String emergencyTel = telController.text;
      String emergencyRelationship = relationshipController.text;

      Map<String, dynamic> dataD = {
        'nameM': emergencyName,
        'telM': emergencyTel,
        'relationshipM': emergencyRelationship,
      };

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RegisterChildEPage(
                  docId: widget.docId,
                  dataA: widget.dataA,
                  dataB: widget.dataB,
                  dataC: widget.dataC,
                  dataD: dataD)));
    }
  }

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
              currentStep: 3,
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
              "D. Emergency Contact",
              style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20.0),
          _buildTextFormField(
            controller: nameController,
            label: 'Name',
            hintText: 'Enter name',
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter name' : null,
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: telController,
            label: 'Telephone',
            hintText: 'Enter telephone number',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              } else if (!RegExp(r'^01\d{7,9}$').hasMatch(value)) {
                return 'Phone number must start with "01" and be 8 to 11 digits long';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: relationshipController,
            label: 'Relationship',
            hintText: 'Enter relationship',
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter relationship'
                : null,
          ),
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
                  'Next',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
        ),
      ],
    );
  }
}
