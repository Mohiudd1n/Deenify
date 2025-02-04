import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class tasbihanalytics extends StatefulWidget {
  const tasbihanalytics({super.key});

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<tasbihanalytics> {
  static final ScrollController scrollController = ScrollController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            Expanded(
              child: _buildNamazAnalytics(),
            ),
          ],
        ),
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
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.grey,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
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
          .collection('DuaData')
          .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('date', isGreaterThanOrEqualTo: _startDate)
          .where('date', isLessThanOrEqualTo: _endDate)
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
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final dua = item['dua'];
            final count = item['count'];
            final date = (item['date'] as Timestamp).toDate();
            final formattedDate = DateFormat('dd-MM-yyyy').format(date);

            return Card(
              color: Colors.grey[800],
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  dua,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Count : $count',
                      style: const TextStyle(color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date : $formattedDate',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}