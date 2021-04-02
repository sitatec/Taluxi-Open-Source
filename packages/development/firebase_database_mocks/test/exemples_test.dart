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
