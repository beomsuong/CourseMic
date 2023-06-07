import 'package:capston/chatting/modifyrole.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capston/chatting/chat/message/message.dart';
import 'package:capston/chatting/chat/message/new_message.dart';

import 'chat/viewuserprofile.dart';

class ChatScreen extends StatefulWidget {
  final String roomID;
  const ChatScreen({Key? key, required this.roomID}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _authentication = FirebaseAuth.instance;
  late final user;
  late int userrole;
  String roomname = '';
  late List<dynamic> userList1;
  late List<Map<dynamic, dynamic>> userList = [];
  late List<dynamic> userinfo;
  @override
  void initState() {
    final authentication = FirebaseAuth.instance;
    user = authentication.currentUser;
    // TODO: implement initState
    super.initState();
  }

  Future<void> loadingdata() async {
    print(user!.uid);
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference roomRef =
        firestore.collection('exchat').doc(widget.roomID);
    DocumentSnapshot roomnameSnapshot = await roomRef.get();
    roomname = roomnameSnapshot.get('톡방이름');
    DocumentReference docRef =
        firestore.collection('exchat').doc(widget.roomID);
    DocumentSnapshot docSnapshot = await docRef.get();
    userList1 = docSnapshot.get('userList');

    userList.clear();
    for (var user1 in userList1) {
      DocumentReference docRef =
          firestore.collection('exuser').doc(user1['userID']);
      DocumentSnapshot docSnapshot = await docRef.get();

      if (user1['userID'] == user!.uid) {
        userrole = user1['role'];
        userinfo = docSnapshot.get('톡방리스트');
      }
      userList.add({
        'userID': user1['userID'],
        'username': docSnapshot.get('이름'),
        'role': user1['role']
      });
    }
    print(userList1);
  }

  late List<List<dynamic>> roomList; //톡방 이름, UID, 마지막 메시지 저장
  Widget room(String id, String name, int userrole) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Viewuserprofile(userid: id);
            },
          ),
        );
      },
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(top: 8), //톡방간 간격
          child: Row(children: [
            if (userrole == 0)
              Image.asset(
                "assets/image/logo.png",
                width: 30,
                height: 30,
                color: Colors.purple,
              )
            else if (userrole >= 16)
              Image.asset("assets/image/commander.png",
                  width: 30, height: 30, color: Colors.purple)
            else if (userrole >= 8)
              Image.asset("assets/image/explorer.png",
                  width: 30, height: 30, color: Colors.purple)
            else if (userrole >= 4)
              Image.asset(
                "assets/image/artist.png",
                width: 30,
                height: 30,
              )
            else if (userrole >= 2)
              Image.asset("assets/image/communicater.png",
                  width: 30, height: 30, color: Colors.purple)
            else if (userrole >= 1)
              Image.asset(
                "assets/image/explorer.png",
                width: 30,
                height: 30,
              ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizedBox(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, //글자 왼쪽 정렬
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                        // 톡방 제목은 굵게
                      ),
                    ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadingdata(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text(roomname),
              ),
              endDrawer: Drawer(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        children: [
                          SizedBox(
                            child: Text(
                              roomname,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Row(children: [
                            const SizedBox(
                              child: Text(
                                '코드: ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(
                              child: Text(
                                widget.roomID.substring(0, 4),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ]),
                          const Divider(
                            thickness: 0.5,
                            height: 1,
                            color: Color.fromARGB(255, 138, 138, 138),
                          ),
                          const SizedBox(
                            child: Text(
                              '참여자',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          for (var data in userList)
                            if (data.containsKey('userID') &&
                                data.containsKey('role'))
                              room(
                                data['userID'].toString(),
                                data['username'].toString(),
                                data['role'],
                              ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.black),
                      title: const Text('역할 수정하기'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Modifyrole(
                              role: userrole,
                              roomid: widget.roomID,
                              useruid: user.uid,
                              returnuserrole: (int userrole) {
                                for (var user1 in userList1) {
                                  if (user1['userID'] == user.uid) {
                                    user1['role'] = userrole;
                                    break;
                                  }
                                }
                                FirebaseFirestore.instance
                                    .collection('exchat')
                                    .doc(widget.roomID)
                                    .update({
                                  'userList': userList1,
                                });
                                setState(() {});
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app_rounded,
                          color: Colors.red),
                      title: const Text('나가기'),
                      onTap: () {
                        userList.removeWhere(
                            (user1) => user1['userID'] == user!.uid);
                        userinfo.remove(widget.roomID);
                        FirebaseFirestore.instance
                            .collection('exchat')
                            .doc(widget.roomID)
                            .update({
                          'userList': userList,
                        });
                        FirebaseFirestore.instance
                            .collection('exuser')
                            .doc(user!.uid)
                            .update({
                          '톡방리스트': userinfo,
                        });
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              body: Container(
                child: Column(
                  children: [
                    Expanded(child: Messages(roomID: widget.roomID)),
                    NewMessage(roomname: widget.roomID),
                  ],
                ),
              ),
            );
          }
        }
      },
    );
  }
}
