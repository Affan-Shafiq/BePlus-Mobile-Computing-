import 'package:flutter/material.dart';
import 'donation_form.dart';
import 'hospital_sign_in.dart';
import 'bloodbank_sign_in.dart';
import 'admin_sign_in.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Be+: We Got You Covered with Blood'),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(context, 'Donate Now', DonationForm()),
              const SizedBox(height: 20),
              _buildButton(context, 'Get Blood', HospitalSignInScreen()),
              const SizedBox(height: 20),
              _buildButton(context, 'Dispatch Blood', BloodBankSignInScreen()),
              const SizedBox(height: 20),
              _buildButton(context, 'Admin Login', AdminSignInScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget destination) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromRGBO(144, 50, 60, 1),
          backgroundColor: const Color.fromRGBO(249, 234, 225, 1),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
