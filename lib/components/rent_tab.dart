import 'package:flutter/material.dart';
import '../screen/main/pending.dart';
import '../screen/main/rent.dart';

class RentTab extends StatelessWidget {
  const RentTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2, // Number of tabs
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Renting Menu",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          SizedBox(height: 10),
          TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.indigo,
            tabs: [
              Tab(text: "Approved"),
              Tab(text: "Pending"),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              children: [
                RentPage(),
                PendingPage(), 
              ],
            ),
          ),
        ],
      ),
    );
  }
}
