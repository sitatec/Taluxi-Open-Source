import 'package:firebase_database_mocks/src/mock_database_reference.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MockDatabaseReference databaseReference;
  setUp(() {
    databaseReference = MockDatabaseReference();
  });

  group('Node path handling : ', () {
    test('Should work with slash as prefix', () {
      expect(
        databaseReference.child('/test').path,
        equals(MockDatabaseReference().child('test').path),
      );
    });
    test('Should work with slash as suffix', () {
      expect(
        databaseReference.child('test/').path,
        equals(MockDatabaseReference().child('test').path),
      );
    });
    test('Should work with slash as suffix', () {
      expect(
        databaseReference.child('/test/').path,
        equals(MockDatabaseReference().child('test').path),
      );
    });
    test('Should work with nested nodes', () {
      expect(
        databaseReference.child('test').child('other').path,
        equals(MockDatabaseReference().child('test/other').path),
      );
      expect(
        databaseReference
            .child('path')
            .child('mock')
            .child('test')
            .child('other')
            .path,
        equals(MockDatabaseReference().child('path/mock/test/other').path),
      );
    });
    test('Should return null when a nonexistent path is given', () async {
      expect(
        (await databaseReference.child('fghgg').once()).value,
        isNull,
      );
      expect(
        (await databaseReference.child('o_/therèè_/Test').once()).value,
        isNull,
      );
    });

    group('Should return null when a nonexistent path that', () {
      test('starts with existent node path is given', () async {
        await databaseReference.child('existing_path').set('value');
        expect(
          (await databaseReference.child('existing_path/therèè_/Test').once())
              .value,
          isNull,
        );
      });
      test('wrap existent node path is given', () async {
        await databaseReference.child('existing_path').set('value');
        expect(
          (await databaseReference.child('any/existing_path/thè_/Tt').once())
              .value,
          isNull,
        );
        await databaseReference.child('tteesstt').set({'key': 'value'});
        expect(
          (await databaseReference.child('tttttst/path/tteesstt/Test').once())
              .value,
          isNull,
          reason: 'With Map as value',
        );
      });
      test('end with existent node path is given', () async {
        await databaseReference.child('end').set('value');
        expect(
          (await databaseReference.child('any/existing_path/Test/end').once())
              .value,
          isNull,
        );
      });

      // Todo put any expect satement inside test function.
    });

    // test('Should work when wrapped in two slash or more', () {
    //   expect(
    //     databaseReference.child('//test//').path,
    //     equals(MockDatabaseReference().child('test').path),
    //   );
    //   expect(
    //     databaseReference.child('//test///').path,
    //     equals(MockDatabaseReference().child('test').path),
    //   );
    // });
  });
  group('Work with any type of data : ', () {
    test('Should set String', () async {
      await databaseReference.child('test').set('value');
      expect(
        (await databaseReference.child('test').once()).value,
        equals('value'),
      );
      await databaseReference.child('otherTest/test').set('otherValue');
      expect(
        (await databaseReference.child('otherTest/test').once()).value,
        equals('otherValue'),
      );
    });
    test('Should set Map', () async {
      await databaseReference.child('test').set({'key': 'value'});
      expect((await databaseReference.child('test').once()).value,
          equals({'key': 'value'}));
    });

    test(
        'Should get nested Map even if the keys of maps was not set individually',
        () async {
      const nestedMap = {
        'key': {
          'nkey1': 'value1',
          'nkey2': {'otheNkey': 'nestedValue'}
        }
      };
      await databaseReference.child('tes').set(nestedMap);
      expect((await databaseReference.child('tes').once()).value,
          equals(nestedMap));

      expect(
          (await databaseReference.child('tes/key').once()).value,
          equals({
            'nkey1': 'value1',
            'nkey2': {'otheNkey': 'nestedValue'}
          }));

      expect((await databaseReference.child('tes/key/nkey1').once()).value,
          equals('value1'));

      expect((await databaseReference.child('tes/key/nkey2').once()).value,
          equals({'otheNkey': 'nestedValue'}));
    });
  });

  // group('Set data at any node reference :', null);

  group('Data persistence : ', () {
    test('Should persist data while test running', () async {
      var databaseReference = MockDatabaseReference();
      await databaseReference.child('test1').set('value1');
      await databaseReference.child('test2/test2').set('value2');
      await databaseReference.child('test1/test_one').set('value3');
      databaseReference = null;
      expect(databaseReference, isNull);

      var newDatabaseReference = MockDatabaseReference();
      expect(
        (await newDatabaseReference.child('test1').once()).value,
        equals('value1'),
      );
      print('test1 passed');
      expect(
        (await newDatabaseReference.child('test2/test2').once()).value,
        equals('value2'),
      );
      expect(
        (await newDatabaseReference.child('test1/test_one').once()).value,
        equals('value3'),
      );
    });
  });

  test('Should return a stream of data', () async {
    await databaseReference.child('streamTest').set('StreamVal');
    final stream = databaseReference.child('streamTest').onValue;
    expect((await stream.first).snapshot.value, equals('StreamVal'));
  });
  // Todo implement all dataSnapshot, dbReference and fbDatabase getters and setters if possible.

  // test(
  //     'Should not persist data if setting "persistData" of MockFirebaseData is false',
  //     () async {
  //   MockFirebaseDatabase.settings(persistData: false);
  //   var databaseReference = MockDatabaseReference();
  //   var test = databaseReference.child('test1');
  //   await test.set('value1');
  //   await databaseReference.child('test2/test2').set('value2');
  //   await databaseReference.child('test1/test_one').set('value3');
  //   expect(
  //     (await test.once()).value,
  //     equals('value1'),
  //   );
  //   databaseReference = null;
  //   expect(databaseReference, isNull);

  //   var newDatabaseReference = MockDatabaseReference();
  //   expect(
  //     (await newDatabaseReference.child('test1').once()).value,
  //     isNull,
  //   );
  //   expect(
  //     (await newDatabaseReference.child('test2/test2').once()).value,
  //     isNull,
  //   );
  //   expect(
  //     (await newDatabaseReference.child('test1/test_one').once()).value,
  //     isNull,
  //   );
  // });
}
