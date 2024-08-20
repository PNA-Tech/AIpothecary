import 'package:pocketbase/pocketbase.dart';

class AuthService {
  final pb = PocketBase('https://region-generally.pockethost.io/');

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

  Future<String?> getCurrentUserId() async {
    if (!pb.authStore.isValid) {
      print('User is not authenticated');
      return null;
    }
    final user = pb.authStore.model;
    return user?.id;
  }

  Future<String?> getCurrentUserName() async {
    if (!pb.authStore.isValid) {
      print('User is not authenticated');
      return null;
    }
    final user = pb.authStore.model;
    return user?.getString('name');
  }
}
