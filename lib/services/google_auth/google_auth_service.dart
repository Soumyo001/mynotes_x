import 'package:mynotes_x/services/auth/auth_user.dart';
import 'package:mynotes_x/services/google_auth/firebase_google_auth_provider.dart';
import 'package:mynotes_x/services/google_auth/google_auth_provider.dart';

class GAuthService implements GAuthProvider {
  final GAuthProvider authProvider;
  const GAuthService({required this.authProvider});
  factory GAuthService.firebase() =>
      GAuthService(authProvider: FirebaseGAuthProvider());
  @override
  AuthUser? get currentUser => authProvider.currentUser;

  @override
  Future<AuthUser> signIn() => authProvider.signIn();

  @override
  Future<void> signOut() => authProvider.signOut();

  @override
  Future<AuthUser> signUp() => authProvider.signUp();

  @override
  Future<void> reload() => authProvider.reload();

  @override
  Future<void> sendEmailVerification() => authProvider.sendEmailVerification();
}
