import 'package:flutter/material.dart';

import '../../service/database_service.dart';
import 'viewTeacher.dart';

class AddTeacherPage extends StatefulWidget {
  const AddTeacherPage({Key? key}) : super(key: key);

  @override
  _AddTeacherPageState createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State<AddTeacherPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController homeAddressController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController joiningDateController = TextEditingController();
  final TextEditingController employmentStatusController =
      TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final DatabaseService _databaseService = DatabaseService();

  // List to hold selected classes
  List<String> selectedClasses = [];

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _submitData() async {
    if (selectedClasses.length != 3) {
      _showSnackbar('Please select all classes: Year 4, Year 5, Year 6.');
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _databaseService.addTeacher({
          'name': nameController.text,
          'dateOfBirth': dateOfBirthController.text,
          'gender': genderController.text,
          'contactInfo': {
            'phoneNumber': phoneNumberController.text,
            'email': emailController.text,
            'homeAddress': homeAddressController.text,
          },
          'employmentInfo': {
            'position': positionController.text,
            'joiningDate': joiningDateController.text,
            'employmentStatus': employmentStatusController.text,
            'salary': salaryController.text,
          },
          'assignedClasses': selectedClasses, // Include selected classes
          'password': passwordController.text,
          'isTeacher': true,
        });

        _showSuccessDialog();
      } catch (e) {
        _showSnackbar('Failed to add teacher: $e');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Teacher Added'),
          content: const Text('The teacher has been successfully added.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const ViewTeacherPage()), // navigate to view page
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add Teacher',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildFormContent(),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildTextFormField(
            controller: nameController,
            labelText: 'Name',
            hintText: 'Name',
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter the position'
                : null,
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: dateOfBirthController,
            labelText: 'Date of Birth',
            hintText: 'YYYY-MM-DD',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the joining date';
              }
              if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                return 'Joining Date must be in YYYY-MM-DD format';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Gender',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[800])),
              Row(
                children: <Widget>[
                  Radio<String>(
                    value: 'Male',
                    groupValue: genderController.text,
                    onChanged: (value) {
                      setState(() {
                        genderController.text = value!;
                      });
                    },
                  ),
                  const Text('Male', style: TextStyle(color: Colors.grey)),
                  Radio<String>(
                    value: 'Female',
                    groupValue: genderController.text,
                    onChanged: (value) {
                      setState(() {
                        genderController.text = value!;
                      });
                    },
                  ),
                  const Text('Female', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: phoneNumberController,
            labelText: 'Phone Number',
            hintText: 'Phone Number',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the phone number';
              }
              if (!RegExp(r'^\d{8,12}$').hasMatch(value)) {
                return 'Phone number must be 8-12 digits long and contain only numbers';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: emailController,
            labelText: 'Email',
            hintText: 'Email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: homeAddressController,
            labelText: 'Home Address',
            hintText: 'Home Address',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the home address';
              }
              if (!RegExp(r'\b\d{5}\b').hasMatch(value)) {
                return 'Address must include a valid postcode (5 digits)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: positionController,
            labelText: 'Position',
            hintText: 'Position',
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter the position'
                : null,
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: joiningDateController,
            labelText: 'Joining Date',
            hintText: 'YYYY-MM-DD',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the joining date';
              }
              if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                return 'Joining Date must be in YYYY-MM-DD format';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: employmentStatusController,
            labelText: 'Employment Status',
            hintText: 'Employment Status',
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter the employment status'
                : null,
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: salaryController,
            labelText: 'Salary',
            hintText: 'Salary',
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter the salary'
                : null,
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: passwordController,
            labelText: 'Password',
            hintText: 'Password',
            obscureText: true,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter the password'
                : null,
          ),
          const SizedBox(height: 16.0),
          // Checkbox for Assign Classes
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text('Assign Classes',
                style: TextStyle(fontSize: 16.0, color: Colors.grey[800])),
          ),
          _buildCheckboxListTile('Year 4'),
          _buildCheckboxListTile('Year 5'),
          _buildCheckboxListTile('Year 6'),
          const SizedBox(height: 16.0),
          _buildGradientButton('Add Teacher', _submitData),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(color: Colors.grey.shade900),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildCheckboxListTile(String className) {
    return CheckboxListTile(
      title: Text(
        className,
        style: TextStyle(color: Colors.grey.shade900),
      ),
      value: selectedClasses.contains(className),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            selectedClasses.add(className);
          } else {
            selectedClasses.remove(className);
          }
        });
      },
      checkColor: Colors.white,
      activeColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
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
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          ),
          onPressed: onPressed,
          child: Text(
            text,
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
}
