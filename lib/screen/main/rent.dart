import 'package:flutter/material.dart';
import 'package:lumistock/components/return.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../api/api.dart';
import '../../model/lending.dart';

class RentPage extends StatefulWidget {
  const RentPage({super.key});

  @override
  State<RentPage> createState() => _RentPageState();
}

class _RentPageState extends State<RentPage> {
  bool _isLoading = false;
  List<Lending> lendings = [];
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

      if (res.statusCode >= 200 && res.statusCode < 300) {
        setState(() {
          lendings = (body['lendings'] as List)
              .map((json) => Lending.fromJson(json))
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

  List<Lending> get filteredLendings {
    if (_selectedStatus == "All") return lendings;
    return lendings
        .where((lending) => lending.status == _selectedStatus)
        .toList();
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
                        "Your Lendings",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Dropdown for filtering
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
                            items: <String>["All", "Lending", "Returned"]
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
                      itemCount: filteredLendings.length,
                      itemBuilder: (context, index) {
                        final lending = filteredLendings[index];
                        return LendingCard(lending: lending);
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

class LendingCard extends StatelessWidget {
  final Lending lending;

  const LendingCard({Key? key, required this.lending}) : super(key: key);

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
                  'http://lumistock.test/storage/${lending.itemImage}'),
              fit: BoxFit.cover,
              height: 175,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                lending.itemName.length > 10
                    ? '${lending.itemName.substring(0, 10)}...'
                    : lending.itemName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Total: ${lending.totalRequest}', // Use string interpolation to include the integer
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
                  lending.status == 'Returned'
                      ? 'Returned'
                      : 'Return at: ${DateFormat('MM-dd').format(lending.returnDate)}',
                  style: TextStyle(
                      fontSize: 14,
                      color: lending.status == 'Returned'
                          ? Colors.greenAccent
                          : Colors.indigo),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lending.status == 'Returned'
                        ? Colors.greenAccent
                        : const Color.fromRGBO(96, 119, 253, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    lending.status == 'Returned'
                        ? {}
                        : Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  ReturnDetail(lending: lending),
                            ),
                          );
                  },
                  child: Icon(
                      lending.status == 'Returned'
                          ? FeatherIcons.check
                          : FeatherIcons.send,
                      size: 18,
                      color: Colors.white),
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
