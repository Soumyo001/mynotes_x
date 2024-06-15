import 'package:mynotes_x/services/auth/auth_exceptions.dart';
import 'package:mynotes_x/services/auth/auth_user.dart';
import 'package:test/test.dart';
import 'package:mynotes_x/services/auth/auth_provider.dart';

void main() {
  group(
    'Mock Authentication',
    () {
      final provider = MockAuthProvider();
      test(
        'should not be initialized',
        () {
          expect(
            provider.initialized,
            false,
          );
        },
      );
      test(
        'Cannot log out if not initialized',
        () {
          expect(
            provider.logOut(),
            throwsA(
              const TypeMatcher<NotInitializedException>(),
            ),
          );
        },
      );
      test(
        'initialized function should return true after calling initializeApp',
        () async {
          await provider.initializeApp();
          expect(
            provider.initialized,
            true,
          );
        },
      );
      test(
        'user should be null after initialization',
        () {
          expect(
            provider.currentUser,
            null,
          );
        },
      );
      test(
        'should be able to initialize in less than 2 minitues',
        () async {
          await provider.initializeApp();
          expect(
            provider.initialized,
            true,
          );
        },
        timeout: const Timeout(
          Duration(
            seconds: 2,
          ),
        ),
      );
      test(
        'create user function should delegate to login function',
        () async {
          final wrongEmailUser = provider.createUser(
            email: 'mrx@gmail.com',
            password: 'password',
            confirmPassword: 'password',
            emailPattern: RegExp(
                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$"),
            passPattern: RegExp(
              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\da-zA-Z]).{8,}$',
              caseSensitive: false,
              multiLine: false,
            ),
          );
          expect(
            wrongEmailUser,
            throwsA(
              const TypeMatcher<UserNotFoundException>(),
            ),
          );
          final weakPassUser = provider.createUser(
            email: 'mr@abc.com',
            password: '123456',
            confirmPassword: '123456',
            emailPattern: RegExp(
                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$"),
            passPattern: RegExp(
              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\da-zA-Z]).{8,}$',
              caseSensitive: false,
              multiLine: false,
            ),
          );
          expect(
            weakPassUser,
            throwsA(
              const TypeMatcher<WeakPasswordException>(),
            ),
          );
          final actualUser = await provider.createUser(
            email: 'email',
            password: 'password',
            confirmPassword: 'password',
            emailPattern: RegExp(
              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
            ),
            passPattern: RegExp(
              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\da-zA-Z]).{8,}$',
              caseSensitive: false,
              multiLine: false,
            ),
          );
          expect(
            provider.currentUser,
            actualUser,
          );
          expect(
            !(provider.currentUser!.isEmailVerified ||
                actualUser.isEmailVerified),
            true,
          );
        },
      );
      test(
        'logged in user should be able to verify email',
        () async {
          await provider.sendEmailverification();
          expect(
            provider.currentUser,
            isNotNull,
          );
          expect(
            provider.currentUser!.isEmailVerified,
            true,
          );
        },
      );
      test(
        'user should be able to logout and login agian',
        () async {
          await provider.logOut();
          expect(
            provider.currentUser,
            isNull,
          );
          await provider.logIn(
            email: 'email',
            password: 'password',
          );
          expect(
            provider.currentUser,
            isNotNull,
          );
        },
      );
    },
  );
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements CustomAuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  String _userEmail = '';
  bool get initialized => _isInitialized;
  Stream<AuthUser?> onUserChange() async* {
    while (true) {
      yield _user;
    }
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
    required String confirmPassword,
    required RegExp emailPattern,
    required RegExp passPattern,
  }) async {
    if (!_isInitialized) throw NotInitializedException();
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initializeApp() async {
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized) throw NotInitializedException();
    if (email == 'mrx@gmail.com') {
      throw UserNotFoundException();
    }
    if (password == '123456') {
      throw WeakPasswordException();
    }
    final user = AuthUser(
      isEmailVerified: false,
      email: email,
    );
    _userEmail = email;
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!_isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw const GenericException(code: 'user-not-found');
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );
    _user = null;
  }

  @override
  Stream<AuthUser?> onUserChanges() async* {
    await for (var i in onUserChange()) {
      if (i == null) {
        yield null;
      } else {
        yield i;
      }
    }
  }

  @override
  Future<void> reload() async {
    if (!_isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw const GenericException(code: 'user-bot-found');
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );
  }

  @override
  Future<void> sendEmailverification() async {
    if (!_isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw const GenericException(code: 'user-not-found');
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );
    final newUser = AuthUser(
      isEmailVerified: true,
      email: _userEmail,
    );
    _user = newUser;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (!_isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw const GenericException(code: 'user-not-found');
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );
  }

  @override
  Future<void> deleteAccount() async {
    if (!_isInitialized) throw NotInitializedException();
    var user = _user;
    if (user == null) throw const GenericException(code: 'user-not-found');
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );
    user = null;
    _user = null;
  }
}
