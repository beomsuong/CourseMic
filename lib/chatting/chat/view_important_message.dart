import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'chat_bubble.dart';
// import 'chat_plus_func.dart';
// import 'save_important_message.dart';

class ImportantMessagesPage extends StatelessWidget {
  final String roomId;

  const ImportantMessagesPage({Key? key, required this.roomId})
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
            .doc(roomId)
            .collection('imp_msg')
            .orderBy('timeStamp', descending: true) // 시간 역순으로 정렬
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
          final filteredDocuments =
              documents.where((doc) => doc['room_id'] == roomId).toList();

          return ListView.builder(
            itemCount: filteredDocuments.length,
            itemBuilder: (context, index) {
              final data =
                  filteredDocuments[index].data() as Map<String, dynamic>;

              final messageDetail = data['msg_detail'] ?? '';
              final messageId = data['msg_id'] ?? '';
              final sendTime = data['timeStamp'] as Timestamp;
              final userId = data['user_id'] ?? '';

              return ListTile(
                title: Text(messageDetail),
                subtitle: Text('ID: $messageId, User ID: $userId'),
                trailing: Text(sendTime.toDate().toString()),
              );
            },
          );
        },
      ),
    );
  }
}

//TODO: roomID처리