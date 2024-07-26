import 'package:pocketbase/pocketbase.dart';

class AuthService {
  final pb = PocketBase('http://127.0.0.1:8090');

  Future<void> signUp(String name, String email, String password) async {
    try {
      final user = await pb.collection('users').create(body: {
        'name': name,
        'email': email,
        'password': password,
        'passwordConfirm': password,
      });

      print('User created: ${user.id}');
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  Future<bool> isAuthenticated() async {
    return pb.authStore.isValid;
  }
}
