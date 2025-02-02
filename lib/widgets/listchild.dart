import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class Listchild extends StatelessWidget {
  const Listchild({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.grey[300],
      child: const Center(child: Text('List Child Content')),
    );
  }
}