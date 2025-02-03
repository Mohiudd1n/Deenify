import 'package:flutter/material.dart';

class Listchild extends StatelessWidget {
  final List<bool> prayerStatus;

  const Listchild({super.key, required this.prayerStatus});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPrayerStatusItem("Fajr", prayerStatus[0]),
        _buildPrayerStatusItem("Zohar", prayerStatus[1]),
        _buildPrayerStatusItem("Asr", prayerStatus[2]),
        _buildPrayerStatusItem("Maghrib", prayerStatus[3]),
        _buildPrayerStatusItem("Isha", prayerStatus[4]),
      ],
    );
  }

  Widget _buildPrayerStatusItem(String prayerName, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green[900] : Colors.red[900],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prayerName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Icon(
            isCompleted ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}