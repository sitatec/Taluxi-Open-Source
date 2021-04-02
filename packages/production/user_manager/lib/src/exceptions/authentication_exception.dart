import 'package:meta/meta.dart';

class AuthenticationException implements Exception {
  final AuthenticationExceptionType exceptionType;
  final String message;
  const AuthenticationException(
      {@required this.exceptionType, @required this.message});

  const AuthenticationException.unknown()
      : this(
          exceptionType: AuthenticationExceptionType.unknown,
          message:
              "Une erreur critique est survenue lors de l'authantification.Veuillez réessayer, si l'erreur persiste veuillez redémarrer l'application.",
        );

  const AuthenticationException.invalidVerificationCode()
      : this(
          exceptionType: AuthenticationExceptionType.invalidVerificationCode,
          message:
              'Le code que vous avez saisie ne correspond pas à celui que nous vous avons envoyé.',
        );

  const AuthenticationException.emailAlreadyUsed()
      : this(
          exceptionType: AuthenticationExceptionType.emailAlreadyUsed,
          message:
              "L'adresse email que vous avez saisie est déjà liée à un compte",
        );

  const AuthenticationException.weakPassword()
      : this(
          exceptionType: AuthenticationExceptionType.weakPassword,
          message: 'Le mot de passe que vous avez saisie est trop faible.',
        );

  const AuthenticationException.invalidEmail()
      : this(
          exceptionType: AuthenticationExceptionType.invalidEmail,
          message: 'Adresse email invalid.',
        );

  const AuthenticationException.userDisabled()
      : this(
          exceptionType: AuthenticationExceptionType.userDisabled,
          message:
              'Votre compte a été temporairement désactivé, si vous ne connaissez pas les raisons pour lesquelles votre compte a été désactivé veuillez nous contacter (taluxi.gn@gmail.com) pour plus d\'informations.',
        );

  const AuthenticationException.userNotFound()
      : this(
          exceptionType: AuthenticationExceptionType.userNotFound,
          message:
              "L'adresse email que vous avez saisie ne correspond à aucun compte existant. S'il vous plaît veuillez saisir la bonne adresse email ou créez un nouveaux compte si vous n'êtes pas déjà inscrit.",
        );

  const AuthenticationException.wrongPassword()
      : this(
          exceptionType: AuthenticationExceptionType.wrongPassword,
          message: 'Mot de passe incorrect.',
        );

  const AuthenticationException.invalidCredential()
      : this(
          exceptionType: AuthenticationExceptionType.invalidCredential,
          message:
              "Nous n'avons pas pu obtenir l'autorisation de vous connecter à l'aide de votre compte facebook. Veuillez vous assurez que vous n'avez pas désactivé l'autorisation de Taluxi sur les paramètres de votre compte facebook.",
        );

  const AuthenticationException.accountExistsWithDifferentCredential()
      : this(
          exceptionType:
              AuthenticationExceptionType.accountExistsWithDifferentCredential,
          message:
              "Un conflit d'identifiants est survenu. Ce type d'erreur peut arriver si vous avez créer un compte Taluxi avec une adresse email et que vous tentez par la suite de vous connecter avec un compte facebook qui est lié à cette adresse email, dans ce cas vous devez vous connecter en saisissant votre email et mot de passe au lieu de tenter de vous connecter avec votre compte facebook.",
        );

  const AuthenticationException.facebookLoginFailed()
      : this(
          exceptionType: AuthenticationExceptionType.facebookLoginFailed,
          message:
              "La connexion à l'aide de votre compte facebook à échouer, veuillez réessayer. Si on vous affiche une page de connexion facebook, connectez vous de la même façon dont vous avez l'habitude de le faire pour vous connecter à votre compte facebook.",
        );
  const AuthenticationException.tooManyRequests()
      : this(
            exceptionType: AuthenticationExceptionType.tooManyRequests,
            message: 'Trop de tentative, veuillez réessayer plus tard.');
}

enum AuthenticationExceptionType {
  unknown,
  invalidVerificationCode,
  emailAlreadyUsed,
  weakPassword,
  invalidEmail,
  userDisabled,
  userNotFound,
  wrongPassword,
  invalidCredential,
  accountExistsWithDifferentCredential,
  facebookLoginFailed,
  tooManyRequests
}
