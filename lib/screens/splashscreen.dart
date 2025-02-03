import 'package:flutter/material.dart';
import 'package:typewritertext/typewritertext.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>

    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Initialize animation
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation
    _controller.forward();

    // Navigate to the next screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: SizedBox(
            width: devw * 0.9, // Constrain the width to 90% of the device width
            child: TypeWriter.text(
              'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
              maintainSize: true,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl, // Arabic text for Bismillah
              style: TextStyle(
                fontSize: devw * 0.07,
                fontWeight: FontWeight.bold,
                color: Colors.green, // Islamic vibe color
                fontFamily: 'Amiri', // Use a font that supports Arabic
              ),
              duration: const Duration(milliseconds: 50),
              maxLines: 1, // Ensure text stays in one line
              overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
            ),
          ),
        ),
      ),
    );
  }
}