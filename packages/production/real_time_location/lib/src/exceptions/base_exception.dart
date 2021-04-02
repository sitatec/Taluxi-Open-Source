import 'package:flutter/foundation.dart';

@immutable
abstract class BaseException<Type> implements Exception {
  final String message;
  final Type exceptionType;

  const BaseException({@required this.exceptionType, @required this.message});

  @override
  String toString() =>
      '$runtimeType :\nmessage => $message \ntype => $exceptionType';

  bool operator ==(Object other) {
    return other is BaseException<Type> &&
        other.message == message &&
        other.exceptionType == exceptionType;
  }

  @override
  int get hashCode => message.hashCode + exceptionType.hashCode;
}
