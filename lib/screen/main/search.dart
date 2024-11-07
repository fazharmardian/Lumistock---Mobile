import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../api/api.dart';
import '../../components/detail.dart';
import '../../model/category.dart';
import '../../model/item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _isLoading = false;
  String name = '';
  List<Item> items = [];
  List<Category> categories = [];
  String _selectedCategory = "All";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Pagination variables
  int _currentPage = 1;
  int _itemsPerPage = 10;

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
          categories = (body['categories'] as List)
              .map((json) => Category.fromJson(json))
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

  List<Item> get filteredItems {
    // Filter items based on selected category and search query
    return items.where((item) {
      final matchesCategory = _selectedCategory == "All" || item.category == _selectedCategory;
      final matchesSearchQuery = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearchQuery;
    }).toList();
  }

  List<Item> get paginatedItems {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    return filteredItems.sublist(
      startIndex,
      endIndex > filteredItems.length ? filteredItems.length : endIndex,
    );
  }

  int get totalPages {
    return (filteredItems.length / _itemsPerPage).ceil();
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
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search items',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color.fromRGBO(5, 9, 34, 1),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "All Items",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(5, 9, 34, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            dropdownColor: const Color.fromRGBO(26, 31, 54, 1),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                              size: 20,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: "All",
                                child: Text("All"),
                              ),
                              ...categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category.name,
                                  child: Text(category.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                                _currentPage = 1; // Reset to first page when changing category
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: paginatedItems.length,
                      itemBuilder: (context, index) {
                        final item = paginatedItems[index];
                        return ItemCard(item: item);
                      },
                    ),
                  const SizedBox(height: 20),
                  // Pagination links
                  if (totalPages > 1) 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(totalPages, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentPage = index + 1;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _currentPage == index + 1 
                                  ? Colors.indigo 
                                  : const Color.fromRGBO(5, 9, 34, 1), // Highlight current page
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }),
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
              image: NetworkImage('http://lumistock.test/storage/${item.image}'),
              fit: BoxFit.cover,
              height: 175,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.name.length > 10 ? '${item.name.substring(0, 10)}...' : item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Stock: ${item.amount}',
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
                const Text(
                  '',
                  style: TextStyle(
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => ItemDetail(item: item)));
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
