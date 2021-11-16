import 'package:architecture_project/core/failure.dart';
import 'package:architecture_project/model/example_model.dart';
import 'package:architecture_project/repository/example_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../json/example_json.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  MockFirebaseFirestore mockFirebaseFirestore = MockFirebaseFirestore();
  MockCollectionReference mockCollectionReference = MockCollectionReference();
  MockDocumentReference mockDocumentReference = MockDocumentReference();
  MockDocumentSnapshot mockDocumentSnapshot = MockDocumentSnapshot();
  MockQuerySnapshot mockQuerySnapshot = MockQuerySnapshot();
  MockQueryDocumentSnapshot mockQueryDocumentSnapshot =
      MockQueryDocumentSnapshot();

  ExampleRepository exampleRepository =
      ExampleRepository(firestore: mockFirebaseFirestore);

  setUp(() {
    when(() => mockFirebaseFirestore.collection(any()))
        .thenReturn(mockCollectionReference);
    when(() => mockCollectionReference.doc(any()))
        .thenReturn(mockDocumentReference);
    when(() => mockCollectionReference.get())
        .thenAnswer((invocation) async => mockQuerySnapshot);

    when(() => mockDocumentReference.id).thenReturn(mockId);
    when(() => mockDocumentReference.get())
        .thenAnswer((invocation) async => mockDocumentSnapshot);

    //! 임시로 3개 반환으로 함.
    when(() => mockQuerySnapshot.docs).thenReturn([
      mockQueryDocumentSnapshot,
      mockQueryDocumentSnapshot,
      mockQueryDocumentSnapshot
    ]);

    when(() => mockDocumentSnapshot.id).thenReturn(mockId);
    when(() => mockDocumentSnapshot.data()).thenReturn(mockJsonData);

    when(() => mockQueryDocumentSnapshot.id).thenReturn(mockId);
    when(() => mockQueryDocumentSnapshot.data()).thenReturn(mockJsonData);
  });

  group('getAllExampleModel', () {
    test('getAllExampleModel - 성공', () async {
      //arrange
      ExampleModel mockModel =
          ExampleModel.fromFirebase(mockQueryDocumentSnapshot);

      //act
      Either<Failure, List<ExampleModel>> either =
          await exampleRepository.getAllExampleModel();
      var result = either.fold((l) => l, (r) => r);

      //assert
      expect(either.isLeft(), false);
      expect(either.isRight(), true);
      expect(result, equals([mockModel, mockModel, mockModel]));
    });

    test('getAllExampleModel - 서버 실패', () async {
      //arrange
      when(() => mockCollectionReference.get()).thenThrow(Exception());

      //act
      Either<Failure, List<ExampleModel>> either =
          await exampleRepository.getAllExampleModel();
      var result = either.fold((l) => l, (r) => r);

      //assert
      expect(either.isLeft(), true);
      expect(either.isRight(), false);
      expect(result, isInstanceOf<Failure>());
    });
    test('getAllExampleModel - 데이터 없음', () async {
      //arrange
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      //act
      Either<Failure, List<ExampleModel>> either =
          await exampleRepository.getAllExampleModel();
      var result = either.fold((l) => l, (r) => r);

      //assert
      expect(either.isLeft(), false);
      expect(either.isRight(), true);
      expect(result, equals([]));
    });
  });
}
