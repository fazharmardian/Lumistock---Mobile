import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('About', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: const Color.fromRGBO(3, 6, 23, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Heading Section
                const Text(
                  'Welcome to Lumistock',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lumistock is a lending item app designed specifically for our school, making it easy for students and staff to borrow and manage items responsibly.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
            
                // About Section
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 24),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(26, 31, 54, 1), // bg-darkblue-300
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'About Lumistock',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Lumistock enables students and staff to borrow school items efficiently. Whether you need equipment for projects, technology, or other school supplies, Lumistock provides a streamlined way to track and manage borrowed items.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
            
                // Lending Rules Section
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 24),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(26, 31, 54, 1), // bg-darkblue-300
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Lending Rules',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '• All items must be returned by the specified return date.\n'
                        '• Late returns may result in penalties or restrictions on future borrowing privileges.\n'
                        '• Handle all borrowed items with care. Damaged items must be reported immediately.\n'
                        '• Borrowed items are for educational and project purposes only and should not be taken off-campus without permission.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
            
                // Assistance Section
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 24),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(26, 31, 54, 1), // bg-darkblue-300
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Need Assistance?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          // Contact Button
                          ContactButton(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'If you have any questions or encounter issues, feel free to reach out to our support team.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
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
}

class ContactButton extends StatelessWidget {
  const ContactButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Open WhatsApp link
        const url = 'https://wa.me/089665375943';
        // Use url_launcher package to open link
        // launch(url);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: const <Widget>[
            Icon(
              Icons.email_outlined,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Contact Support',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
