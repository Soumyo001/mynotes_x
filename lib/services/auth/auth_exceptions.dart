class GenericException implements Exception {
  final String code;
  const GenericException({required this.code});
}

class UserNotLoggedInException implements Exception {
  final String code = "user-not-logged-in";
  const UserNotLoggedInException();
}

class NoEmailChoosenException implements Exception {
  const NoEmailChoosenException();
}

class UserNotFoundException implements Exception {}

class WeakPasswordException implements Exception {}
