import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:capston/chatting/chat/chat_user.dart';

class AddChat extends StatefulWidget {
  const AddChat({
    Key? key,
  }) : super(key: key);

  @override
  State<AddChat> createState() => _AddChatState();
}

String roomname = '';

class _AddChatState extends State<AddChat> {
  Future<DocumentSnapshot> loadingdata(
      String datatype, String universistyname) async {
    final authentication = FirebaseAuth.instance;
    final user = authentication.currentUser;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference docRef = firestore.collection('user').doc(user?.uid);
    DocumentSnapshot docSnapshot = await docRef.get();
    await docRef.update({datatype: universistyname});
    return docSnapshot;
  }

// Add chatting room
  void addroom() async {
    // 입력된 문자가 없을 경우 리턴
    if (roomname.isEmpty) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference chatColRef = firestore.collection('chat');
    final authentication = FirebaseAuth.instance;
    final user = authentication.currentUser;

    // add user to chatting room field
    chatColRef.add({
      'roomName': roomname,
      'commanderID': '',
      'userList': <Map<String, dynamic>>[ChatUser(userID: user!.uid).toJson()],
    }).then((DocumentReference doc) {
      CollectionReference userColRef = firestore.collection('user');

      userColRef.doc(user.uid).update({
        'chatList': FieldValue.arrayUnion([doc.id]),
      }).then((value) {
        print("Value Added to Array");
      }).catchError((error) {
        print("Failed to add value to array: $error");
      });
      print("Document Added, ID: ${doc.id}"); // 문서의 ID를 출력합니다.
    }).catchError((error) {
      print("Failed to add document: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("톡방 생성",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 20)),
                  IconButton(
                      color: Colors.white,
                      iconSize: 30,
                      onPressed: () {
                        addroom();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("톡방 이름 :",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 20)),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // 버튼 배경색 지정
                    ),
                    child: SizedBox(
                      width: 150,
                      height: 30,
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            roomname = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            )
          ],
        ));
  }
}
