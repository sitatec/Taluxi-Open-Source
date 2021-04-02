class UserDataAccessException implements Exception {
  final UserDataAccessExceptionType exceptionType;
  final String message;
  const UserDataAccessException({
    this.exceptionType = UserDataAccessExceptionType.unknown,
    this.message =
        "Une Erreur est survenue lors de la récupération de vos données. Si l'erreur persiste, réessayez plus tard.",
  });
  const UserDataAccessException.unknown() : this();
}

enum UserDataAccessExceptionType { unknown }
