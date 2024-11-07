import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';

import '../../api/api.dart';
import '../../components/edit_profile.dart';
import '../../model/profile.dart';
import '../auth/login.dart';
import 'about.dart';
import 'bookmark.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Profile? profile;
  bool _isLoading = false;
  int id = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) => _fetchProfile());
  }

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userId = jsonDecode(localStorage.getString('user') ?? '{}')['id'];

    setState(() {
      id = userId;
    });
  }

  Future<void> _fetchProfile() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token') ?? '');

    setState(() {
      _isLoading = true;
    });

    try {
      var res = await Network().getData(
        '/profile/$id',
        headers: {'Authorization': 'Bearer $token'},
      );
      var body = json.decode(res.body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        setState(() {
          profile = Profile.fromJson(body['user']);
        });
      } else {
        print(body['message']);
      }
    } catch (e) {
      print('An error occurred while fetching profile data.');
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
          color: const Color.fromRGBO(3, 6, 23, 1),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Column(
                    children: [
                      // Profile Image with Shimmer
                      _isLoading
                          ? Shimmer.fromColors(
                              baseColor:
                                  const Color.fromRGBO(189, 189, 189, 0.2),
                              highlightColor:
                                  const Color.fromRGBO(224, 224, 224, 0.2),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[400],
                              ),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundImage: profile != null &&
                                      profile!.avatar.isNotEmpty
                                  ? NetworkImage(
                                      'http://lumistock.test/storage/${profile!.avatar}')
                                  : const AssetImage(
                                          'assets/images/placeholder.jpg')
                                      as ImageProvider,
                            ),
                      const SizedBox(height: 10),
                      // Username with Shimmer
                      _isLoading
                          ? Shimmer.fromColors(
                              baseColor:
                                  const Color.fromRGBO(189, 189, 189, 0.2),
                              highlightColor:
                                  const Color.fromRGBO(224, 224, 224, 0.2),
                              child: Container(
                                height: 20,
                                width: 100,
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[400],
                                ),
                              ),
                            )
                          : Text(
                              profile != null ? profile!.username : '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                      const SizedBox(height: 5),
                      // Email with Shimmer
                      _isLoading
                          ? Shimmer.fromColors(
                              baseColor:
                                  const Color.fromRGBO(189, 189, 189, 0.2),
                              highlightColor:
                                  const Color.fromRGBO(224, 224, 224, 0.2),
                              child: Container(
                                height: 20,
                                width: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[400],
                                ),
                              ),
                            )
                          : Text(
                              profile != null ? profile!.email : '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                      const SizedBox(height: 10),
                      _isLoading
                          ? Shimmer.fromColors(
                              baseColor:
                                  const Color.fromRGBO(189, 189, 189, 0.2),
                              highlightColor:
                                  const Color.fromRGBO(224, 224, 224, 0.2),
                              child: Container(
                                height: 25,
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey[400],
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfile()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    children: [
                      _buildProfileOption(FeatherIcons.bookmark, "Bookmark",
                          action: bookmark),
                      _buildProfileOption(FeatherIcons.info, "About",
                          action: about),
                      _buildProfileOption(FeatherIcons.logOut, "Log Out",
                          action: logout),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title,
      {VoidCallback? action}) {
    return _isLoading
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Shimmer.fromColors(
              baseColor: const Color.fromRGBO(189, 189, 189, 0.2),
              highlightColor: const Color.fromRGBO(224, 224, 224, 0.2),
              child: Container(
                height: 40,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[400],
                ),
              ),
            ),
          )
        : ListTile(
            leading: Icon(
              icon,
              color: Colors.grey[700],
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            tileColor: Colors.transparent,
            trailing: action != null
                ? const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16)
                : null,
            onTap: action,
          );
  }

  void about() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutPage()),
    );
  }

  void bookmark() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BookmarkPage()),
    );
  }

  void logout() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token') ?? '');

    try {
      var res = await Network().postData(
        '/logout',
        {'message': token},
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        localStorage.remove('user');
        localStorage.remove('token');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        print('Logout failed');
      }
    } catch (e) {
      print('Request error: $e');
    }
  }
}
