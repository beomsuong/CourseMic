import 'package:flutter/material.dart';
import 'package:capston/chatting/chat/chat_list.dart';
import 'mypage/mypage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class GradientText extends StatelessWidget {
  const GradientText({super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      'CourseMic',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        foreground: Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Color.fromARGB(142, 141, 5, 187)],
          ).createShader(
            const Rect.fromLTWH(50.0, 0.0, 200.0, 0.0),
          ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    //각 페이지 이동 시 사용하는 리스트형 위젯 각 페이지 클래스를 실행한다
    // ChatScreen(),
    const RoomList(),
    const Mypage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.messenger_outline),
            label: '채팅방',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
