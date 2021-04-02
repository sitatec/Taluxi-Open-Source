import 'package:meta/meta.dart';

class VoIPException implements Exception {
  final String message;
  final VoIPExceptionType exceptionType;
  const VoIPException({@required this.message, @required this.exceptionType});

  const VoIPException.microphonePermissionDenied()
      : this(
          message:
              "L'accès au microphone de votre téléphone est requis pour pouvoir appeler un taxi. Veuillez appuyez sur le bouton ci-dessous puis accepter lorsqu'on vous demandera d'autoriser taluxi à accéder au microphone.",
          exceptionType: VoIPExceptionType.microphonePermissionDenied,
        );

  // TODO test if permamently denied permissions will be reseted after app reinstall.
  // TODO implements open app settings page to allows user to manually autorize the permission
  const VoIPException.microphonePermissionPermanentlyDenied()
      : this(
          message:
              "L'accès au micro par taluxi a été refusé de façon permanente, or taluxi à besoin du micro pour que vous puissiez appeler un taxi. Vous devez manuellement activé l'autorisation dans les paramètres du téléphone ou réinstaller l'application taluxi et accepter lorsqu'on vous demandera d'autoriser taluxi à utiliser le micro.",
          exceptionType:
              VoIPExceptionType.microphonePermissionPermanentlyDenied,
        );
  const VoIPException.microphonePermissionRestricted()
      : this(
          message:
              "Taluxi doit utiliser le micro du téléphone (pour pouvoir appeler un taxi lorsque vous en aurez besoin) mais n'y arrive pas, cela peut être due à des restrictions activées dans les paramètres du téléphone.",
          exceptionType: VoIPExceptionType.microphonePermissionRestricted,
        );
  //TODO translate all messages into english messages destined to developers and handle messages for users in ui side.
  const VoIPException.invalidCallId()
      : this(
          message:
              "Une erreur est survenue lors de l'appel, veuillez réessayer. Si l'erreur persiste vérifiez votre connexion internet et rédemarer l'application.",
          exceptionType: VoIPExceptionType.invalidCallId,
        );
}

enum VoIPExceptionType {
  microphonePermissionDenied,
  microphonePermissionPermanentlyDenied,
  microphonePermissionRestricted,
  invalidCallId
}
