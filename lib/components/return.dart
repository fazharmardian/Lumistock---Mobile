import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../api/api.dart';
import '../model/lending.dart';

class ReturnDetail extends StatefulWidget {
  final Lending lending;

  const ReturnDetail({Key? key, required this.lending}) : super(key: key);

  @override
  State<ReturnDetail> createState() => _ReturnDetailState();
}

class _ReturnDetailState extends State<ReturnDetail> {
  String userid = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user') ?? '{}');

    setState(() {
      userid = user['id'].toString();
      print(userid);
    });
  }

  Future<void> _request() async {
    print('send request');

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token') ?? '');

    var data = {
      'rent_id': widget.lending.id,
      'id_user': userid,
      'id_item': widget.lending.itemId,
      'total_request': widget.lending.totalRequest,
      'return_date': DateFormat('yyyy-MM-dd').format(widget.lending.returnDate),
      'type': 'Returning',
      'status': 'Pending',
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
          SnackBar(backgroundColor: Colors.green, content: Text('Request sent successfully')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromRGBO(26, 31, 54, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                        'http://lumistock.test/storage/${widget.lending.itemImage}',
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
                              widget.lending.itemName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.lending.status,
                              style: TextStyle(
                                  color: Colors.indigo,
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
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.lending.itemDesc,
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
            child: ElevatedButton(
              onPressed: _request,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                backgroundColor: const Color.fromRGBO(3, 6, 23, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text("Add to cart",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
