import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  int id = 0;
  String name = '';
  String email = '';
  String avatar = '';
  String role = '';
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user') ?? '{}');

    setState(() {
      id = user['id'];
      print(id);
      name = user['username'];
      email = user['email'];
      avatar = user['avatar'];
      role = user['role'];
    });

    usernameController.text = name;
    emailController.text = email;
  }

  Future<void> _pickImage() async {
    if (!kIsWeb) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else {
      // Handle image picking on web, if needed
      print("Image picking is only supported on mobile for now.");
    }
  }

  Future<void> _saveProfile() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = jsonDecode(localStorage.getString('token') ?? '');

    // Prepare JSON payload
    Map<String, dynamic> data = {
      'username':
          usernameController.text.isNotEmpty ? usernameController.text : name,
      'email': emailController.text.isNotEmpty ? emailController.text : email,
    };

    if (passwordController.text.isNotEmpty) {
      data['password'] = passwordController.text;
    }

    // Add avatar only if on mobile and image is picked
    if (_image != null && !kIsWeb) {
      List<int> imageBytes = await _image!.readAsBytes();
      data['avatar'] = base64Encode(imageBytes);
    }

    try {
      var response = await http.put(
        Uri.parse('http://lumistock.test/api/profile/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      print(response.statusCode);
      print(response.body); // Log response for debugging

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        localStorage.setString('user', jsonEncode(body['user']));

        setState(() {
          name = body['user']['username'];
          email = body['user']['email'];
          avatar = body['user']['avatar'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      print('An error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(3, 6, 23, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(3, 6, 23, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.indigo),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : avatar.isNotEmpty
                              ? NetworkImage(
                                      'http://lumistock.test/storage/$avatar')
                                  as ImageProvider
                              : const AssetImage(
                                  'assets/images/placeholder.jpg'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                  "Username", usernameController, TextInputType.text),
              _buildTextField(
                  "Email Address", emailController, TextInputType.emailAddress),
              _buildTextField(
                  "Password", passwordController, TextInputType.visiblePassword,
                  obscureText: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, TextInputType inputType,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        controller: controller,
        keyboardType: inputType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color.fromRGBO(26, 31, 54, 1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
