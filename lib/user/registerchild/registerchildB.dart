// ignore_for_file: file_names, use_super_parameters, prefer_const_constructors_in_immutables, library_private_types_in_public_api, unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'registerchildC.dart';
import 'step_progress.dart';

class RegisterChildBPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> dataA;

  RegisterChildBPage({Key? key, required this.docId, required this.dataA})
      : super(key: key);

  @override
  _RegisterChildBPageState createState() => _RegisterChildBPageState();
}

class _RegisterChildBPageState extends State<RegisterChildBPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController fatherICController = TextEditingController();
  final TextEditingController fatherAddressController = TextEditingController();
  final TextEditingController fatherHomeTelController = TextEditingController();
  final TextEditingController fatherHandphoneController =
      TextEditingController();
  final TextEditingController fatherEmailController = TextEditingController();
  String? selectedIncomeRange;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docId)
        .get();

    if (userDoc.exists) {
      setState(() {
        fatherNameController.text = userDoc['name'] ?? '';
        fatherHandphoneController.text = userDoc['noTel'] ?? '';
        fatherEmailController.text = userDoc['email'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    fatherNameController.dispose();
    fatherICController.dispose();
    fatherAddressController.dispose();
    fatherHomeTelController.dispose();
    fatherHandphoneController.dispose();
    fatherEmailController.dispose();
    super.dispose();
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
              currentStep: 1,
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
        children: [
          const Center(
            child: Text(
              "B. Guardian's Particulars",
              style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20.0),
          _buildTextFormField(
            controller: fatherNameController,
            label: 'Name (as per IC)',
            hintText: 'Enter name (as per IC)',
            readOnly: true,
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: fatherICController,
            label: 'IC',
            hintText: '000000-00-0000',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return "Please enter your IC number";
              } else if (!RegExp(r'^\d{12}$').hasMatch(value!)) {
                // Check for exactly 12 digits
                return "Ic No. must be exactly 12 digits long and contain only numbers";
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          _buildDropdownFormField(
            value: selectedIncomeRange,
            items: [
              '0-RM2000',
              'RM2000-RM4000',
              'RM4000-RM6000',
              'RM6000-RM8000',
              'RM8000 and above'
            ],
            label: 'Total Monthly Income',
            hintText: 'Select total monthly income',
            validator: (value) => value?.isEmpty ?? true
                ? 'Please select your income range'
                : null,
            onChanged: (value) {
              setState(() {
                selectedIncomeRange = value as String?;
              });
            },
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: fatherAddressController,
            label: 'Home Address',
            hintText: 'Enter home address',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return "Please enter child's address";
              } else if (!RegExp(r'\b\d{5}\b').hasMatch(value!)) {
                // 5 digits anywhere in the text
                return "Address must include a valid postcode (5 digits)";
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: fatherHomeTelController,
            label: 'Tel no (Home)',
            hintText: 'Enter home telephone number (Optional)',
            // validator: (value) => value?.isEmpty ?? true
            // ? 'Please enter your home telephone number'
            //: null,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: fatherHandphoneController,
            label: 'Tel no (Handphone)',
            hintText: 'Enter handphone number',
            readOnly: true,
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: fatherEmailController,
            label: 'Email',
            hintText: 'Enter email',
            readOnly: true,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email';
              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
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

  void _submitData() {
    if (_formKey.currentState?.validate() ?? false) {
      final dataB = {
        'nameF': fatherNameController.text,
        'icF': fatherICController.text,
        'incomeF': selectedIncomeRange ?? '',
        'addressF': fatherAddressController.text,
        'homeTelF': fatherHomeTelController.text,
        'handphoneF': fatherHandphoneController.text,
        'emailF': fatherEmailController.text,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterChildCPage(
            docId: widget.docId,
            dataA: widget.dataA,
            dataB: dataB,
          ),
        ),
      );
    }
  }

  Widget _buildDropdownFormField({
    required String? value,
    required List<String> items,
    required String label,
    required String hintText,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _fieldLabelStyle),
        const SizedBox(height: 8.0),
        DropdownButtonFormField<String>(
          value: value,
          decoration: _inputDecoration(hintText: hintText),
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
      {Widget? suffixIcon, required String hintText}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent)),
      fillColor: Colors.grey.shade100,
      filled: true,
      suffixIcon: suffixIcon,
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 16.0,
      ),
    );
  }

  TextStyle get _fieldLabelStyle => const TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.w600, color: Colors.black87);
}
