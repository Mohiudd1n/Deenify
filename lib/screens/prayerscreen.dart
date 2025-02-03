import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class prayerscreen extends StatelessWidget {
  const prayerscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const CalendarButtonScreen(),
    );
  }
}

class CalendarButtonScreen extends StatefulWidget {
  const CalendarButtonScreen({super.key});

  @override
  _CalendarButtonScreenState createState() => _CalendarButtonScreenState();
}

class _CalendarButtonScreenState extends State<CalendarButtonScreen> {
  DateTime? _selectedDate;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  late List<String> _buttonLabels = List.generate(5, (index) => 'Slide to confirm ${_Namazname(index)}');
  final List<bool> _buttonStates = List.generate(5, (index) => false); // Track button states

  void _doSomething() async {
    Timer(Duration(seconds: 3), () {
      _btnController.success();
    });
  }

  String _Namazname(int index){
    const prayername = ["Fajr","Zohar","Asr","Maghrib","Isha"];

    return prayername[index];
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onSubmit() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    // Submit logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}\nButtons: $_buttonLabels'),
      ),
    );
  }

  void _onSlideComplete(int index) {
    setState(() {
      _buttonStates[index] = true; // Mark the button as slid
    });
  }

  void _resetButtonState(int index) {
    setState(() {
      _buttonStates[index] = false; // Reset the button state
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayers'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date Picker Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons Section
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Card(
                            color: Colors.transparent,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8), // Add margin between cards
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buttonStates[index]
                                  ? InkWell(
                                onTap: () => _resetButtonState(index), // Reset on tap
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade400, // Dark theme color for completed state
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Completed ${_Namazname(index)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                                  : SlideAction(
                                text: _buttonLabels[index],
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                outerColor: Colors.red.shade300, // Dark theme color
                                innerColor: Colors.white,
                                sliderButtonIcon: const Icon(Icons.arrow_forward, color: Colors.black),
                                onSubmit: () {
                                  _onSlideComplete(index);
                                  // Call the slide completion function
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            RoundedLoadingButton(
              child: Text('Submit!', style: TextStyle(color: Colors.white)),
              controller: _btnController,
              onPressed: _doSomething,
            ),
          ],
        ),
      ),
    );
  }
}