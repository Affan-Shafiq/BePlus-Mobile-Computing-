import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BloodBankHomeScreen extends StatefulWidget {
  final String bloodBankName;

  BloodBankHomeScreen({required this.bloodBankName});

  @override
  _BloodBankHomeScreenState createState() => _BloodBankHomeScreenState();
}

class _BloodBankHomeScreenState extends State<BloodBankHomeScreen> {
  final Map<String, String> _selectedBloodTypes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Bank Home'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Appointments:',
                  style: TextStyle(fontSize: 20.0, color: Color.fromRGBO(249, 234, 225, 1)),
                ),
              ),
              const SizedBox(height: 10.0),
              _buildAppointments(),
              const SizedBox(height: 20.0),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Blood Requests from Hospitals:',
                  style: TextStyle(fontSize: 20.0, color: Color.fromRGBO(249, 234, 225, 1)),
                ),
              ),
              const SizedBox(height: 10.0),
              _buildBloodRequests(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointments() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Appointments').where('collectionPoint', isEqualTo: widget.bloodBankName).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Color.fromRGBO(249, 234, 225, 1));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', style: const TextStyle(color: Color.fromRGBO(249, 234, 225, 1)));
        }

        final QuerySnapshot<Map<String, dynamic>>? appointmentSnapshot = snapshot.data;

        if (appointmentSnapshot == null || appointmentSnapshot.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('No appointments', style: TextStyle(color: Color.fromRGBO(249, 234, 225, 1))),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: appointmentSnapshot.docs.map((doc) {
              final data = doc.data();
              final donorName = data['name'];
              final phoneNumber = data['phoneNo'];
              final cnic = data['cnic'];
              final appointmentTime = data['appointmentTime'];
              final appointmentDate = (data['appointmentDate'] as Timestamp).toDate();
              final formattedDate = '${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}';

              return Card(
                color: Color.fromRGBO(249, 234, 225, 1),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Donor Name: $donorName', style: TextStyle(color: Color.fromRGBO(94, 11, 21, 1))),
                      Text('Phone Number: $phoneNumber', style: TextStyle(color: Color.fromRGBO(94, 11, 21, 1))),
                      Text('CNIC: $cnic', style: TextStyle(color: Color.fromRGBO(94, 11, 21, 1))),
                      Text('Appointment Time: $appointmentTime', style: TextStyle(color: Color.fromRGBO(94, 11, 21, 1))),
                      Text('Appointment Date: $formattedDate', style: TextStyle(color: Color.fromRGBO(94, 11, 21, 1))),
                      const SizedBox(height: 10.0),
                      _buildBloodTypeChips(doc.id),
                      const SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed: () => _collectBlood(doc.id, donorName, phoneNumber, cnic, appointmentDate),
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromRGBO(144, 50, 60, 1),
                          onPrimary: const Color.fromRGBO(249, 234, 225, 1),
                        ),
                        child: const Text('Blood Collected'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildBloodTypeChips(String appointmentId) {
    final List<String> bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    return Wrap(
      spacing: 8.0,
      children: bloodTypes.map((bloodType) {
        return ChoiceChip(
          label: Text(
            bloodType,
            style: TextStyle(
              color: _selectedBloodTypes[appointmentId] == bloodType ? const Color.fromRGBO(144, 50, 60, 1) : const Color.fromRGBO(249, 234, 225, 1),
            ),
          ),
          selected: _selectedBloodTypes[appointmentId] == bloodType,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedBloodTypes[appointmentId] = bloodType;
              } else {
                _selectedBloodTypes.remove(appointmentId);
              }
            });
          },
          selectedColor: const Color.fromRGBO(249, 234, 225, 1),
          backgroundColor: const Color.fromRGBO(144, 50, 60, 1),
        );
      }).toList(),
    );
  }

  Future<void> _collectBlood(String appointmentId, String donorName, String phoneNumber, String cnic, DateTime appointmentDate) async {
    final bloodType = _selectedBloodTypes[appointmentId];
    if (bloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a blood type', style: TextStyle(color: Color.fromRGBO(249, 234, 225, 1)))),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('BloodStored').add({
      'cnic': cnic,
      'bloodType': bloodType,
      'storageLocation': [widget.bloodBankName],
      'storageDate': Timestamp.fromDate(DateTime.now()),
      'appointmentDate': Timestamp.fromDate(appointmentDate),
    });

    await FirebaseFirestore.instance.collection('Appointments').doc(appointmentId).delete();

    setState(() {
      _selectedBloodTypes.remove(appointmentId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Blood collected and stored successfully', style: TextStyle(color: Color.fromRGBO(249, 234, 225, 1)))),
    );
  }

  Widget _buildBloodRequests() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('BloodRequests').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Color.fromRGBO(249, 234, 225, 1));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', style: const TextStyle(color: Color.fromRGBO(249, 234, 225, 1)));
        }

        final QuerySnapshot<Map<String, dynamic>>? bloodRequestSnapshot = snapshot.data;

        if (bloodRequestSnapshot == null || bloodRequestSnapshot.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('No blood requests', style: TextStyle(color: Color.fromRGBO(249, 234, 225, 1))),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: bloodRequestSnapshot.docs.map((doc) {
              final data = doc.data();
              final hospitalName = data['hospitalName'];
              final bloodType = data['bloodType'];
              final storageLocation = data['storageLocation'];

              if (storageLocation != widget.bloodBankName) {
                return const SizedBox.shrink();
              }

              return Card(
                color: const Color.fromRGBO(249, 234, 225, 1),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hospital: $hospitalName', style: const TextStyle(color: Color.fromRGBO(94, 11, 21, 1))),
                      Text('Blood Type: $bloodType', style: const TextStyle(color: Color.fromRGBO(94, 11, 21, 1))),
                      ElevatedButton(
                        onPressed: () => _approveRequest(doc.id, bloodType, hospitalName),
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromRGBO(144, 50, 60, 1),
                          onPrimary: const Color.fromRGBO(249, 234, 225, 1),
                        ),
                        child: const Text('Approve Request'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _approveRequest(String requestId, String bloodType, String hospitalName) async {
    // Retrieve blood information from BloodStored collection
    final bloodQuerySnapshot = await FirebaseFirestore.instance.collection('BloodStored').where('bloodType', isEqualTo: bloodType).limit(1).get();
    final bloodDoc = bloodQuerySnapshot.docs.first;

    // Move blood from BloodStored to BloodInTransit
    await FirebaseFirestore.instance.collection('BloodInTransit').add({
      'hospitalName': hospitalName,
      'bloodType': bloodDoc['bloodType'],
      'storageLocation': bloodDoc['storageLocation'],
      'cnic': bloodDoc['cnic'],
      'storageDate': bloodDoc['storageDate'],
      'collectionPoint': widget.bloodBankName,
    });

    // Delete blood from BloodStored
    await bloodDoc.reference.delete();

    // Delete the blood request from BloodRequests collection
    await FirebaseFirestore.instance.collection('BloodRequests').doc(requestId).delete();
  }
}
