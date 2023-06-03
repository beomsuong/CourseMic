// import 'package:flutter/material.dart';
// import 'view_important_message.dart';

// class simpleImportantMessage extends StatelessWidget {
//   const simpleImportantMessage({Key? key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: <Widget>[
//           Row(
//             children: [
//               Text('중요한 대화 일시 / (대충 개수)'),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) =>
//                             ImportantMessagesPage(roomname: roomname)), //받아오는지 확인 필요
//                   );
//                 },
//                 child: Text('+ 전체 모아보기'),
//               ),
//               Container(
//                 width: 500,
//                 height: 1,
//                 color: Colors.purple,
//               ),
//               ListView.builder(
//                 //이 요소가 viewImportantMEssage처럼 반복해서 나와야함
//                 itemCount: ,
//                 children: [
//                   Column(
//                     children: [
//                       Container(
//                           //대충 날짜랑 이 날짜에 있는 중요한 메시지 개수
//                           ),
//                       Container(
//                           //여기에 who랑 중요한 메시지
//                           ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
