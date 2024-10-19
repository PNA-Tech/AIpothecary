import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Chat"),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          ListView(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.lightBlue[100],
                child: const Text(
                    "Hello! How can I help you? I am your personal health assistant."),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: const Text("What is my BMI?"),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.lightBlue[100],
                child: const Text("Your BMI is 25.0. You are overweight."),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              color: Colors.grey[200],
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Type a message",
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          )
        ],
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
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}
