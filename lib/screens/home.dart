import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  final String name;

  const HomeScreen({super.key, required this.name});

  Future<void> _launchWebMdPage(String medicineName) async {
    final url = 'https://www.webmd.com/drugs/2/search?query=$medicineName';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👋 $name', style: TextStyle(fontSize: 20)),
            Text('AIpothecary', style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/add_medicine');
                  },
                  child: const Text('Add Medicine', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 20),
                // Streaks and Gamification Section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Streaks',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: const [
                                Icon(Icons.bolt, size: 50, color: Colors.amber),
                                SizedBox(height: 5),
                                Text(
                                  '3-Day Streak',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Column(
                              children: const [
                                Icon(Icons.bolt, size: 50, color: Colors.amber),
                                SizedBox(height: 5),
                                Text(
                                  'Next Reward: 5 Days',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Connect with Family and Friends Section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connect with Family & Friends',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/connect_family');
                          },
                          child: const Text('Invite Family Member', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/connect_friends');
                          },
                          child: const Text('Invite Friend', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Fake User Profiles for Competition
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Profiles',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Example User Profile 1
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                          ),
                          title: const Text('John Doe', style: TextStyle(fontSize: 16)),
                          subtitle: const Text('Age: 34 | Condition: Hypertension', style: TextStyle(fontSize: 14)),
                        ),
                        const Divider(),
                        // Example User Profile 2
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                          ),
                          title: const Text('Jane Smith', style: TextStyle(fontSize: 16)),
                          subtitle: const Text('Age: 29 | Condition: Asthma', style: TextStyle(fontSize: 14)),
                        ),
                        const Divider(),
                        // Example User Profile 3
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                          ),
                          title: const Text('Alex Johnson', style: TextStyle(fontSize: 16)),
                          subtitle: const Text('Age: 45 | Condition: Diabetes', style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Medicine Information Section
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: () {
                    _launchWebMdPage('aspirin'); // Example usage with medicine name 'aspirin'
                  },
                  child: const Text('Get Info on Aspirin from WebMD', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 20),
                // Feed / Log Section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Example Feed Entry 1
                        ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network('https://www.webmd.com/media/medical-associations/image-placeholder.png'),
                          ),
                          title: const Text('Aspirin - Taken at 8:00 AM', style: TextStyle(fontSize: 16)),
                          subtitle: const Text('Feeling good today. No side effects.', style: TextStyle(fontSize: 14)),
                        ),
                        const Divider(),
                        // Example Feed Entry 2
                        ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network('https://www.webmd.com/media/medical-associations/image-placeholder.png'),
                          ),
                          title: const Text('Vitamin C - Taken at 10:00 AM', style: TextStyle(fontSize: 16)),
                          subtitle: const Text('Added note: Boosting immunity!', style: TextStyle(fontSize: 14)),
                        ),
                        const Divider(),
                        // Example Feed Entry 3
                        ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network('https://www.webmd.com/media/medical-associations/image-placeholder.png'),
                          ),
                          title: const Text('Ibuprofen - Taken at 2:00 PM', style: TextStyle(fontSize: 16)),
                          subtitle: const Text('Mild headache, feeling better now.', style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              icon: const Icon(Icons.home, size: 30),
              color: Colors.deepPurpleAccent,
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_medicine');
              },
              icon: const Icon(Icons.medication, size: 30),
              color: Colors.deepPurpleAccent,
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/chat');
              },
              icon: const Icon(Icons.chat, size: 30),
              color: Colors.deepPurpleAccent,
            ),
          ],
        ),
      ),
    );
  }
}
