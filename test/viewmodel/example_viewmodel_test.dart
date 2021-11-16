import 'package:architecture_project/core/failure.dart';
import 'package:architecture_project/core/view_state.dart';
import 'package:architecture_project/model/example_model.dart';
import 'package:architecture_project/repository/example_repository.dart';
import 'package:architecture_project/viewmodel/example_viewmodel.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExampleRepository extends Mock implements ExampleRepository {}

void main() {
  late MockExampleRepository mockExampleRepository = MockExampleRepository();
  ExampleViewModel exampleViewModel =
      ExampleViewModel(repository: mockExampleRepository);

  group('example test', () {
    List<ExampleModel> mockData = [
      ExampleModel(
          id: '1',
          contents: 'test 1',
          subContentList: const [
            ExampleSubModel(id: 1, contents: 'sub test 1'),
            ExampleSubModel(id: 2, contents: 'sub test 2'),
          ],
          createdAt: DateTime.now()),
      ExampleModel(
          id: '2',
          contents: 'test 2 ',
          subContentList: const [
            ExampleSubModel(id: 3, contents: 'sub test 3'),
            ExampleSubModel(id: 4, contents: 'sub test 4'),
          ],
          createdAt: DateTime.now()),
      ExampleModel(
          id: '3',
          contents: 'test 2',
          subContentList: const [
            ExampleSubModel(id: 5, contents: 'sub test 5'),
            ExampleSubModel(id: 6, contents: 'sub test 6'),
          ],
          createdAt: DateTime.now()),
    ];
    test('getExampleList - 성공', () async {
      //arrange
      when(() => mockExampleRepository.getAllExampleModel())
          .thenAnswer((invocation) async => Right(mockData));

      //act
      await exampleViewModel.getExampleList();

      //assert
      expect(exampleViewModel.exampleList, equals(mockData));
      expect(exampleViewModel.viewState, isInstanceOf<Loaded>());
      verify(() => mockExampleRepository.getAllExampleModel()).called(1);
      verifyNoMoreInteractions(mockExampleRepository);
    });

    test('getExampleList - 실패', () async {
      //arrange
      when(() => mockExampleRepository.getAllExampleModel())
          .thenAnswer((invocation) async => Left(Failure()));

      //act
      await exampleViewModel.getExampleList();

      //assert
      expect(exampleViewModel.viewState, isInstanceOf<Error>());
      verify(() => mockExampleRepository.getAllExampleModel()).called(1);
      verifyNoMoreInteractions(mockExampleRepository);
    });
  });
}
