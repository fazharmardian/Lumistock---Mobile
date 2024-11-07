import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api.dart';
import '../../components/bottom_bar.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  final _formKey = GlobalKey<FormState>();
  String? username, email;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(3, 6, 23, 1), // Dark theme background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 70),
              const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              _buildRegisterForm(),
              const SizedBox(height: 30),
              _buildRegisterButton(),
              const SizedBox(height: 20),
              _buildLoginPrompt(),
              const Spacer(),
              _buildCopyright(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _buildTextField(
            label: "Username",
            icon: Icons.person_outline,
            onSaved: (value) => username = value,
            validator: (value) => value!.isEmpty ? 'Enter your username' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Email",
            icon: Icons.email_outlined,
            onSaved: (value) => email = value,
            validator: (value) {
              if (value!.isEmpty) return 'Enter your email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            label: "Password",
            obsecure: !_isPasswordVisible,
            controller: _passwordController,
            icon: Icons.lock_outline,
            sicon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible; // Toggle state
                  });
                },
              ),
            validator: (value) =>
                value!.length < 6 ? 'Password too short' : null,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            label: "Confirm Password",
            obsecure: !_isConfirmVisible,
            controller: _confirmPasswordController,
            icon: Icons.lock_outline,
            sicon: IconButton(
                icon: Icon(
                  _isConfirmVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmVisible = !_isConfirmVisible; // Toggle state
                  });
                },
              ),
            validator: (value) {
              if (value!.isEmpty) return 'Confirm your password';
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.grey,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: const  Color.fromRGBO(26, 31, 54, 1),
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required IconButton sicon,
    required bool obsecure,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obsecure,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.grey,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: const Color.fromRGBO(26, 31, 54, 1),
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: sicon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
      ),
      validator: validator,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(vertical: 22),
        ),
        onPressed: _isLoading ? null : _register,
        child: Text(
          _isLoading ? 'Processing...' : 'Register',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        child: RichText(
          text: TextSpan(
            text: "Already have an account? ",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            children: [
              const TextSpan(
                text: "Sign in",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCopyright() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Center(
        child: RichText(
          text: TextSpan(
            text: "Lumistock ",
            style: TextStyle(
              color: const Color.fromRGBO(158, 158, 158, 0.5),
              fontSize: 14,
            ),
            children: [
              const TextSpan(
                text: "@",
                style: TextStyle(
                  color: Color.fromRGBO(158, 158, 158, 0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    var data = {
      'username': username,
      'email': email,
      'password': _passwordController.text,
      'password_confirmation': _confirmPasswordController.text,
    };

    try {
      var res = await Network().authData(data, '/register');
      var body = json.decode(res.body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('token', json.encode(body['token']));
        localStorage.setString('user', json.encode({'id': body['user']['id']}));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomBar()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
