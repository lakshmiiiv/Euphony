import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:musicapp/pages/homepage.dart';
import 'package:musicapp/pages/login_page.dart'; // Create this next

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If user is logged in, show Homepage
          if (snapshot.hasData) {
            return const Homepage();
          }
          // If not logged in, show Login page
          else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}