import 'package:architecture_project/model/example_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../json/example_json.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  MockDocumentSnapshot mockDocumentSnapshot = MockDocumentSnapshot();

  ExampleModel mockModel = ExampleModel(
      id: mockId,
      contents: 'contents test 2',
      subContentList: const [
        ExampleSubModel(id: 1, contents: 'sub contents test 1 '),
        ExampleSubModel(id: 2, contents: 'sub contents test 2 '),
        ExampleSubModel(id: 3, contents: 'sub contents test3 '),
      ],
      createdAt: time.toDate());

  test('Example Model test', () {
    //arrange
    when(() => mockDocumentSnapshot.id).thenReturn(mockId);
    when(() => mockDocumentSnapshot.data()).thenReturn(mockJsonData);
    //act
    ExampleModel exampleModel = ExampleModel.fromFirebase(mockDocumentSnapshot);
    //assert
    expect(exampleModel.id, mockId);
    expect(exampleModel, equals(mockModel));
  });
}
