import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authenticator', () {
    final provider = MockAuthProvider();
    test('should not be initilized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('cannot log out before initialize', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('should be able to initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('user should be null after initializtion', () {
      expect(provider.currentUser, null);
    });

    test(
      'should be initialized within 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('create user should delegate to login function', () async {
      final badpersonemail = provider.createUser(
        email: 'arif@rafay.com',
        password: "anypassword",
      );
      expect(
        badpersonemail,
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );
      final badpersonpassword = provider.createUser(
        email: 'any@rafay.com',
        password: 'rafayuu',
      );
      expect(
        badpersonpassword,
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );
      final user = await provider.createUser(email: 'rafay', password: 'rafay');
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('should be able to log out and log in again', () async {
      await provider.logOut();
      await provider.showLogin(email: 'email', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return showLogin(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(
      isEmailVerified: true,
      email: 'rafay@arif.com',
      id: 'my_id',
    );
    _user = newUser;
  }

  @override
  Future<AuthUser> showLogin({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'arif@rafay.com') throw UserNotFoundAuthException();
    if (password == 'rafayuu') throw WrongPasswordAuthException();
    const user = AuthUser(
      id: 'my_id',
      email: 'arif@rafay.com',
      isEmailVerified: false,
    );
    _user = user;
    return Future.value(user);
  }
}
