// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin/adminDashboard.dart';
import 'service/database_service.dart';
import 'teacher/teacherDashboard.dart';
import 'user/dashboard.dart';
import 'user/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  Future<void> _login(BuildContext context) async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter both username and password.');
      return;
    }

    try {
      final Map<String, dynamic>? userInfo = await _getUserInfo(email);
      if (userInfo != null) {
        if (userInfo['password'] == password) {
          await _storeSessionData(userInfo['id'], userInfo['role']);
          _navigateToDashboard(userInfo);
        } else {
          _showSnackBar('Incorrect password. Please try again.');
        }
      } else {
        _showSnackBar('Username not found. Please try again.');
      }
    } catch (e) {
      _showSnackBar('Failed to sign in: $e');
    }
  }

  Future<Map<String, dynamic>?> _getUserInfo(String email) async {
    final List<String> collections = ['users', 'teachers', 'admins'];

    for (String collection in collections) {
      final QuerySnapshot querySnapshot =
          await _databaseService.getUserByEmail(email, collection: collection);

      if (querySnapshot.docs.isNotEmpty) {
        final DocumentSnapshot doc = querySnapshot.docs.first;
        return {
          'id': doc.id,
          'role': collection.substring(0, collection.length - 1),
          // Extract role: "users" -> "user"
          'password': (doc.data() as Map<String, dynamic>)['password'],
        };
      }
    }
    return null;
  }

  Future<void> _storeSessionData(String userId, String role) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('role', role);
  }

  void _navigateToDashboard(Map<String, dynamic> userInfo) {
    final String role = userInfo['role'];
    final String docId = userInfo['id'];

    Widget dashboard;
    switch (role) {
      case 'user':
        dashboard = DashboardPage(docId: docId);
        break;
      case 'teacher':
        dashboard = TeacherDashboardPage(docId: docId);
        break;
      case 'admin':
        dashboard = AdminDashboardPage(docId: docId);
        break;
      default:
        throw Exception('Unknown role: $role');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50.0),
              _buildHeader(),
              const SizedBox(height: 32.0),
              _buildLoginForm(),
              const SizedBox(height: 32.0),
              _buildLoginButton(),
              _buildCreateAccountLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Image.asset('assets/logooo.png', width: 200.0, height: 200.0),
          const SizedBox(height: 16.0),
          const Text(
            'Little I.M.A.N Kids',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFormField(
          controller: emailController,
          labelText: 'Email',
        ),
        const SizedBox(height: 16.0),
        _buildTextFormField(
          controller: passwordController,
          labelText: 'Password',
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
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
          onPressed: () => _login(context),
          child: const Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccountLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegAccPage()),
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          backgroundColor: Colors.transparent,
        ),
        child: const Text(
          'Create a new account',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
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
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        hintText: labelText,
        hintStyle: const TextStyle(color: Colors.grey),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      obscureText: obscureText,
    );
  }
}
