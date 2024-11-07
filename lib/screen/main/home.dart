import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../api/api.dart';
import '../../components/detail.dart';
import '../../model/item.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  String name = '';
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchItems();
  }

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user') ?? '{}');

    setState(() {
      name = user['username'] ?? 'User';
    });
  }

  Future<void> _fetchItems() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token') ?? '');

    setState(() {
      _isLoading = true;
    });

    try {
      var res = await Network().getData(
        '/item',
        headers: {'Authorization': 'Bearer $token'},
      );
      var body = json.decode(res.body);


      if (res.statusCode >= 200 && res.statusCode < 300) {
        setState(() {
          items = (body['items'] as List)
              .map((json) => Item.fromJson(json))
              .toList();
        });
      } else {
        print(body['message']);
      }
    } catch (e) {
      print('An error occurred while fetching items.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 31, 54, 1),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(3, 6, 23, 1),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Borrow Your Necessity",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // const SizedBox(height: 20),
                  // Container(
                  //   decoration: BoxDecoration(
                  //       color: const Color.fromRGBO(26, 31, 54, 1),
                  //       borderRadius: BorderRadius.circular(30)),
                  //   child: const Padding(
                  //     padding:
                  //         EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  //     child:
                  //         Text('Books',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 16,
                  //       )
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Latest Items",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     Navigator.pushReplacement(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => BottomBar()),
                      //     );
                      //   },
                      //   child: const Text(
                      //     "View All",
                      //     style: TextStyle(
                      //       color: Colors.grey,
                      //       fontSize: 16,
                      //       decoration: TextDecoration.underline,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading) Center(child: CircularProgressIndicator()),
                  if (!_isLoading)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns
                        childAspectRatio: 0.75, // Aspect ratio for items
                        crossAxisSpacing: 16, // Space between columns
                        mainAxisSpacing: 16, // Space between rows
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ItemCard(item: item);
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(5, 9, 34, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Image(
              image:
                  NetworkImage('http://lumistock.test/storage/${item.image}'),
              fit: BoxFit.cover,
              height: 175,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.name.length > 10
                    ? '${item.name.substring(0, 10)}...'
                    : item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Stock: ${item.amount}', // Use string interpolation to include the integer
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '', // Use string interpolation to include the integer
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(96, 119, 253, 1),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(96, 119, 253, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ItemDetail(item: item)));
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
