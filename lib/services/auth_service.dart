import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_demo_firebase/models/user_model.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      developer.log('Starting email login for: $email');

      // Ensure Firebase is ready
      await Future.delayed(const Duration(milliseconds: 300));

      // Try signing in
      UserCredential result;
      try {
        result = await _auth
            .signInWithEmailAndPassword(
              email: email.trim(),
              password: password.trim(),
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () =>
                  throw Exception('Login timeout - please try again'),
            );
      } catch (e) {
        developer.log('First attempt failed: $e');

        // If we get a Pigeon error, try checking auth state directly
        if (e.toString().contains('Pigeon') ||
            e.toString().contains('PigeonUser')) {
          developer.log('Pigeon error detected, checking auth state...');
          await Future.delayed(const Duration(seconds: 1));

          // Check if user is actually authenticated
          if (_auth.currentUser != null) {
            developer.log(
              'User is authenticated via currentUser: ${_auth.currentUser?.uid}',
            );
            return _auth.currentUser;
          }
        }

        // If still failed, rethrow
        if (e is FirebaseAuthException) {
          throw Exception('Login failed: ${e.message}');
        }
        throw Exception('Login error: $e');
      }

      developer.log('Login successful: ${result.user?.uid}');

      // Create user document if it doesn't exist
      if (result.user != null) {
        await _ensureUserExists(result.user!);
      }

      return result.user;
    } catch (e) {
      developer.log('Login exception: $e');
      throw Exception(e.toString());
    }
  }

  Future<User?> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String phone = '',
    String city = '',
  }) async {
    try {
      developer.log('Starting registration for: $email');

      await Future.delayed(const Duration(milliseconds: 300));

      UserCredential result;
      try {
        result = await _auth
            .createUserWithEmailAndPassword(
              email: email.trim(),
              password: password.trim(),
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () =>
                  throw Exception('Registration timeout - please try again'),
            );
      } catch (e) {
        if (e.toString().contains('Pigeon') ||
            e.toString().contains('PigeonUser')) {
          developer.log('Pigeon error in registration, checking state...');
          if (_auth.currentUser != null) {
            return _auth.currentUser;
          }
        }

        if (e is FirebaseAuthException) {
          throw Exception('Registration failed: ${e.message}');
        }
        throw Exception('Registration error: $e');
      }

      final user = result.user;
      if (user != null) {
        final model = UserModel(
          uid: user.uid,
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          photoUrl: '',
          createdAt: Timestamp.now(),
          lastSeen: Timestamp.now(),
          city: city.trim(),
        );
        await _firestore.collection('users').doc(user.uid).set(model.toMap());
        developer.log('User registered and document created: ${user.uid}');
      }

      return user;
    } catch (e) {
      developer.log('Registration exception: $e');
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      developer.log('User signed out');
    } catch (e) {
      developer.log('Sign out error: $e');
      throw Exception('Sign out failed: $e');
    }
  }

  // Helper method to ensure user document exists
  Future<void> _ensureUserExists(User user) async {
    try {
      final doc = _firestore.collection('users').doc(user.uid);
      final snapshot = await doc.get();

      if (!snapshot.exists) {
        final model = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          phone: '',
          photoUrl: user.photoURL ?? '',
          createdAt: Timestamp.now(),
          lastSeen: Timestamp.now(),
          city: '',
        );
        await doc.set(model.toMap());
        developer.log('User document created: ${user.uid}');
      }
    } catch (e) {
      developer.log('Error ensuring user exists: $e');
      // Don't throw here, user is still logged in
    }
  }
}
