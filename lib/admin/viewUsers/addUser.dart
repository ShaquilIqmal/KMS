import 'package:flutter/material.dart';

import '../../service/database_service.dart';
import 'viewUser.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController noTelController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add User',
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

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _submitData() async {
    if (_formKey.currentState?.validate() ?? false) {
      String name = nameController.text;
      String email = emailController.text;
      String noTel = noTelController.text;
      String password = passwordController.text;

      try {
        await _databaseService.addUser({
          'name': name,
          'email': email,
          'noTel': noTel,
          'password': password,
        });
        _showSuccessDialog();
      } catch (e) {
        _showSnackbar('Failed to add user: $e');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Colors.black.withOpacity(0.7), // Transparent black background
          title: const Text(
            'User Added',
            style: TextStyle(color: Colors.white), // White text color
          ),
          content: const Text(
            'The user has been successfully added.',
            style: TextStyle(color: Colors.white70), // Light grey text color
          ),
          actions: [
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewUserPage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: nameController,
            labelText: 'Name',
            hintText: 'Name',
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter the user\'s name'
                : null,
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: emailController,
            labelText: 'Email',
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the user\'s email';
              } else if (!value.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: noTelController,
            labelText: 'No Tel',
            hintText: 'No Tel',
            keyboardType: TextInputType.phone,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter the user\'s phone number'
                : null,
          ),
          const SizedBox(height: 16.0),
          _buildTextFormField(
            controller: passwordController,
            labelText: 'Password',
            hintText: 'Password',
            obscureText: true,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter a password'
                : null,
          ),
          const SizedBox(height: 24.0),
          _buildAddUserButton(context),
        ],
      ),
    );
  }

  Widget _buildAddUserButton(BuildContext context) {
    return Container(
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
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        ),
        onPressed: _submitData,
        child: const Text(
          'Add User',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
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
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
          borderSide: const BorderSide(color: Colors.grey), // Border color
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
          borderSide:
              const BorderSide(color: Colors.grey), // Border color on focus
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
