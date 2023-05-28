import 'package:capston/message/addmessage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'chat_bubble.dart';
// import 'chat_plus_func.dart';
// import 'save_important_message.dart';

class ImportantMessagesPage extends StatelessWidget {
  final String roomname;

  const ImportantMessagesPage({Key? key, required this.roomname})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('중요한 메시지'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('exchat')
            .doc(roomname)
            .collection('imp_msg')
            .orderBy('timeStamp', descending: false) // 시간 역순으로 정렬
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data!.docs;

          // 해당 채팅방의 중요한 메시지만 필터링하여 보여줌

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;

              final messageDetail = data['msg_detail'] ?? '';
              //final messageId = data['msg_id'] ?? '';
              final sendTime = data['timeStamp'] as Timestamp;
              final userId = data['user_id'] ?? '';
              final impMsgId = documents[index].id;

              return GestureDetector(
                onLongPress: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('이 메시지에서 삭제하시겠습니까?'),
                    content: Text(messageDetail),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          print(documents[index].id);
                          deleteImpMsg(roomname, impMsgId);
                          Navigator.pop(context);
                        },
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                ),
                child: ListTile(
                  title: Text(messageDetail),
                  subtitle: Text('User ID: $userId'),
                  trailing: Text(sendTime.toDate().toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Future<void> deleteImpMsg(String roomname, String impMsgId) async {
  try {
    await FirebaseFirestore.instance
        .collection('exchat')
        .doc(roomname)
        .collection('imp_msg')
        .doc(impMsgId)
        .delete();
    print('중요한 메시지 삭제 완료!');
  } catch (error) {
    print('중요한 메시지 삭제 실패!: $error');
  }
}
