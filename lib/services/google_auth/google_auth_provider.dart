import 'package:mynotes_x/services/auth/auth_user.dart';

abstract class GAuthProvider {
  Future<AuthUser> signUp();
  Future<AuthUser> signIn();
  Future<void> signOut();
  Future<void> sendEmailVerification();
  Future<void> reload();
  AuthUser? get currentUser;
}
