// ignore_for_file: file_names, use_super_parameters

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'registerchildB.dart';
import 'step_progress.dart';

class RegisterChildPage extends StatefulWidget {
  final String docId;

  const RegisterChildPage({Key? key, required this.docId}) : super(key: key);

  @override
  State<RegisterChildPage> createState() => _RegisterChildPageState();
}

class _RegisterChildPageState extends State<RegisterChildPage> {
  String? childGender;
  DateTime? selectedDate;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController childAddressController = TextEditingController();
  final TextEditingController childDateOfBirthController =
      TextEditingController();
  final TextEditingController childAgeController = TextEditingController();
  final TextEditingController childMyKidController = TextEditingController();
  final TextEditingController childReligionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Child Registration",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomStepIndicator(
              currentStep: 0,
              stepLabels: const [
                'Child Info',
                'Guardian',
                'Medical',
                'Emergency',
                'Transport',
              ],
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 24.0),
                  children: [
                    const Center(
                      child: Text(
                        "A. Child's Particular",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    _buildTextField(
                      controller: childNameController,
                      label: 'Full Name (Child)',
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16.0),
                    _buildGenderSelection(),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                      controller: childAddressController,
                      label: 'Address',
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
                    _buildDateOfBirthAndAgeRow(),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                      controller: childMyKidController,
                      label: 'myKid No.',
                      keyboardType:
                          TextInputType.number, // Set keyboard type to number
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return "Please enter child's myKid number";
                        } else if (!RegExp(r'^\d{12}$').hasMatch(value!)) {
                          // Check for exactly 12 digits
                          return "myKid No. must be exactly 12 digits long and contain only numbers";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                      controller: childReligionController,
                      label: 'Religion',
                      validator: (value) => value?.isEmpty ?? true
                          ? "Please enter child's religion"
                          : null,
                    ),
                    const SizedBox(height: 30.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.black54)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
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
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: Colors.black38),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Male'),
                value: 'Male',
                groupValue: childGender,
                onChanged: (value) => setState(() => childGender = value),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Female'),
                value: 'Female',
                groupValue: childGender,
                onChanged: (value) => setState(() => childGender = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateOfBirthAndAgeRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date of Birth', style: _fieldLabelStyle),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: childDateOfBirthController,
                readOnly: true,
                decoration: _inputDecoration(
                    suffixIcon:
                        const Icon(Icons.calendar_today, color: Colors.grey)),
                onTap: _selectDate,
                validator: (value) => value?.isEmpty ?? true
                    ? "Please select child's date of birth"
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Age', style: _fieldLabelStyle),
              const SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 14.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  childAgeController.text.isNotEmpty
                      ? childAgeController.text
                      : 'Age',
                  style: const TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _selectDate() async {
    DateTime now = DateTime.now();
    DateTime initialDate = now.subtract(const Duration(days: 365 * 5));
    DateTime firstDate = now.subtract(const Duration(days: 365 * 7));
    DateTime lastDate = now.subtract(const Duration(days: (365 * 4) + 1));

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        childDateOfBirthController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
        _calculateAge(pickedDate);
      });
    }
  }

  void _calculateAge(DateTime birthDate) {
    int age = DateTime.now().year - birthDate.year;
    if (DateTime.now().month < birthDate.month ||
        (DateTime.now().month == birthDate.month &&
            DateTime.now().day < birthDate.day)) {
      age--;
    }
    childAgeController.text = age.toString();
  }

  void _submitData() {
    if (_formKey.currentState?.validate() ?? false) {
      Map<String, dynamic> dataA = {
        'nameC': childNameController.text,
        'genderC': childGender,
        'addressC': childAddressController.text,
        'dateOfBirthC': childDateOfBirthController.text,
        'yearID': 'Year ${childAgeController.text}',
        'myKidC': childMyKidController.text,
        'religionC': childReligionController.text,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RegisterChildBPage(docId: widget.docId, dataA: dataA),
        ),
      );
    }
  }

  TextStyle get _fieldLabelStyle => const TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.w600, color: Colors.black87);

  InputDecoration _inputDecoration({Widget? suffixIcon}) => InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent)),
        fillColor: Colors.grey.shade100,
        filled: true,
        suffixIcon: suffixIcon,
      );
}
