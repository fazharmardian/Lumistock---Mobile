import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../screen/main/home.dart';
import '../screen/main/search.dart';
import '../screen/main/profile.dart';
import 'rent_tab.dart';

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomePage(),
    SearchPage(),
    RentTab(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(3, 6, 23, 1),
      body: _screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          height: 70,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(26, 31, 54, 1),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors
                .transparent, // Make background transparent to see rounded corners
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey[600],
            showSelectedLabels: false,
            showUnselectedLabels: false,
            iconSize: 28,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(FeatherIcons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(FeatherIcons.search), label: 'Search'),
              BottomNavigationBarItem(
                  icon: Icon(FeatherIcons.shoppingCart), label: 'Lending'),
              BottomNavigationBarItem(
                  icon: Icon(FeatherIcons.user), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
