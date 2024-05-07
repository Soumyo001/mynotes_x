import 'package:mynotes_x/services/auth/auth_user.dart';
import 'package:mynotes_x/services/facebook_auth/facebook_auth_provider.dart';
import 'package:mynotes_x/services/facebook_auth/firebase_facebook_auth_provider.dart';

class FAuthService implements FAuthProvider {
  final FAuthProvider authProvider;
  const FAuthService({required this.authProvider});
  factory FAuthService.firebase() =>
      FAuthService(authProvider: FirebaseFAuthProvider());

  @override
  AuthUser? get currentUser => authProvider.currentUser;

  @override
  Future<AuthUser> logIn() => authProvider.logIn();

  @override
  Future<void> logOut() => authProvider.logOut();
  @override
  Future<void> reload() => authProvider.reload();

  @override
  Future<void> sendEmailVerification() => authProvider.sendEmailVerification();

  @override
  Future<AuthUser> signUp() => authProvider.signUp();
}
