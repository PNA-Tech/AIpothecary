import 'package:flutter/material.dart';
import 'package:healthassistant/screens/home.dart';
import 'package:healthassistant/widgets/login.dart';
import 'package:healthassistant/widgets/signup.dart';
import 'package:healthassistant/util/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    _isAuthenticated = await _authService.isAuthenticated();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isAuthenticated
              ? HomeScreen()
              : LoginScreen(),
      routes: {
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
