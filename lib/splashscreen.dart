import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin/adminDashboard.dart'; // Import for admin dashboard
import 'login.dart'; // Import for login page
import 'teacher/teacherDashboard.dart'; // Import for teacher dashboard
import 'user/dashboard.dart'; // Import for user dashboard

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _checkSession();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _visible = true;
      });
    });
  }

  Future<void> _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? role = prefs.getString('role');

    // Debugging: print session data
    print('Checking session. User ID: $userId, Role: $role');

    // Check if session exists and navigate accordingly
    if (userId != null) {
      if (role == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => AdminDashboardPage(docId: userId)),
        );
      } else if (role == 'teacher') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => TeacherDashboardPage(docId: userId)),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DashboardPage(docId: userId)),
        );
      }
    } else {
      // No session, go to login
      Timer(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(seconds: 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Image.asset(
                  'assets/logooo.png', // Replace with your logo
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(
                  0, _visible ? 0 : 50, 0), // Slide-up effect
              child: Text(
                'Little I.M.A.N Kids',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(
                  0, _visible ? 0 : 50, 0), // Slide-up effect
              child: const Text(
                'Kindergarten Portal for Parents',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
