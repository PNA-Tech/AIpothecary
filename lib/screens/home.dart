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
    );
  }
}
