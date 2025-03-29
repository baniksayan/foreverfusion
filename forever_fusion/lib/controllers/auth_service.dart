import 'package:firebase_auth/firebase_auth.dart';
import 'package:forever_fusion/controllers/db_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new account with email verification
  Future<String> createAccountWithEmail(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Save user data to Firestore
      await DbService().saveUserData(name: name, email: email, uid: userCredential.user!.uid);

      return "Account Created Successfully! Please verify your email before logging in.";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred during signup.";
    }
  }

  // Login with email verification check
  Future<String> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the email is verified
      if (!userCredential.user!.emailVerified) {
        await _auth.signOut(); // Sign out the user if not verified
        return "Please verify your email before logging in.";
      }

      return "Login Successful";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred during login.";
    }
  }

  // Logout function
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Send a password reset email
  Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Password reset email sent. Please check your inbox.";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Failed to send password reset email.";
    }
  }

  // Check if the user is logged in
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }
}
