//톡방을 검색해서 들어가기

import 'package:capston/chatting/chat/chat.dart';
import 'package:capston/chatting/chat/chat_list.dart';
import 'package:capston/chatting/chat/message/log.dart';
import 'package:capston/palette.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:capston/chatting/chat/chat_user.dart';

class SearchChat extends StatefulWidget {
  final ChatListState chatListParent;
  const SearchChat({super.key, required this.chatListParent});

  @override
  State<SearchChat> createState() => _SearchChatState();
}

class _SearchChatState extends State<SearchChat> {
  bool bButton = false;
  bool bInSearchedChat = false;
  bool bFind = false;

  String userInput = '';
  String roomID = '';
  Chat? searchedChat;

  void searchChat(String shortRoomCode) async {
    //유저가 코드를 입력했을 때 실행
    QuerySnapshot querySnapshot =
        await widget.chatListParent.firestore.collection('chat').get();
    for (var doc in querySnapshot.docs) {
      if (shortRoomCode == doc.id.substring(0, 4)) {
        searchedChat = Chat.fromJson(doc);
        roomID = doc.id;
        if (searchedChat!.getIndexOfUser(
                userID: widget.chatListParent.currentUser.uid) !=
            -1) {
          setState(() {
            bFind = true;
            bInSearchedChat = true;
            bButton = false;
          });
          return;
        }

        setState(() {
          bFind = true;
          bInSearchedChat = false;
          bButton = true;
        });
        return;
      }
    }

    setState(() {
      bFind = false;
      bInSearchedChat = false;
      bButton = false;
    });
  }

  void addRoom() {
    //해당 톡방을 유저에게 추가
    widget.chatListParent.currUserDocRef.update({
      'chatList': FieldValue.arrayUnion([roomID]),
    });

    // add user into userList field
    widget.chatListParent.firestore.collection('chat').doc(roomID).update({
      'userList': FieldValue.arrayUnion(
          [ChatUser(userID: widget.chatListParent.currentUser.uid).toJson()])
    });
    addEnterEventLog(
        roomID: roomID, uid: widget.chatListParent.currentUser.uid);
    FirebaseMessaging.instance.subscribeToTopic(roomID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
          ),
          toolbarHeight: 100.0,
          title: const Text(
            "톡방 검색",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                        hintText: '4 자리 코드를 입력하세요',
                        hintStyle: TextStyle(color: Palette.textColor1)),
                    onChanged: (value) {
                      userInput = value;
                    })),
            IconButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                searchChat(userInput);
              },
              icon: const Icon(
                Icons.search_rounded,
                color: Palette.pastelPurple,
                size: 30,
              ), // 원하는 아이콘을 선택합니다.
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            color: Palette.pastelYellow,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    "검색된 채팅방 정보",
                    style: TextStyle(
                      color:
                          bInSearchedChat ? Palette.pastelBlack : Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 25,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  bFind
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end, // 오른쪽 정렬
                                      children: [
                                        SizedBox(
                                          width: 120,
                                          height: 35,
                                          child: Text(
                                            "채팅방 이름 :",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: bInSearchedChat
                                                  ? Palette.pastelWarning
                                                  : Palette.pastelBlack,
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
                                              color: bInSearchedChat
                                                  ? Palette.pastelWarning
                                                  : Palette.pastelBlack,
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
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 35,
                                        child: Text(
                                          searchedChat != null
                                              ? searchedChat!.roomName
                                              : " ",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: bInSearchedChat
                                                ? Palette.pastelWarning
                                                : Palette.pastelBlack,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        height: 35,
                                        child: Text(
                                          searchedChat != null
                                              ? "${searchedChat!.userList.length} 명"
                                              : ' ',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: bInSearchedChat
                                                ? Palette.pastelWarning
                                                : Palette.pastelBlack,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ])
                      : const Text("해당 채팅방을 찾을 수 없습니다."),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                        bFind && bInSearchedChat ? "이미 검색한 채팅방에 속해있습니다." : " ",
                        style: const TextStyle(
                            color: Palette.pastelError,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: bButton
              ? () {
                  addRoom();
                  Navigator.of(context).pop();
                }
              : null,
          child: Text(
            bInSearchedChat ? "입장불가" : "입장",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ]),
    );
  }
}
