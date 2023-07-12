import 'package:capston/notification.dart';
import 'package:capston/palette.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:capston/chatting/chat/chat_list.dart';
import 'mypage/profile.dart';

class MyHomePage extends StatefulWidget {
  final String currentUserID;
  const MyHomePage({super.key, required this.currentUserID});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0; //현재 보고 있는 페이지
  @override
  void initState() {
    super.initState();
    FCMLocalNotification.getMyDeviceToken().then(
      (value) {
        FirebaseFirestore.instance
            .collection('user')
            .doc(widget.currentUserID)
            .update({'deviceToken': value});
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: [
        const ChatList(), //체팅방 리스트
        Profile(
          //프로필보기
          userID: widget.currentUserID,
          bMyProfile: true,
          bChild: false,
        ),
      ]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey,
              blurRadius: 0.5,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Palette.lightGray,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                  _currentIndex == 0
                      ? Icons.messenger_rounded
                      : Icons.messenger_outline_rounded,
                  color: Palette.pastelPurple),
              label: '채팅방',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                  _currentIndex == 1
                      ? Icons.account_circle_rounded
                      : Icons.account_circle_outlined,
                  color: Palette.pastelPurple),
              label: '마이페이지',
            ),
          ],
        ),
      ),
    );
  }
}
