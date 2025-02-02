import 'package:deenify/screens/prayerscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_scrolling_fab_animated/flutter_scrolling_fab_animated.dart';
import '../widgets/listchild.dart'; // Adjust the import path as needed

class homepage extends StatelessWidget {
  static final ScrollController scrollController = ScrollController();

  const homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimationLimiter(
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (BuildContext context, int index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      color: Colors.lightGreen[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Item $index',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Listchild(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: ScrollingFabAnimated(
        icon: const Icon(Icons.add, color: Colors.white),
        text: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 16.0)),
        onPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => prayerscreen()),
          );
        },
        scrollController: scrollController,
        animateIcon: true,
        color: Colors.green,
        inverted: false,
        radius: 10.0,
      ),
    );
  }
}