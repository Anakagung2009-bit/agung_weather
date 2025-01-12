import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream untuk status autentikasi
  Stream<User?> get user => _auth.authStateChanges();

  // Cek status login
  bool get isLoggedIn => _auth.currentUser != null;

  // Login dengan Email dan Password
  Future<User?> signInWithEmailPassword(
      {required String email, required String password}) async {
    try {
      print('Attempting to sign in with email: $email');

      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      print('Sign in successful: ${result.user?.uid}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error Code: ${e.code}');
      print('Firebase Auth Error Message: ${e.message}');

      String errorMessage;
      switch (e.code) {
        case 'network-request-failed':
          errorMessage =
              'Network error. Please check your internet connection.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        default:
          errorMessage = e.message ?? 'Authentication error';
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('Unexpected error during sign in: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Registrasi dengan Email dan Password
  Future<User?> registerWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      print('Attempting to register with email: $email');

      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Update display name jika disediakan
      if (displayName != null && result.user != null) {
        await result.user!.updateDisplayName(displayName);
      }

      print('Registration successful: ${result.user?.uid}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Registration Error: ${e.code}');
      print('Error Message: ${e.message}');

      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email is already in use.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak.';
          break;
        case 'network-request-failed':
          errorMessage =
              'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = e.message ?? 'Registration error';
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('Unexpected error during registration: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      print('Password Reset Error: ${e.code}');
      print('Error Message: ${e.message}');

      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        default:
          errorMessage = e.message ?? 'Password reset error';
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('Unexpected error during password reset: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Update Profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await currentUser.updateDisplayName(displayName);
        await currentUser.updatePhotoURL(photoURL);

        print('Profile updated successfully');
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile');
    }
  }

  Future<void> signOut() async {
    try {
      // Logout dari Firebase Authentication
      await _auth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  // Dapatkan user saat ini
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Verifikasi email
  Future<void> verifyEmail() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print('Verification email sent to ${user.email}');
    } else {
      throw Exception('User is either null or already verified');
    }
  }
}
