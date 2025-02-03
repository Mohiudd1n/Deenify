import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deenify/screens/prayerscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:deenify/main.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_scrolling_fab_animated/flutter_scrolling_fab_animated.dart';
import 'package:intl/intl.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart'; // Add this package
import '../widgets/listchild.dart'; // Adjust the import path as needed

class homepage extends StatelessWidget {
  static final ScrollController scrollController = ScrollController();

  const homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimationLimiter(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("namazrecords")
              .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No Data Here :("));
            }

            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                final doc = snapshot.data!.docs[index];
                final date = DateFormat("dd-MM-yyyy").format((doc["Date"] as Timestamp).toDate());
                final time = DateFormat("hh:mm a").format((doc["Time"] as Timestamp).toDate());

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
                              Text(
                                time,
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
          },
        ),
      ),
      floatingActionButton: ScrollingFabAnimated(
        icon: const Icon(Icons.add, color: Colors.white),
        text: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 16.0)),
        onPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const prayerscreen()),
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