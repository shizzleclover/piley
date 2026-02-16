import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signInAnonymously(String username) async {
    try {
      // 1. Sign in anonymously
      final authResponse = await _client.auth.signInAnonymously();
      final user = authResponse.user;

      if (user != null) {
        // 2. Create profile
        await _client.from('profiles').insert({
          'id': user.id,
          'username': username,
        });
      }
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
