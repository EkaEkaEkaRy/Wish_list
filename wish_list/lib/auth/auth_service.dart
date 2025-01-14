import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wish_list/Database/SupabaseUser.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    final auth = await _supabase.auth
        .signInWithPassword(email: email, password: password);
    updateUserID(email, _supabase.auth.currentSession!.user.id);
    return auth;
  }

  Future<void> signUpWithEmailPassword(
      String username, String email, String password) async {
    await _supabase.auth.signUp(email: email, password: password);

    addUser(email, username);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  String? getCurrentUserId() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.id;
  }
}
