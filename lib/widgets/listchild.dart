import 'package:flutter/material.dart';

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