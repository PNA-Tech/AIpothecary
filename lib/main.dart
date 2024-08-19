import 'package:flutter/material.dart';
import 'package:healthassistant/screens/add_medicine.dart';
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
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    _isAuthenticated = await _authService.isAuthenticated();
    if (_isAuthenticated) {
      _userName = (await _authService.getCurrentUserName())!;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Assistant',
      debugShowCheckedModeBanner: false,
      home: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isAuthenticated
              ? HomeScreen(name: _userName)
              : const LoginScreen(),
      routes: {
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(name: _userName),
        '/add_medicine': (context) =>  AddMedicine(authService: AuthService(),),
      },
    );
  }
}
