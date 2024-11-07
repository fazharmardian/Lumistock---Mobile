import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../api/api.dart';
import '../model/item.dart';

class ItemDetail extends StatefulWidget {
  final Item item;

  const ItemDetail({Key? key, required this.item}) : super(key: key);

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  int quantity = 0;
  int days = 0;
  String userid = '';
  DateTime? selectedDate;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadToken();
    _checkBookmarkStatus();
    selectedDate = DateTime.now();
  }

  _loadToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token') ?? '');

    print(token);
  }

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user') ?? '{}');

    setState(() {
      userid = user['id'].toString(); // Ensure userid is treated as a string
      print(userid);
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(Duration(days: 7)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _checkBookmarkStatus() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token') ?? '');

    try {
      var res = await Network().getData(
        '/bookmark/${widget.item.id}',
        headers: {
          'Accept': 'application/json',
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var body = json.decode(res.body);
      print(body);
      print(res.statusCode);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        setState(() {
          isBookmarked = body['bookmarked'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to check bookmark status')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Could not check bookmark status')),
      );
    }
  }

  Future<void> _request() async {
    print('send request');

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token') ?? '');

    var data = {
      'id_user': userid,
      'id_item': widget.item.id,
      'total_request': quantity,
      'type': 'Renting',
      'status': 'pending',
      'must_return': days,
    };

    try {
      var res = await Network().postData(
        '/request/store',
        data,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var body = json.decode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request sent successfully')),
        );
      } else {
        // Handle error response from API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Failed to send request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to send request')),
      );
    }
  }

  Future<void> _bookmark() async {
    print('send request');

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token') ?? '');

    var data = {'message': 'bookmark please'};

    try {
      var res = await Network().postData(
        '/bookmark/${widget.item.id}',
        data,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var body = json.decode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        setState(() {
          isBookmarked = body['bookmarked'];
        });
      } else {
        // Handle error response from API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Failed to send request')),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromRGBO(26, 31, 54, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: const Color.fromRGBO(26, 31, 54, 1)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark
                  : Icons.bookmark_border, // Toggle bookmark icon
              color: const Color.fromRGBO(26, 31, 54, 1),
            ),
            onPressed: _bookmark,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              child: Container(
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(3, 6, 23, 1),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Displaying the image without padding
                      Image.network(
                        'http://lumistock.test/storage/${widget.item.image}',
                        height: 400,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              widget.item.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.item.amount > 0
                                  ? "Available in stock"
                                  : "Not Available",
                              style: TextStyle(
                                  color: widget.item.amount > 0
                                      ? Colors.indigo
                                      : Colors.red,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Product Description",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          if (quantity > 1) quantity--;
                                        });
                                      },
                                    ),
                                    Text(
                                      '$quantity', // Update label to "item" or "items"
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          // Ensure the quantity does not exceed available amount
                                          if (quantity < widget.item.amount)
                                            quantity++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.item.description,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(26, 31, 54, 1),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '$days Days', // Update label to "item" or "items"
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (days > 1) days--;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          // Ensure the quantity does not exceed available amount
                          if (days < 7) days++;
                        });
                      },
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _request,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(350, 60),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text("Add to cart",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
