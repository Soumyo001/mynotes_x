import 'package:mynotes_x/services/auth/auth_provider.dart';
import 'package:mynotes_x/services/auth/auth_user.dart';
import 'package:mynotes_x/services/auth/firebase_auth_provider.dart';

class AuthService implements CustomAuthProvider {
  final CustomAuthProvider authProvider;
  const AuthService({required this.authProvider});
  factory AuthService.firebase() =>
      AuthService(authProvider: FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
    required String confirmPassword,
    required RegExp emailPattern,
    required RegExp passPattern,
  }) =>
      authProvider.createUser(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        emailPattern: emailPattern,
        passPattern: passPattern,
      );

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      authProvider.logIn(
        email: email,
        password: password,
      );

  @override
  AuthUser? get currentUser => authProvider.currentUser;

  @override
  Future<void> logOut() => authProvider.logOut();

  @override
  Future<void> sendEmailverification() => authProvider.sendEmailverification();

  @override
  Future<void> initializeApp() => authProvider.initializeApp();

  @override
  Future<void> reload() => authProvider.reload();

  @override
  Stream<AuthUser?> onUserChanges() => authProvider.onUserChanges();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      authProvider.sendPasswordResetEmail(email);

  @override
  Future<void> deleteAccount() => authProvider.deleteAccount();
}
