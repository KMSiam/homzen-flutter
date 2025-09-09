import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user account first
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Update display name immediately
        await user.updateDisplayName(name);
        
        // Save to Firestore in background (non-blocking)
        _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        }).catchError((error) {
          // Firestore background save failed - handled silently
        });
        
        return null; // Success - don't wait for Firestore
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'The account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return e.message ?? 'An error occurred during sign up.';
      }
    } catch (e) {
      return 'Failed to create account: ${e.toString()}';
    }
    return 'Unknown error occurred';
  }

  // Sign in with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        default:
          return e.message ?? 'An error occurred during sign in.';
      }
    } catch (e) {
      return 'Failed to sign in: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    User? user = currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get()
            .timeout(const Duration(seconds: 5));
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>?;
        } else {
          // Fallback: create basic user data if missing
          Map<String, dynamic> userData = {
            'name': user.displayName ?? 'User',
            'email': user.email ?? '',
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          };
          
          // Try to save it for next time
          try {
            await _firestore.collection('users').doc(user.uid).set(userData);
          } catch (e) {
            // Failed to create user document - handled silently
          }
          
          return userData;
        }
      } catch (e) {
        // Error getting user data - return basic info
        return {
          'name': user.displayName ?? 'User',
          'email': user.email ?? '',
          'uid': user.uid,
        };
      }
    }
    return null;
  }

  // Reset password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return e.message ?? 'An error occurred.';
      }
    } catch (e) {
      return 'Failed to send reset email: ${e.toString()}';
    }
  }
}
