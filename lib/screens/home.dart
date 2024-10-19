import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String name;

  const HomeScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('👋 $name'),
        backgroundColor: Colors.cyanAccent[200],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/add_medicine');
          },
          child: const Text('Add Medicine'),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              icon: Icon(Icons.home),
              color: Colors.purple,
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_medicine');
              },
              icon: Icon(Icons.medication),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/chat');
              },
              icon: Icon(Icons.chat),
            ),
          ],
        ),
      ),
    );
  }
}
