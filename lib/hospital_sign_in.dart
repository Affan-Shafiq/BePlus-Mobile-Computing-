import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/hospital_sign_up.dart';
import 'hospital_home_screen.dart';

class HospitalSignInScreen extends StatefulWidget {
  @override
  _HospitalSignInScreenState createState() => _HospitalSignInScreenState();
}

class _HospitalSignInScreenState extends State<HospitalSignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('RegisteredHospitals');

  Future<void> signIn() async {
    final querySnapshot = await _usersCollection
        .where('username', isEqualTo: _usernameController.text)
        .where('password', isEqualTo: _passwordController.text)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final hospitalName = querySnapshot.docs.first['name'];
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-in successful')),
      );

      Navigator.push(context, MaterialPageRoute(builder: (context) => HospitalHomePage(hospitalName: hospitalName)),);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-in failed: Incorrect username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Sign In'),
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
                  foregroundColor: const Color.fromRGBO(144, 50, 60, 1),
                  backgroundColor: const Color.fromRGBO(249, 234, 225, 1),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HospitalSignUpScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromRGBO(249, 234, 225, 1),
                ),
                child: const Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
