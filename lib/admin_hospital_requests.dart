import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalRequestsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Requests'),
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
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('HospitalRequests').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color.fromRGBO(249, 234, 225, 1)));
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Color.fromRGBO(249, 234, 225, 1))),
              );
            }

            final QuerySnapshot<Map<String, dynamic>>? requestSnapshot = snapshot.data;

            if (requestSnapshot == null || requestSnapshot.docs.isEmpty) {
              return const Center(
                child: Text('No hospital requests', style: TextStyle(color: Color.fromRGBO(249, 234, 225, 1))),
              );
            }

            return ListView(
              children: requestSnapshot.docs.map((doc) {
                final data = doc.data();
                final hospitalName = data['name'];
                final phoneNo = data['phoneNo'];
                final username = data['username'];
                final password = data['password'];

                return Card(
                  color: Color.fromRGBO(249, 234, 225, 1),
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hospital Name: $hospitalName',
                          style: const TextStyle(color: Color.fromRGBO(144, 50, 60, 1)),
                        ),
                        Text(
                          'Phone No: $phoneNo',
                          style: const TextStyle(color: Color.fromRGBO(144, 50, 60, 1)),
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Color.fromRGBO(249, 234, 225, 1),
                                backgroundColor: const Color.fromRGBO(144, 50, 60, 1),
                              ),
                              onPressed: () => _approveHospital(context, doc.id, username, password, hospitalName, phoneNo),
                              child: const Text('Approve'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Color.fromRGBO(249, 234, 225, 1),
                                backgroundColor: Color.fromRGBO(43, 61, 65, 1),
                              ),
                              onPressed: () => _disapproveHospital(context, doc.id),
                              child: const Text('Disapprove'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Future<void> _approveHospital(BuildContext context, String requestId, String username, String password, String hospitalName, String phoneNo) async {
    await FirebaseFirestore.instance.collection('RegisteredHospitals').add({
      'username': username,
      'password': password,
      'name': hospitalName,
      'phoneNo': phoneNo,
    });

    await FirebaseFirestore.instance.collection('HospitalRequests').doc(requestId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hospital approved and registered successfully')),
    );
  }

  Future<void> _disapproveHospital(BuildContext context, String requestId) async {
    await FirebaseFirestore.instance.collection('HospitalRequests').doc(requestId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hospital request disapproved')),
    );
  }
}
