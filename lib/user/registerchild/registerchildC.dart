// ignore_for_file: file_names, use_super_parameters, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

import 'registerchildD.dart';
import 'step_progress.dart';

class RegisterChildCPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> dataA;
  final Map<String, dynamic> dataB;

  RegisterChildCPage({
    Key? key,
    required this.docId,
    required this.dataA,
    required this.dataB,
  }) : super(key: key);

  @override
  State<RegisterChildCPage> createState() => _RegisterChildCPageState();
}

class _RegisterChildCPageState extends State<RegisterChildCPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController medicalConditionController =
      TextEditingController();
  final TextEditingController doctorTelController = TextEditingController();
  final TextEditingController clinicHospitalController =
      TextEditingController();

  void _submitData() {
    if (_formKey.currentState?.validate() ?? false) {
      String medicalCondition = medicalConditionController.text;
      String doctorTel = doctorTelController.text;
      String clinicHospital = clinicHospitalController.text;

      // Create a Map to hold the data
      Map<String, dynamic> dataC = {
        'medicalCondition': medicalCondition,
        'doctorTel': doctorTel,
        'clinicHospital': clinicHospital,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterChildDPage(
            docId: widget.docId,
            dataA: widget.dataA,
            dataB: widget.dataB,
            dataC: dataC,
          ),
        ),
      );
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
              currentStep: 2,
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
              "C. Medical Data",
              style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20.0),
          _buildTextFormField(
            controller: medicalConditionController,
            label: "Medical Condition",
            hintText: 'Type \'-\' for no Info',
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter medical condition'
                : null,
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: doctorTelController,
            label: "Doctor Tel No",
            hintText: 'Type \'-\' for no Info',
            keyboardType: TextInputType.phone,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter doctor\'s telephone number'
                : null,
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: clinicHospitalController,
            label: "Clinic/Hospital",
            hintText: 'Type \'-\' for no Info',
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter clinic or hospital name'
                : null,
          ),
          const SizedBox(height: 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // Navigate back to the previous section
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
