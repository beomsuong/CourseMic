import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capston/chatting/chat/chat_user.dart';

class SearchChat extends StatefulWidget {
  const SearchChat({super.key});

  @override
  State<SearchChat> createState() => _SearchChatState();
}

class _SearchChatState extends State<SearchChat> {
  String groupname = '';
  List<dynamic> groupmember = [];
  String groupmessage = '';
  bool btn = false;
  String userinput = '';
  String roomcode = '';
  late final user;
  late final firebase;
  searchdata(String a) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await firestore.collection('exchat').get();

    for (var doc in querySnapshot.docs) {
      if (a == doc.id.substring(0, 4)) {
        print(doc['톡방이름'].toString());
        groupname = doc['톡방이름'].toString();
        groupmember = doc['userList'];

        DocumentReference docRef = firestore.collection('exchat').doc(doc.id);
        DocumentSnapshot docSnapshot = await docRef.get();
        groupmember = docSnapshot.get('userList');

        final chatDocsSnapshot = await FirebaseFirestore.instance
            .collection('exchat')
            .doc(doc.id)
            .collection('message')
            .orderBy('time', descending: true)
            .limit(1)
            .get();
        roomcode = doc.id;
        if (chatDocsSnapshot.docs.isNotEmpty) {
          Timestamp timestamp = chatDocsSnapshot.docs[0]['time'];
          DateTime dateTime = timestamp.toDate();
          String formattedDate = DateFormat('M월d일').format(dateTime);
          groupmessage = formattedDate;
        }
        for (var member in groupmember) {
          if (member['userID'] == user!.uid) {
            setState(() {});
            return;
          }
        }
        btn = true;
        setState(() {});
        return;
      }
    }
    btn = false;
    setState(() {});
  }

  @override
  void initState() {
    final authentication = FirebaseAuth.instance;
    user = authentication.currentUser;
    // TODO: implement initState
    super.initState();
  }

  addroom() async {
    final authentication = FirebaseAuth.instance;
    final firebase = FirebaseFirestore.instance;
    final user = authentication.currentUser;
    await firebase.collection('exuser').doc(user!.uid).update({
      '톡방리스트': FieldValue.arrayUnion([roomcode]),
    });

    // add user into userList field
    firebase.collection('exchat').doc(roomcode).update({
      'userList': FieldValue.arrayUnion([ChatUser(userID: user.uid).toJson()])
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 30,
          ),
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 100.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 3.0,
                  width: 150.0,
                  color: Colors.black,
                ),
                const Text(
                  "톡방 검색",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 3.0),
                Container(
                  height: 3.0,
                  width: 150.0,
                  color: Colors.black,
                ),
              ],
            ),
            const SizedBox(width: 60),
          ],
        ),
      ),
      body: Column(children: [
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 30,
            ),
            SizedBox(
                width: 200,
                child: TextField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: '코드를 입력하세요',
                    ),
                    onChanged: (value) {
                      userinput = value;
                    })),
            IconButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                searchdata(userinput);
              },
              icon: const Icon(
                Icons.search,
                color: Colors.purple,
                size: 30,
              ), // 원하는 아이콘을 선택합니다.
            ),
          ],
        ),
        Container(
            width: 370,
            height: 400,
            margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 6, // 선의 굵기 설정
              ),
              borderRadius: BorderRadius.circular(20), // 둥근 정도 설정
            ),
            child: Column(
              children: [
                const Text(
                  "선택한 톡방 정보",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 2.0,
                  width: 250.0,
                  color: Colors.black,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                          children: const [
                            SizedBox(
                              width: 120,
                              height: 35,
                              child: Text(
                                "그룹 이름 :",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              height: 35,
                              child: Text(
                                "현재 참가자 :",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              height: 35,
                              child: Text(
                                "최근 메시지 :",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 120,
                              height: 35,
                              child: Text(
                                groupname,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              height: 35,
                              child: Text(
                                groupmember.isNotEmpty
                                    ? groupmember.length.toString()
                                    : ' ',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              height: 35,
                              child: Text(
                                groupmessage,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: btn
                      ? () {
                          addroom();

                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 148, 61, 255), // 버튼 배경색 지정
                  ),
                  child: const Text(
                    '입장',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            )),
      ]),
    );
  }
}
