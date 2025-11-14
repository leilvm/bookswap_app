// lib/data/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up: creates Firebase user, sends verification email and writes Firestore profile
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      // Send verification email
      await user.sendEmailVerification();

      // Create user document in Firestore
      final newUser = UserModel(
        id: user.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

      // Optional: keep user signed in or sign out depending on your flow.
      // We return the created user profile to the caller.
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception('Firebase Auth error: ${e.message}');
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign In: checks verification and returns Firestore user data
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('User not found');

      // Ensure we have latest emailVerified status
      await user.reload();
      final reloaded = _auth.currentUser;
      if (reloaded == null) throw Exception('User session error');

      if (!reloaded.emailVerified) {
        // Sign the user out immediately and ask verification
        await _auth.signOut();
        throw Exception('Please verify your email before signing in.');
      }

      // Fetch Firestore profile
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception('Firebase Auth error: ${e.message}');
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user data (from Firestore)
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) return UserModel.fromMap(doc.data()!);
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Resend verification email to currently signed-in user
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No signed-in user to send verification to.');
    }
    await user.sendEmailVerification();
  }
}
