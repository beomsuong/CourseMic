import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

//erwer
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class GradientText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'CouserMic',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        foreground: Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Color.fromARGB(142, 141, 5, 187)],
          ).createShader(
            const Rect.fromLTWH(50.0, 0.0, 200.0, 70.0),
          ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    mypage(),
    const Center(child: Text('두 번째 페이지')),
    const Center(child: Text('세 번째 페이지')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GradientText(),
        centerTitle: false,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(30), //격을 줄여줍니다.
          child: IconButton(
            onPressed: null,
            icon: SizedBox(
              width: 10,
              height: 10,
              child: Image.asset(
                "assets/image/logo.png",
                fit: BoxFit.contain, // 이미지 크기를 그대로 유지합니다.
              ),
            ),
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.messenger_outline),
            label: '체팅방',
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

class mypage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              child: Text('● 내 프로필',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
            ),
          ),
          Align(
            alignment: Alignment.center, // 가운데 정렬
            child: SizedBox(
              child: Image.asset(
                "assets/image/logo.png",
                fit: BoxFit.contain, // 이미지 크기를 그대로 유지합니다.
              ),
            ),
          ),
          const SizedBox(
            child: Text(
              '이름 예정',
              style: TextStyle(
                fontSize: 30,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 30, left: 30),
              child: SizedBox(
                child: Text(
                  '기본 정보',
                  style: TextStyle(
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
