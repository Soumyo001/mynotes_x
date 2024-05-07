import 'package:mynotes_x/services/auth/auth_user.dart';

abstract class FAuthProvider {
  Future<AuthUser> logIn();
  Future<AuthUser> signUp();
  Future<void> sendEmailVerification();
  Future<void> reload();
  Future<void> logOut();
  AuthUser? get currentUser;
}
