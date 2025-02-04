import 'package:deenify/pages/tasbihanalytics.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart'; // Add this package
import '../widgets/listchild.dart';

class AnalyticPage extends StatefulWidget {
  const AnalyticPage({super.key});

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticPage> {

  static final ScrollController scrollController = ScrollController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ContainedTabBarView(
        tabs: [
          Text("Namaz Tracker", style: TextStyle(color: Colors.white),),
          Text("Tasbih Tracker", style: TextStyle(color: Colors.white),),
        ],
        views : [Container(
          color: Colors.grey[900],
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Date Range Picker
              Card(
                color: Colors.grey[800],
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.green),
                  title: Text(
                    _startDate == null || _endDate == null
                        ? 'Select Date Range'
                        : '${DateFormat('yyyy-MM-dd').format(_startDate!)} to ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(Icons.arrow_drop_down, color: Colors.green),
                  onTap: _selectDateRange,
                ),
              ),
              const SizedBox(height: 20),
        
              // Tasbih Analytics
              // Expanded(
              //   child: _buildTasbihAnalytics(),
              // ),
        
              // Namaz Analytics
              Expanded(
                child: _buildNamazAnalytics(),
              ),
            ],
          ),
        ),
        tasbihanalytics(),
        ]
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.green, // Primary color for selected range
              onPrimary: Colors.white, // Text color on primary
              surface: Colors.grey, // Background color of the calendar
              onSurface: Colors.white, // Text color on the surface
            ),
            dialogBackgroundColor: Colors.grey[900], // Background color of the dialog
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white), // Text color for input fields
              bodyMedium: TextStyle(color: Colors.white), // Text color for input fields
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.black, // Background color of the input fields
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintStyle: TextStyle(color: Colors.grey[400]), // Hint text color
              labelStyle: TextStyle(color: Colors.white), // Label text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Widget _buildTasbihAnalytics() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('DuaData')
          .where('user', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No Tasbih data available',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        }

        final data = snapshot.data!.docs;

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final text = item['dua'];
            final count = item['count'];

            return Card(
              color: Colors.grey[800],
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                subtitle: Text(
                  'Count: $count',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNamazAnalytics() {
    if (_startDate == null || _endDate == null) {
      return const Center(
        child: Text(
          'Please select a date range',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('namazrecords')
          .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('Date', isGreaterThanOrEqualTo: _startDate)
          .where('Date', isLessThanOrEqualTo: _endDate)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No Namaz data available',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        }

        final data = snapshot.data!.docs;

        int prayedDays = 0;
        int missedDays = 0;

        for (final doc in data) {
          final fajr = doc['Fajr'] as bool;
          final zohar = doc['Zohar'] as bool;
          final asr = doc['Asr'] as bool;
          final maghrib = doc['Maghrib'] as bool;
          final isha = doc['Isha'] as bool;

          if (fajr && zohar && asr && maghrib && isha) {
            prayedDays++;
          } else {
            missedDays++;
          }
        }
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            final doc = snapshot.data!.docs[index];
            final date = DateFormat("dd-MM-yyyy").format((doc["Date"] as Timestamp).toDate());

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTileCard(
                      elevation: 2,
                      initialPadding: EdgeInsets.zero,
                      baseColor: Colors.white,
                      expandedColor: Colors.white,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Listchild(
                            prayerStatus: [
                              doc["Fajr"],
                              doc["Zohar"],
                              doc["Asr"],
                              doc["Maghrib"],
                              doc["Isha"],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
        return Column(
          children: [
            Text(
              'Days Prayed: $prayedDays',
              style: const TextStyle(color: Colors.green, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'Days Missed: $missedDays',
              style: const TextStyle(color: Colors.red, fontSize: 20),
            ),
          ],
        );
      },
    );
  }
}