import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ExampleModel extends Equatable {
  final String id;
  final String contents;
  final List<ExampleSubModel> subContentList;
  final DateTime createdAt;

  const ExampleModel(
      {required this.id,
      required this.contents,
      required this.subContentList,
      required this.createdAt});

  //! fromJson이라면 서버에서 이미 처리 다한 json만 읽으면 된다. (깔끔하다.)
  //! 현재는 firestore를 사용하기에 당장 사용 불가능.
  // factory ExampleModel.fromJson(Map<String, dynamic> json) {
  //   return ExampleModel(
  //       id: json['id'],
  //       contents: json['contents'],
  //       subContentList:
  //           json['sub_content_list'].map((e) => ExampleSubModel.fromJson(e)).toList(),
  //       createdAt: (json['created_at'] as Timestamp).toDate());
  // }

  //! 하지만 firebase는 컬랙션 구조에 따라 따로 추가 호출해서 넣어주어야 한다.
  //! 현재는 restAPI처럼 내부 map형식으로 firebase를 만들어놔서 아래와 같이 진행이 가능하다.
  factory ExampleModel.fromFirebase(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;

    //! Dart에서 nullSafety가 적용된 뒤로 dynamic 타입의 에러가 많이 발생함.
    //! 아래와 같이 json['sub_content_list']에는 Map형식이 List로 들어가 있음.
    //! 그러나 firestore에서 읽어오면 dart에서는 list<Map>이 아니라 list<dynamic>으로 인식해버림
    //! dynamic을 Map으로 쓰려고 하면 에러가 발생
    //! 그래서 아래와 같이 cast를 통해 내용물들을 Map<String, dynamic>으로 바꿔준 뒤 toList로 list화 시킴.
    List<Map<String, dynamic>> contentJsonList =
        json['sub_content_list']?.cast<Map<String, dynamic>>().toList();

    return ExampleModel(
        //? firebase에서 각 document마다 고유한 id값이 있음, 이 아이디는 DocumentSnapshot에서 id로 접근 가능.
        // id: json['id'], => 디비에 넣어놨기 때문에 이렇게 해도 문제 없으나 DocumentSnapshot id를 보여주기 위해 아래처럼 코딩
        id: doc.id,
        contents: json['contents'],
        //! 만약 subContentList가 내부 컬랙션이였으면 ?
        //! doc.reference.collection('sub_collection').get(); =>한걸 list화 해서 넣어주어야 한다.
        subContentList:
            contentJsonList.map((e) => ExampleSubModel.fromJson(e)).toList(),
        createdAt: (json['created_at'] as Timestamp).toDate());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contents': contents,
      //! 일반적인 restapi라면 아래와 같이 해서 보내주면 된다.
      //! 하지만 firestore는 서브컬랙션이냐에 따라서 로직이 복잡해진다.
      'sub_content_list': subContentList.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [id, contents, subContentList, createdAt];
}

class ExampleSubModel extends Equatable {
  final int id;
  final String contents;

  const ExampleSubModel({required this.id, required this.contents});

  factory ExampleSubModel.fromJson(Map<String, dynamic> json) {
    return ExampleSubModel(id: json['id'], contents: json['contents']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contents': contents,
    };
  }

  @override
  List<Object?> get props => [id, contents];
}
