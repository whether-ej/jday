import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jday/page_1.dart';
import 'package:jday/page_2.dart';
import 'package:jday/page_3.dart';
import 'package:jday/palette.dart';

class PageTab extends StatefulWidget {
  const PageTab({super.key});

  @override
  State<PageTab> createState() => _PageTabState();
}

class _PageTabState extends State<PageTab> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('events').snapshots(),
            builder: (context, snapshotE) {
              if (snapshotE.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance.collection('task').snapshots(),
                  builder: (context, snapshotT) {
                    if (snapshotT.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (_currentPage == 0) {
                      return Center(
                          child: Page1(
                        snapshotE: snapshotE,
                        snapshotT: snapshotT,
                      ));
                    } else if (_currentPage == 1) {
                      return Center(
                          child: Page2(
                        snapshot: snapshotE,
                      ));
                    } else {
                      return Center(
                          child: Page3(
                        snapshot: snapshotT,
                      ));
                    }
                  });
            }),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    color: Color(0xffcccccc), spreadRadius: 0, blurRadius: 10),
              ]),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: BottomNavigationBar(
                onTap: _onItemTapped,
                currentIndex: _currentPage,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Palette.whiteP[700],
                unselectedItemColor: Palette.whiteP[200],
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_month), label: 'calendar'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.checklist_rounded), label: 'todo'),
                ]),
          ),
        ));
  }

  void _onItemTapped(int pgnum) {
    setState(() {
      _currentPage = pgnum;
    });
  }
}
