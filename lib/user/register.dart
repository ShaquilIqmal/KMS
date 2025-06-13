// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../service/database_service.dart';
import 'dashboard.dart';

class RegAccPage extends StatefulWidget {
  const RegAccPage({Key? key}) : super(key: key);

  @override
  _RegAccPageState createState() => _RegAccPageState();
}

class _RegAccPageState extends State<RegAccPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Registration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _nameController,
                labelText: 'Name (Parent)',
                hintText: 'Enter your name',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your name'
                    : null,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
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
              _buildTextField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your password'
                    : null,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitData,
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
                            Color(0xFFF27121)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      alignment: Alignment.center,
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Colors.grey, // Set the border color to grey
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Colors.grey, // Set the border color to grey
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Colors.grey, // Set the border color to grey
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  void _submitData() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String phone = _phoneController.text.trim();
      final String password = _passwordController.text.trim();
      final String confirmPassword = _confirmPasswordController.text.trim();

      // Password validation
      if (!RegExp(r'^(?=.*[A-Z])(?=.*\d).{5,}$').hasMatch(password)) {
        _showSnackBar(
            'Password must be at least 5 characters long, contain at least one uppercase letter, and one number.');
        return;
      }

      if (password != confirmPassword) {
        _showSnackBar('Passwords do not match.');
        return;
      }

      // Check if email already exists
      bool emailExists = await _databaseService.doesEmailExist(email);
      if (emailExists) {
        _showSnackBar('Email is already used. Please use a different email.');
        return;
      }

      try {
        // Add user to the database
        final DocumentReference docRef = await _databaseService.addUser({
          'name': name,
          'email': email,
          'noTel': phone,
          'password': password,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Prepare the notification
        String adminDocId = 'GENERATED'; // Replace with actual admin ID
        List<String> userIds = [docRef.id]; // List of user IDs to notify

        // Send notification
        await _databaseService.sendNotification(
          adminDocId: adminDocId,
          userIds: userIds,
          title: 'Important Fee Information for New Kindergarten Enrollments!',
          message: 'Dear Parents,\n\n'
              'We are thrilled to welcome you to our kindergarten family! Before you proceed with registering your child, we kindly ask you to take a moment to review the fees associated with enrollment to ensure a smooth and informed registration process.\n\n'
              'Total Registration Fee: RM520\n'
              'This includes the following:\n\n'
              'Yearly Fee: RM150\n'
              'A yearly contribution to support our kindergarten activities and operations.\n\n'
              'Monthly Fee: RM250\n'
              'This fee covers your child\'s monthly attendance and participation in our engaging programs.\n\n'
              'Uniform Fees: RM60\n'
              'This includes two sets of our official uniforms, ensuring your child looks smart and feels comfortable.\n\n'
              'Book Fees (1 Year): RM100\n'
              'This covers all educational materials for one year, including:\n'
              ' - 6 reading books\n'
              ' - 6 writing books\n'
              ' - 6 maths exercise books\n'
              ' - Stationery supplies\n\n'
              'Additionally, there is an Annual Concert Fee of RM100, which helps us organize our yearly concert, a fun event showcasing your child\'s talents!\n\n'
              'Important Reminder:\n'
              'Please ensure you understand these fees before registering your child. We are here to answer any questions you may have. Our goal is to provide a nurturing and supportive environment for your child’s growth and learning.\n\n'
              'Thank you for considering our kindergarten for your child’s educational journey! We look forward to partnering with you in their development.\n\n'
              'Kindly Contact 01119395023 for further information\n\n'
              'Warm regards,\n'
              'Little IMAN Kids',
        );

        // Show success dialog
        _showSuccessDialog(docRef.id);
      } catch (e) {
        _showSnackBar('Failed to register: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccessDialog(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration Successful'),
          content: const Text('You have successfully registered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => DashboardPage(docId: docId),
                  ),
                );
              },
              child: const Text('Go to Dashboard'),
            ),
          ],
        );
      },
    );
  }
}
