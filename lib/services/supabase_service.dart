import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  }

  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: name != null ? {'full_name': name} : null,
    );
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Get current user
  static User? get currentUser => client.auth.currentUser;

  // Stream of auth state changes
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
