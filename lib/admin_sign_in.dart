import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/admin_home_screen.dart';

class AdminSignInScreen extends StatefulWidget {
  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final CollectionReference _adminCollection = FirebaseFirestore.instance.collection('Admin');

  Future<void> signIn() async {
    final querySnapshot = await _adminCollection
        .where('username', isEqualTo: _usernameController.text)
        .where('password', isEqualTo: _passwordController.text)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Show a snackbar for successful sign-in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-in successful')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminHomeScreen()),
      );
    } else {
      // Show a snackbar if sign-in fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-in failed: Incorrect username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Sign In'),
        backgroundColor: const Color.fromRGBO(94, 11, 21, 1),
        titleTextStyle: const TextStyle(
          color: Color.fromRGBO(249, 234, 225, 1),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: Color.fromRGBO(249, 234, 225, 1),
        ),
      ),
      body: Container(
        color: const Color.fromRGBO(94, 11, 21, 1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Color.fromRGBO(249, 234, 225, 1)),
                ),
                style: const TextStyle(color: Color.fromRGBO(249, 234, 225, 1)),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color.fromRGBO(249, 234, 225, 1)),
                ),
                obscureText: true,
                style: const TextStyle(color: Color.fromRGBO(249, 234, 225, 1)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromRGBO(249, 234, 225, 1),
                  onPrimary: const Color.fromRGBO(144, 50, 60, 1),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
