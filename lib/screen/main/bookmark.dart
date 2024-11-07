import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';

import '../../api/api.dart';
import '../../components/bookedDetail.dart';
import '../../model/bookmark.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<Bookmark> bookmarks = [];
  bool _isLoading = false;
  int id = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) => _fetchItems());
  }

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userId = jsonDecode(localStorage.getString('user') ?? '{}')['id'];

    setState(() {
      id = userId;
      print(id);
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
        '/bookmark/user/$id',
        headers: {'Authorization': 'Bearer $token'},
      );
      var body = json.decode(res.body);

      print(body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        setState(() {
          bookmarks = (body['bookmarks'] as List)
              .map((json) => Bookmark.fromJson(json))
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
      backgroundColor: Color.fromRGBO(3, 6, 23, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: const Color.fromRGBO(26, 31, 54, 1)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Bookmarked Item', style: TextStyle(color: Colors.white),),
      ),
      body: Container(
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
                    itemCount: bookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = bookmarks[index];
                      return ItemCard(bookmark: bookmark);
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Bookmark bookmark;

  const ItemCard({Key? key, required this.bookmark}) : super(key: key);

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
                  NetworkImage('http://lumistock.test/storage/${bookmark.image}'),
              fit: BoxFit.cover,
              height: 175,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                bookmark.name.length > 10
                    ? '${bookmark.name.substring(0, 10)}...'
                    : bookmark.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Stock: ${bookmark.amount}', // Use string interpolation to include the integer
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
                                BookedDetail(bookmark: bookmark)));
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
