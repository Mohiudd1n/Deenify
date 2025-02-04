import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

class analyticpage extends StatefulWidget {
  const analyticpage({super.key});

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<analyticpage> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليلات', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green[900],
      ),
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
                      ? 'اختر نطاق التاريخ'
                      : '${DateFormat('yyyy-MM-dd').format(_startDate!)} إلى ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.arrow_drop_down, color: Colors.green),
                onTap: _selectDateRange,
              ),
            ),
            const SizedBox(height: 20),

            // Tasbih Analytics
            Expanded(
              child: _buildTasbihAnalytics(),
            ),

            // Namaz Analytics
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
              'لا توجد بيانات Tasbih متاحة',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        }

        final data = snapshot.data!.docs;

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final text = item['text'];
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
                  'العدد: $count',
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
          'الرجاء اختيار نطاق التاريخ',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('namazrecords')
          .where('user', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
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
              'لا توجد بيانات Namaz متاحة',
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

        return Column(
          children: [
            Text(
              'أيام الصلاة: $prayedDays',
              style: const TextStyle(color: Colors.green, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'الأيام الفائتة: $missedDays',
              style: const TextStyle(color: Colors.red, fontSize: 20),
            ),
          ],
        );
      },
    );
  }
}