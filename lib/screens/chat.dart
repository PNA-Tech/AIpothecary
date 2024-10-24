import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  String _userName = "Piyush Acharya"; // Fake user name

  // Fake medicines for the user
  final List<Map<String, dynamic>> _medicines = [
    {
      'name': 'Aspirin',
      'frequency': 'Once daily',
      'times': ['8:00 AM'],
      'days': ['Monday', 'Wednesday', 'Friday'],
    },
    {
      'name': 'Lisinopril',
      'frequency': 'Once daily',
      'times': ['9:00 AM'],
      'days': ['Everyday'],
    },
  ];

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add({"user": message});
    });

    // Call the OpenAI API with access to fake user data
    String response = await _getAIResponse(message);

    // Update state with bot response
    setState(() {
      _messages.add({"bot": response});
    });

    // Clear input field
    _controller.clear();
  }

  // Function to get a response from OpenAI API with detailed error logging
  Future<String> _getAIResponse(String message) async {
    final apiKey = "sk-LwVScIKsYIgsvT4NO5Q3j2jFZI-AXWNZjrSiVK4GYlT3BlbkFJSkZcO-okqO3BwxFKLO52j8NrFC_FN_zrmWtSoV6E4A"; // Replace with your actual OpenAI API key

    // Construct the prompt with fake user data
    String prompt = """
    You are a medical assistant chatbot with access to the user's medical history and current medications. 
    The user's name is $_userName.
    The user is currently taking the following medications: ${_medicines.map((m) => "${m['name']}: ${m['frequency']}").join(", ")}.
    Please provide helpful health advice or recommendations based on their message. END WITH 2-3 MEDICINE RECOMMENDATIONS, FREQUENCY, AND BUILD A PLAN FOR THE USER, ALSO EDUCATE THEM ABOUT THE MEDICINE LIKE TELL THEM ABOUT IT.

    User message: "$message"
    """;

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "system", "content": "You are a helpful medical assistant."},
        {"role": "user", "content": prompt}
      ],
      "max_tokens": 500,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['choices'][0]['message']['content'].trim();
      } else {
        // Print response for debugging
        print("API Error: ${response.statusCode}, ${response.body}");
        return "Oops! Something went wrong. API Error: ${response.statusCode}";
      }
    } catch (e) {
      // Print the exception for debugging
      print("Exception: $e");
      return "Oops! Something went wrong: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Chat"),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              Map<String, String> message = _messages[index];
              bool isUser = message.containsKey("user");
              return Container(
                padding: const EdgeInsets.all(10),
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                color: isUser ? Colors.lightBlue[100] : Colors.lightGreen[100],
                child: Text(isUser ? message["user"]! : message["bot"]!),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              color: Colors.grey[200],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        contentPadding: EdgeInsets.all(10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _sendMessage(_controller.text);
                    },
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
