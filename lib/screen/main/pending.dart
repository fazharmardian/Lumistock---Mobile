import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../api/api.dart';
import '../../model/pending.dart';

class PendingPage extends StatefulWidget {
  const PendingPage({super.key});

  @override
  State<PendingPage> createState() => _PendingPageState();
}

class _PendingPageState extends State<PendingPage> {
  bool _isLoading = false;
  List<Request> pendings = [];
  String _selectedStatus = "All";

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token') ?? '');

    setState(() {
      _isLoading = true;
    });

    try {
      var res = await Network().getData(
        '/request',
        headers: {'Authorization': 'Bearer $token'},
      );
      var body = json.decode(res.body);

      print(body);
      print(res.statusCode);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        setState(() {
          pendings = (body['pendings'] as List)
              .map((json) => Request.fromJson(json))
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

  List<Request> get filteredPendings {
    if (_selectedStatus == "All") return pendings;
    return pendings
        .where((lending) => lending.type == _selectedStatus)
        .toList();
  }

  Future<void> _cancelRequest(int requestId) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token') ?? '');

    setState(() {
      _isLoading = true;
    });

    try {
      var res = await Network().deleteData(
        '/request/$requestId',
        headers: {'Authorization': 'Bearer $token'},
      );

      var body = json.decode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        setState(() {
          // Remove the canceled request from the list
          pendings.removeWhere((request) => request.id == requestId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(body['message'])),
        );
      } else {
        print(body['message']);
      }
    } catch (e) {
      print('An error occurred while cancelling the request.');
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Pending Requests",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(5, 9, 34, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            dropdownColor: const Color.fromRGBO(26, 31, 54, 1),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                              size: 20, // Smaller icon size
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14, // Slightly smaller font size
                              fontWeight: FontWeight.w500,
                            ),
                            items: <String>["All", "Renting", "Returning"]
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedStatus = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredPendings.length,
                      itemBuilder: (context, index) {
                        final pending = filteredPendings[index];
                        return PendingCard(
                          pending: pending,
                          onCancel: () => _cancelRequest(pending.id)
                        );
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

class PendingCard extends StatelessWidget {
  final Request pending;
  final VoidCallback onCancel;

  const PendingCard({Key? key, required this.pending, required this.onCancel})
      : super(key: key);

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
              image: NetworkImage(
                  'http://lumistock.test/storage/${pending.itemImage}'),
              fit: BoxFit.cover,
              height: 175,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              pending.itemName.length > 10
                  ? '${pending.itemName.substring(0, 10)}...'
                  : pending.itemName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Total: ${pending.totalRequest}',
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
                  pending.type,
                  style: TextStyle(fontSize: 14, color: Colors.indigo),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                  onPressed: onCancel, // Use the onCancel callback
                  child: const Icon(FeatherIcons.x,
                      size: 18, color: Colors.white),
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
