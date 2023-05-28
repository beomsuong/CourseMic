// import 'dart:math';

// import 'package:capston/chatting/chat_screen.dart';
// import 'package:capston/message.dart';
// import 'chat_plus_func.dart';
// import 'chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*
1. chat_bubble에서 메시지 -> 다이얼로그 -> 중요 누르면 실행됨
2. 해당 messages를 복사해서 파이어베이스(imp_msg)에 저장
3. important_message_list에서는 파이어베이스(imp_msg)목록을 불러와서
   시간순으로 나열해서 보여준다.
4. 쿼리가 가능하면 -> chat_plus_func의 작은 sizedbox에서 간소화해서
   불러올 수 있게 만든다.

Create
Read
Update
Delete
*/

Future<void> saveImportantMessage(String messageDetail, String messageId,
    Timestamp sendTime, String userId, String roomId) async {
  try {
    await FirebaseFirestore.instance
        .collection('exchat')
        .doc(roomId)
        .collection('imp_msg')
        .doc()
        .set({
      'msg_detail': messageDetail,
      'msg_id': messageId,
      'timeStamp': sendTime,
      'user_id': userId,
      'room_id': roomId, // roomId 값을 추가로 저장 -> 처리
    });
    print('중요한 메시지 저장 성공!');
  } catch (error) {
    print('중요한 메시지 저장 실패: $error');
  }
}
