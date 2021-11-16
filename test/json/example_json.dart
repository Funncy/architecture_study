import 'package:cloud_firestore/cloud_firestore.dart';

const String mockId = 'mock Id';
final Timestamp time = Timestamp.now();

Map<String, dynamic> mockJsonData = {
  'id': mockId,
  'contents': 'contents test 2',
  'sub_content_list': [
    {'id': 1, 'contents': 'sub contents test 1 '},
    {'id': 2, 'contents': 'sub contents test 2 '},
    {'id': 3, 'contents': 'sub contents test3 '}
  ],
  'created_at': time,
};
