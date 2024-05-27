import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:untitled/main_screen.dart';

class DonationForm extends StatefulWidget {
  @override
  _DonationFormState createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _cnicController = TextEditingController();
  String _selectedTime = '';
  String _selectedLocation = '';
  List<String> _availableTimes = [];
  DateTime _selectedDay = DateTime.now();
  List<DocumentSnapshot> _availableLocations = [];

  @override
  void initState() {
    super.initState();
    _fetchCollectionPoints();
  }

  void _fetchCollectionPoints() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('CollectionPoints').get();
      setState(() {
        _availableLocations = snapshot.docs;
      });
    } catch (e) {
      print('Error fetching collection points: $e');
    }
  }

  void _fetchAvailableSlots(DocumentSnapshot location) {
    List<dynamic> timeList = location['time'];
    setState(() {
      _availableTimes.clear();
      _availableTimes.addAll(timeList.map((e) => e.toString()));
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _checkAndSaveData();
    }
  }

  void _checkAndSaveData() async {
    final cnic = _cnicController.text;
    final donorSnapshot = await FirebaseFirestore.instance.collection('Donors').where('cnic', isEqualTo: cnic).get();

    if (donorSnapshot.docs.isNotEmpty) {
      final donorDoc = donorSnapshot.docs.first;
      await donorDoc.reference.update({
        'name': _nameController.text,
        'phoneNo': _phoneNumberController.text,
      });

      await FirebaseFirestore.instance.collection('Appointments').add({
        'name': _nameController.text,
        'phoneNo': _phoneNumberController.text,
        'cnic': _cnicController.text,
        'appointmentTime': _selectedTime,
        'appointmentDate': _selectedDay,
        'collectionPoint': _selectedLocation,
      });
    } else {
      await FirebaseFirestore.instance.collection('Donors').add({
        'name': _nameController.text,
        'phoneNo': _phoneNumberController.text,
        'cnic': _cnicController.text,
      });

      await FirebaseFirestore.instance.collection('Appointments').add({
        'name': _nameController.text,
        'phoneNo': _phoneNumberController.text,
        'cnic': _cnicController.text,
        'appointmentTime': _selectedTime,
        'appointmentDate': _selectedDay,
        'collectionPoint': _selectedLocation,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment booked successfully!'),
      ),
    );
    Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Form'),
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
      backgroundColor: const Color.fromRGBO(94, 11, 21, 1),
      body: Container(
        color: const Color.fromRGBO(94, 11, 21, 1),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _availableLocations.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Color.fromRGBO(249, 234, 225, 1)),
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: Color.fromRGBO(249, 234, 225, 1)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _phoneNumberController,
                          style: const TextStyle(color: Color.fromRGBO(249, 234, 225, 1)),
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(color: Color.fromRGBO(249, 234, 225, 1)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _cnicController,
                          style: const TextStyle(color: Color.fromRGBO(249, 234, 225, 1)),
                          decoration: const InputDecoration(
                            labelText: 'CNIC',
                            labelStyle: TextStyle(color: Color.fromRGBO(249, 234, 225, 1)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your CNIC';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Select Location:',
                          style: TextStyle(fontSize: 16, color: Color.fromRGBO(249, 234, 225, 1)),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: _availableLocations.map((location) {
                            final data = location.data() as Map<String, dynamic>;
                            return ChoiceChip(
                              label: Text(data['name']),
                              backgroundColor: const Color.fromRGBO(144, 50, 60, 1),
                              selected: _selectedLocation == location['name'],
                              selectedColor: const Color.fromRGBO(249, 234, 225, 1),
                              labelStyle: TextStyle(
                                color: _selectedLocation == location['name']
                                    ? const Color.fromRGBO(144, 50, 60, 1)
                                    : const Color.fromRGBO(249, 234, 225, 1),
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedLocation = selected ? location['name'] : '';
                                  if (selected) {
                                    _fetchAvailableSlots(location);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        if (_selectedLocation.isNotEmpty) ...[
                          const Text(
                            'Select Time:',
                            style: TextStyle(fontSize: 16, color: Color.fromRGBO(249, 234, 225, 1)),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            children: _availableTimes.map((time) {
                              return ChoiceChip(
                                label: Text(time),
                                backgroundColor: const Color.fromRGBO(144, 50, 60, 1),
                                selected: _selectedTime == time,
                                selectedColor: const Color.fromRGBO(249, 234, 225, 1),
                                labelStyle: TextStyle(
                                  color: _selectedTime == time
                                      ? const Color.fromRGBO(144, 50, 60, 1)
                                      : const Color.fromRGBO(249, 234, 225, 1),
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedTime = selected ? time : '';
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Select Date:',
                            style: TextStyle(fontSize: 16, color: Color.fromRGBO(249, 234, 225, 1)),
                          ),
                          const SizedBox(height: 10),
                          TableCalendar(
                            focusedDay: _selectedDay,
                            firstDay: DateTime.now(),
                            lastDay: DateTime.now().add(const Duration(days: 365)),
                            calendarFormat: CalendarFormat.month,
                            headerStyle: const HeaderStyle(
                              titleTextStyle: TextStyle(
                                color: Color.fromRGBO(249, 234, 225, 1),
                              ),
                              formatButtonVisible: false,
                              leftChevronIcon: Icon(
                                Icons.chevron_left,
                                color: Color.fromRGBO(249, 234, 225, 1),
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right,
                                color: Color.fromRGBO(249, 234, 225, 1),
                              ),
                            ),
                            daysOfWeekStyle: const DaysOfWeekStyle(
                              weekdayStyle: TextStyle(
                                color: Color.fromRGBO(249, 234, 225, 1),
                              ),
                              weekendStyle: TextStyle(
                                color: Color.fromRGBO(249, 234, 225, 1),
                              ),
                            ),
                            calendarStyle: const CalendarStyle(
                              defaultTextStyle: TextStyle(
                                color: Color.fromRGBO(249, 234, 225, 1),
                              ),
                              selectedTextStyle: TextStyle(
                                color: Color.fromRGBO(143, 61, 65, 1),
                              ),
                              todayTextStyle: TextStyle(
                                color: Color.fromRGBO(43, 61, 65, 1),
                              ),
                              outsideTextStyle: TextStyle(
                                color: Color.fromRGBO(43, 61, 65, 1),
                              ),
                              outsideDaysVisible: true,
                              selectedDecoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(249, 234, 225, 1),
                              ),
                            ),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                primary: const Color.fromRGBO(249, 234, 225, 1),
                                onPrimary: const Color.fromRGBO(144, 50, 60, 1),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text('Submit'),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
