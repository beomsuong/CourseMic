import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class testpage extends StatelessWidget {
  const testpage({super.key});
  Future<void> fetchListFromDocument() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 최상위 컬렉션에서 하위 컬렉션까지 한 번에 지정하는 변수
    DocumentReference docRef =
        firestore.collection('chat').doc('mH2pTd2HcfRFSAO9dPVU');

    // 문서의 데이터를 가져옵니다.
    DocumentSnapshot docSnapshot = await docRef.get();

    // 문서 내부의 사람리스트 필드를 가져옵니다.
    List<dynamic> peopleList = docSnapshot.get('사람리스트');

    // 사람리스트의 첫 번째 항목을 출력합니다.
    print('First person in list: ${peopleList[0]}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('두 번째 페이지'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('두 번째 페123이지입니다.'),
            ElevatedButton(
              child: const Text('이전 페이지로 돌아가기'),
              onPressed: () {
                fetchListFromDocument();
              },
            ),
          ],
        ),
      ),
    );
  }
}
