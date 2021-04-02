# firebase_database_mocks

[![Pub Version](https://img.shields.io/pub/v/firebase_database_mocks)](https://pub.dev/packages/firebase_database_mocks) [![style: effective dart](https://img.shields.io/badge/style-pedantic-blue)](https://github.com/google/pedantic) [![test: passing](https://img.shields.io/badge/test-passing-green)](https://github.com/sitatec/firebase_database_mocks/tree/main/test)

Mocks library to write unit tests for FirebaseDatabase (real-time database). Get Instance
`MockFirebaseDatabase.instance`, then pass it around your project as if it were a
`FirebaseDatabase.instance`. This mock keep data in memory while test running.

## Usage
```dart
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

class UserRepository {
  UserRepository(this.firebaseDatabase);
  FirebaseDatabase firebaseDatabase;

  Future<String> getUserName(String userId) async {
    final userNameReference =
        firebaseDatabase.reference().child('users').child(userId).child('name');
    final dataSnapshot = await userNameReference.once();
    return dataSnapshot.value;
  }

  Future<Map<String, dynamic>> getUser(String userId) async {
    final userNode = firebaseDatabase.reference().child('users/$userId');
    final dataSnapshot = await userNode.once();
    return dataSnapshot.value;
  }
}

void main() {
  FirebaseDatabase firebaseDatabase;
  UserRepository userRepository;
  // Put fake data
  const userId = 'userId';
  const userName = 'Elon musk';
  const fakeData = {
    'users': {
      userId: {
        'name': userName,
        'email': 'musk.email@tesla.com',
        'photoUrl': 'url-to-photo.jpg',
      },
      'otherUserId': {
        'name': 'userName',
        'email': 'othermusk.email@tesla.com',
        'photoUrl': 'other_url-to-photo.jpg',
      }
    }
  };
  MockFirebaseDatabase.instance.reference().set(fakeData);
  setUp(() {
    firebaseDatabase = MockFirebaseDatabase.instance;
    userRepository = UserRepository(firebaseDatabase);
  });
  test('Should get userName ...', () async {
    final userNameFromFakeDatabase = await userRepository.getUserName(userId);
    expect(userNameFromFakeDatabase, equals(userName));
  });

  test('Should get user ...', () async {
    final userNameFromFakeDatabase = await userRepository.getUser(userId);
    expect(
      userNameFromFakeDatabase,
      equals({
        'name': userName,
        'email': 'musk.email@tesla.com',
        'photoUrl': 'url-to-photo.jpg',
      }),
    );
  });
}

```

As you can see you don't need to initialize firabase core for testing or call
`TestWidgetsFlutterBinding.ensureInitialized()` before using `MockFirebaseDatabase`
but in bonus if you use anther firebase service which need it you can simply call
the `setupFirebaseMocks()` top level function which performs all required operations 
for testing a firebase service which isn't fully mocked like `MockFirebaseDatabase`.


- [Issues](https://github.com/sitatec/firebase_database_mocks/issues)
- [Pull requests](https://github.com/sitatec/firebase_database_mocks/pulls)

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
