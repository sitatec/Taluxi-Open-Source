import 'package:firebase_database/firebase_database.dart';
import 'package:mockito/mockito.dart';

class MockDataSnapshot extends Mock implements DataSnapshot {
  final dynamic _value;

  MockDataSnapshot(this._value);

  @override
  dynamic get value => _value;
}
