import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_screen.dart';

class HospitalHomePage extends StatefulWidget {
  final String hospitalName;

  HospitalHomePage({required this.hospitalName});

  @override
  _HospitalHomePageState createState() => _HospitalHomePageState();
}

class _HospitalHomePageState extends State<HospitalHomePage> {
  String _selectedBloodType = '';
  String _selectedLocation = '';
  final CollectionReference _bloodRequestsCollection = FirebaseFirestore.instance.collection('BloodRequests');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Home'),
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
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(94, 11, 21, 1),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Blood Type:',
                style: TextStyle(fontSize: 20.0, color: Color.fromRGBO(249, 234, 225, 1)),
              ),
              const SizedBox(height: 20.0),
              Wrap(
                spacing: 10.0,
                children: [
                  _buildBloodTypeChip('A+'),
                  _buildBloodTypeChip('A-'),
                  _buildBloodTypeChip('B+'),
                  _buildBloodTypeChip('B-'),
                  _buildBloodTypeChip('O+'),
                  _buildBloodTypeChip('O-'),
                  _buildBloodTypeChip('AB+'),
                  _buildBloodTypeChip('AB-'),
                ],
              ),
              const SizedBox(height: 20.0),
              _selectedBloodType.isNotEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Blood of Type $_selectedBloodType:',
                    style: const TextStyle(fontSize: 20.0, color: Color.fromRGBO(249, 234, 225, 1)),
                  ),
                  const SizedBox(height: 10.0),
                  _buildAvailableBloodChips(_selectedBloodType),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _saveBloodRequest,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(144, 50, 60, 1),
                      backgroundColor: const Color.fromRGBO(249, 234, 225, 1),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    ),
                    child: const Text('Request Blood'),
                  ),
                ],
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBloodTypeChip(String bloodType) {
    return ChoiceChip(
      label: Text(
        bloodType,
        style: TextStyle(
          color: _selectedBloodType == bloodType
              ? const Color.fromRGBO(144, 50, 60, 1)
              : const Color.fromRGBO(249, 234, 225, 1),
        ),
      ),
      selected: _selectedBloodType == bloodType,
      onSelected: (selected) {
        setState(() {
          _selectedBloodType = selected ? bloodType : '';
        });
      },
      selectedColor: const Color.fromRGBO(249, 234, 225, 1),
      backgroundColor: const Color.fromRGBO(144, 50, 60, 1),
    );
  }

  Widget _buildAvailableBloodChips(String bloodType) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('BloodStored').where('bloodType', isEqualTo: bloodType).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Color.fromRGBO(249, 234, 225, 1));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', style: const TextStyle(color: Color.fromRGBO(249, 234, 225, 1)));
        }

        final QuerySnapshot<Map<String, dynamic>>? bloodSnapshot = snapshot.data;

        if (bloodSnapshot == null || bloodSnapshot.docs.isEmpty) {
          return const Text('No data available', style: TextStyle(color: Color.fromRGBO(249, 234, 225, 1)));
        }

        final List<String> allLocations = [];

        bloodSnapshot.docs.forEach((doc) {
          final data = doc.data();
          if (data['storageLocation'] != null) {
            final locations = List<String>.from(data['storageLocation']);
            allLocations.addAll(locations);
          }
        });

        final uniqueLocations = allLocations.toSet().toList();

        return Wrap(
          spacing: 10.0,
          children: uniqueLocations.map((location) {
            return ChoiceChip(
              label: Text(
                location,
                style: TextStyle(
                  color: _selectedLocation == location
                      ? const Color.fromRGBO(144, 50, 60, 1)
                      : const Color.fromRGBO(249, 234, 225, 1),
                ),
              ),
              selected: _selectedLocation == location,
              onSelected: (selected) {
                setState(() {
                  _selectedLocation = selected ? location : '';
                });
              },
              selectedColor: const Color.fromRGBO(249, 234, 225, 1),
              backgroundColor: const Color.fromRGBO(144, 50, 60, 1),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _saveBloodRequest() async {
    if (_selectedBloodType.isNotEmpty && _selectedLocation.isNotEmpty) {
      await _bloodRequestsCollection.add({
        'bloodType': _selectedBloodType,
        'requestedAt': DateTime.now(),
        'storageLocation': _selectedLocation,
        'hospitalName': widget.hospitalName,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blood request submitted successfully', style: TextStyle(color: Color.fromRGBO(249, 234, 225, 1)))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a blood type and location', style: TextStyle(color: Color.fromRGBO(249, 234, 225, 1)))),
      );
    }
  }
}
