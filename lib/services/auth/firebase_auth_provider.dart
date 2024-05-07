import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes_x/firebase_options.dart';
import 'package:mynotes_x/services/auth/auth_provider.dart';
import 'package:mynotes_x/services/auth/auth_user.dart';
import 'package:mynotes_x/services/auth/auth_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthProvider implements CustomAuthProvider {
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
    required String confirmPassword,
    required RegExp emailPattern,
    required RegExp passPattern,
  }) async {
    try {
      if (email.isEmpty && password.isEmpty) {
        throw const GenericException(code: 'Email or Password field empty');
      }
      if (!emailPattern.hasMatch(email)) {
        throw const GenericException(code: 'invalid email');
      }
      if (!passPattern.hasMatch(password)) {
        throw const GenericException(code: 'weak password');
      }
      if (password != confirmPassword) {
        throw const GenericException(code: 'Password Mismatch');
      }
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw const UserNotLoggedInException();
      }
    } on FirebaseAuthException catch (e) {
      throw GenericException(code: e.code);
    } on UserNotLoggedInException {
      throw const UserNotLoggedInException();
    } on GenericException catch (e) {
      throw GenericException(code: e.code);
    } catch (e) {
      throw GenericException(code: e.toString());
    }
  }

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
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
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

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw const UserNotLoggedInException();
    }
  }

  @override
  Future<void> sendEmailverification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw const UserNotLoggedInException();
    }
  }

  @override
  Future<void> initializeApp() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
  Stream<AuthUser?> onUserChanges() async* {
    await for (var i in FirebaseAuth.instance.userChanges()) {
      if (i == null) {
        yield null;
      } else {
        yield AuthUser.fromFirebase(i);
      }
    }
  }
}
