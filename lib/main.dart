import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:kms2/service/consts.dart';

import 'splashscreen.dart'; // Import the new splash screen

void main() async {
  await _setup();
  //WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  //Stripe.publishableKey =
  //    "pk_test_51QT4wWGGUyr9vbxpX51SAjC622do0jHv6LIFYO5Of2UoWjMd1CbbhdW8jN4EmSGeQCw3eYrUZEVQOwxMKwJxLvCV00Uv7gkHId"; // Replace with your actual key
  runApp(const MyApp());
}

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripePublishableKey;

  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kindergarten Flash Page',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Set the splash screen as the home page
    );
  }
}
