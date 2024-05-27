import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_hospital_requests.dart';
import 'admin_storage_point_requests.dart';
import 'admin_registered_hospitals.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _appointmentsCount = 0;
  int _donorsCount = 0;
  int _collectionPointsCount = 0;
  int _storagePointsCount = 0;
  int _registeredHospitalsCount = 0;
  Map<String, int> _bloodStoredCount = {};
  int _hospitalRequestsCount = 0;
  int _storagePointRequestsCount = 0;
  List<Map<String, dynamic>> _hammadData = [];

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    final appointmentsSnapshot = await FirebaseFirestore.instance.collection('Appointments').get();
    final donorsSnapshot = await FirebaseFirestore.instance.collection('Donors').get();
    final collectionPointsSnapshot = await FirebaseFirestore.instance.collection('CollectionPoints').get();
    final storagePointsSnapshot = await FirebaseFirestore.instance.collection('StoragePoints').get();
    final registeredHospitalsSnapshot = await FirebaseFirestore.instance.collection('RegisteredHospitals').get();
    final hospitalRequestsSnapshot = await FirebaseFirestore.instance.collection('HospitalRequests').get();
    final storagePointRequestsSnapshot = await FirebaseFirestore.instance.collection('StoragePointRequests').get();
    final bloodStoredSnapshot = await FirebaseFirestore.instance.collection('BloodStored').get();
    final hammadSnapshot = await FirebaseFirestore.instance.collection('Hammad').get();

    final Map<String, int> bloodTypeCounts = {};
    for (var doc in bloodStoredSnapshot.docs) {
      final bloodType = doc['bloodType'] as String;
      if (bloodTypeCounts.containsKey(bloodType)) {
        bloodTypeCounts[bloodType] = bloodTypeCounts[bloodType]! + 1;
      } else {
        bloodTypeCounts[bloodType] = 1;
      }
    }

    final List<Map<String, dynamic>> hammadData = hammadSnapshot.docs.map((doc) {
      return {
        'cnic': doc['cnic'],
        'gpa': doc['gpa'],
      };
    }).toList();

    setState(() {
      _appointmentsCount = appointmentsSnapshot.size;
      _donorsCount = donorsSnapshot.size;
      _collectionPointsCount = collectionPointsSnapshot.size;
      _storagePointsCount = storagePointsSnapshot.size;
      _registeredHospitalsCount = registeredHospitalsSnapshot.size;
      _hospitalRequestsCount = hospitalRequestsSnapshot.size;
      _storagePointRequestsCount = storagePointRequestsSnapshot.size;
      _bloodStoredCount = bloodTypeCounts;
      _hammadData = hammadData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
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
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard('Appointments', _appointmentsCount.toString()),
              _buildSummaryCard('Donors', _donorsCount.toString()),
              _buildSummaryCard('Collection Points', _collectionPointsCount.toString()),
              _buildSummaryCard('Storage Points', _storagePointsCount.toString()),
              _buildInteractiveSummaryCard('Registered Hospitals', _registeredHospitalsCount.toString(), RegisteredHospitalPage()),
              _buildInteractiveSummaryCard('Hospital Requests', _hospitalRequestsCount.toString(), HospitalRequestsPage()),
              _buildInteractiveSummaryCard('Storage Point Requests', _storagePointRequestsCount.toString(), StoragePointRequestsPage()),
              _buildBloodStoredCard(),
              _buildHammadCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count) {
    return Card(
      color: const Color.fromRGBO(249, 234, 225, 1),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Color.fromRGBO(144, 50, 60, 1)),
        ),
        trailing: Text(
          count,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(144, 50, 60, 1),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveSummaryCard(String title, String count, Widget destinationPage) {
    return Card(
      color: const Color.fromRGBO(249, 234, 225, 1),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Color.fromRGBO(144, 50, 60, 1)),
        ),
        trailing: Text(
          count,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(144, 50, 60, 1),
          ),
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
          _fetchCounts();
        },
      ),
    );
  }

  Widget _buildBloodStoredCard() {
    return Card(
      color: const Color.fromRGBO(249, 234, 225, 1),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: const Text(
          'Blood Stored',
          style: TextStyle(color: Color.fromRGBO(144, 50, 60, 1)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _bloodStoredCount.entries.map((entry) {
            return Text(
              '${entry.key} : ${entry.value}',
              style: const TextStyle(color: Color.fromRGBO(144, 50, 60, 1)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHammadCard() {
    return Card(
      color: const Color.fromRGBO(249, 234, 225, 1),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: _hammadData.map((data) {
          return ListTile(
            title: Text(
              'CNIC: ${data['cnic']}',
              style: const TextStyle(color: Color.fromRGBO(144, 50, 60, 1)),
            ),
            subtitle: Text(
              'GPA: ${data['gpa']}',
              style: const TextStyle(color: Color.fromRGBO(144, 50, 60, 1)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
