import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mynotes_x/services/auth/auth_exceptions.dart';
import 'package:mynotes_x/services/auth/auth_user.dart';
import 'package:mynotes_x/services/google_auth/google_auth_provider.dart';

class FirebaseGAuthProvider implements GAuthProvider {
  @override
  Future<AuthUser> signIn() async {
    try {
      // final GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
      // await FirebaseAuth.instance.signInWithProvider(googleAuthProvider);

      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        throw const NoEmailChoosenException();
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
        accessToken: gAuth.accessToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw const UserNotLoggedInException();
      }
    } on NoEmailChoosenException {
      throw const NoEmailChoosenException();
    } on FirebaseAuthException catch (e) {
      throw GenericException(code: e.code);
    } catch (e) {
      throw GenericException(code: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
  }

  @override
  Future<AuthUser> signUp() async {
    try {
      // final GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
      // await FirebaseAuth.instance.signInWithProvider(googleAuthProvider);

      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        throw const NoEmailChoosenException();
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
        accessToken: gAuth.accessToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw const UserNotLoggedInException();
      }
    } on NoEmailChoosenException {
      throw const NoEmailChoosenException();
    } on FirebaseAuthException catch (e) {
      throw GenericException(code: e.code);
    } catch (e) {
      throw GenericException(code: e.toString());
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    } else {
      return AuthUser.fromFirebase(user);
    }
  }

  @override
  Future<void> reload() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
    } else {
      throw const UserNotLoggedInException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw const UserNotLoggedInException();
    }
  }
}
