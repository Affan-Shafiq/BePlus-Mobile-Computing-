import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/hospital_sign_in.dart';
import 'main_screen.dart';

class BloodBankSignUpScreen extends StatefulWidget {
  @override
  _BloodBankSignUpScreenState createState() => _BloodBankSignUpScreenState();
}

class _BloodBankSignUpScreenState extends State<BloodBankSignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final CollectionReference _registeredHospitalsCollection = FirebaseFirestore.instance.collection('StoragePoints');
  final CollectionReference _hospitalRequestsCollection = FirebaseFirestore.instance.collection('StoragePointRequests');

  Future<void> signUp() async {
    final usernameQuerySnapshot = await _registeredHospitalsCollection
        .where('username', isEqualTo: _usernameController.text)
        .get();

    if (usernameQuerySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-up failed: Username already exists')),
      );
      return;
    }

    final hospitalNameQuerySnapshot = await _hospitalRequestsCollection
        .where('name', isEqualTo: _hospitalNameController.text)
        .get();

    if (hospitalNameQuerySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-up failed: Hospital name already exists in requests')),
      );
      return;
    }

    await _hospitalRequestsCollection.add({
      'username': _usernameController.text,
      'password': _passwordController.text,
      'name': _hospitalNameController.text,
      'phoneNo': _phoneNoController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request Forwarded to Admin')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Bank Sign Up'),
        backgroundColor: Color.fromRGBO(94, 11, 21, 1),
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
        color: Color.fromRGBO(94, 11, 21, 1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _hospitalNameController,
                decoration: const InputDecoration(
                  labelText: 'Blood Bank Name',
                  labelStyle: TextStyle(color: Color.fromRGBO(249, 234, 225, 1)),
                ),
                style: const TextStyle(color: Color.fromRGBO(249, 234, 225, 1)),
              ),
              TextField(
                controller: _phoneNoController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Color.fromRGBO(249, 234, 225, 1)),
                ),
                style: const TextStyle(color: Color.fromRGBO(249, 234, 225, 1)),
              ),
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
                onPressed: signUp,
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(249, 234, 225, 1),
                  onPrimary: Color.fromRGBO(144, 50, 60, 1),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HospitalSignInScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  primary: Color.fromRGBO(249, 234, 225, 1),
                ),
                child: const Text('Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
