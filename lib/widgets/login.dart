import 'package:flutter/material.dart';
import 'package:healthassistant/screens/add_medicine.dart';
import 'package:healthassistant/util/auth.dart';
import 'package:healthassistant/widgets/manual_btn.dart';
import 'package:pocketbase/pocketbase.dart';
import '../screens/home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final pb = PocketBase('https://region-generally.pockethost.io/');

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authResponse = await pb.collection('users').authWithPassword(
              _emailController.text,
              _passwordController.text,
            );

        final user = authResponse.record;
        final userName = user?.getStringValue('name') ?? 'User';
        final userId = user?.id; 

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(name: userName)),
          result: MaterialPageRoute(builder: (context) => ManualAddButton(userId: userId, authService: AuthService(), onAdd: (String name, String frequency, List<String> times, List<String> days) {  },)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text('Not a member? Sign Up'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
