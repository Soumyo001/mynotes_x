import 'package:mynotes_x/services/auth/auth_user.dart';

abstract class CustomAuthProvider {
  Future<void> initializeApp();
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  AuthUser? get currentUser;
  Future<AuthUser> createUser({
    required String email,
    required String password,
    required String confirmPassword,
    required RegExp emailPattern,
    required RegExp passPattern,
  });
  Future<void> logOut();
  Future<void> sendEmailverification();
  Future<void> reload();
  Stream<AuthUser?> onUserChanges();
}
