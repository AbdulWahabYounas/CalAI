import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Register/register_home.dart';

class AuthService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Rx<User?> user = Rx<User?>(null);
  var isSigningIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());

    // Listen to auth state changes
    ever(user, (User? u) {
      if (u != null) {
        _createUserInFirestore(u);
      }
    });

    checkSignInStatus();
  }

  void checkSignInStatus() {
    if (_auth.currentUser != null) {
      // User is already signed in
    }
  }

  // Sign in with Email/Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      isSigningIn.value = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      isSigningIn.value = false;
      return userCredential;
    } catch (e) {
      isSigningIn.value = false;
      Get.snackbar(
        'Error',
        'Failed to sign in: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Sign up with Email/Password
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      isSigningIn.value = true;
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await _createUserInFirestore(userCredential.user!);
      }
      
      isSigningIn.value = false;
      return userCredential;
    } catch (e) {
      isSigningIn.value = false;
      Get.snackbar(
        'Error',
        'Failed to sign up: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // SIGN IN WITH GOOGLE
  Future<UserCredential?> signInWithGoogle() async {
    try {
      isSigningIn.value = true;

      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isSigningIn.value = false;
        Get.snackbar(
          'Cancelled',
          'Sign-in was cancelled',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }

      // Fetch Google tokens
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Build Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Firebase sign in
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final User? currentUser = userCredential.user;

      if (currentUser != null) {
        // Create Firestore user document (if not exists)
        await _createUserInFirestore(currentUser);
      }

      isSigningIn.value = false;

      Get.snackbar(
        'Success',
        'Signed in as ${currentUser?.displayName ?? currentUser?.email}',
        snackPosition: SnackPosition.BOTTOM,
      );

      return userCredential;
    } catch (e) {
      isSigningIn.value = false;
      print("Error signing in with Google: $e");
      Get.snackbar(
        'Error',
        'Failed to sign in: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserInFirestore(User user) async {
    try {
      final docRef =
      FirebaseFirestore.instance.collection("users").doc(user.uid);

      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          "email": user.email,
          "displayName": user.displayName ?? "",
          "photoURL": user.photoURL ?? "",
          "createdAt": FieldValue.serverTimestamp(),
          "lastLogin": FieldValue.serverTimestamp(),
        });
      } else {
        // Update existing user info
        await docRef.update({
          "displayName": user.displayName ?? "",
          "photoURL": user.photoURL ?? "",
          "lastLogin": FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error creating/updating user in Firestore: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();

      Get.offAll(() => const RegisterHome());

      Get.snackbar(
        'Signed Out',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Sign-out failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Delete user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .delete();

      // Delete Firebase Auth account
      await currentUser.delete();

      // Sign out from Google
      await _googleSignIn.signOut();

      Get.snackbar(
        'Success',
        'Account deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete account: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Helper methods
  User? getCurrentUser() => _auth.currentUser;
  String? getUserEmail() => _auth.currentUser?.email;
  String? getUserName() => _auth.currentUser?.displayName;
  String? getUserPhotoUrl() => _auth.currentUser?.photoURL;
  String? getUserId() => _auth.currentUser?.uid;
  bool isSignedIn() => _auth.currentUser != null;
}
