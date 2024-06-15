import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:mynotes_x/services/auth/auth_exceptions.dart';
import 'package:mynotes_x/services/auth/auth_user.dart';
import 'package:mynotes_x/services/facebook_auth/facebook_auth_provider.dart';

class FirebaseFAuthProvider implements FAuthProvider {
  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.accessToken == null) {
        throw NoAccountChoosenException();
      }
      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw const UserNotLoggedInException();
      }
    } on NoAccountChoosenException {
      throw NoAccountChoosenException();
    } on FirebaseAuthException catch (e) {
      throw GenericException(code: e.code);
    } catch (e) {
      throw GenericException(code: e.toString());
    }
  }

  @override
  Future<void> logOut() async {
    await FacebookAuth.instance.logOut();
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

  @override
  Future<AuthUser> signUp() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw const UserNotLoggedInException();
      }
    } on FirebaseAuthException catch (e) {
      throw GenericException(code: e.code);
    } catch (e) {
      throw GenericException(code: e.toString());
    }
  }
}
