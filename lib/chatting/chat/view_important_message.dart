import 'package:capston/message/addmessage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final currentYear = DateTime.now().year; //실제 시간의 년도

class ImportantMessagesPage extends StatelessWidget {
  final String roomname;

  const ImportantMessagesPage({Key? key, required this.roomname})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('중요한 메시지 목록'),
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
            return const Center(child: Text('오류가 발생했습니다.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data!.docs;
          //int messageCount = documents.length;

          // 해당 채팅방의 중요한 메시지만 필터링하여 보여줌

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;

              final messageDetail = data['msg_detail'] ?? '';
              final sendTime = data['timeStamp'] as Timestamp;
              final userId = data['user_id'] ?? '';
              final impMsgId = documents[index].id;

              final dateTime = sendTime.toDate();
              late var fmtTime = DateFormat('M월 dd일 h:mm a').format(dateTime);
              final msgYear = dateTime.year;

              if (currentYear != msgYear) {
                fmtTime = DateFormat('yyyy년 M월 d일 hh:mm').format(dateTime);
              } else {
                fmtTime = DateFormat('M월 d일 h:mm a').format(dateTime);
              }

              return GestureDetector(
                onLongPress: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('이 메시지를 삭제하시겠습니까?'),
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
                  title: Text(userId),
                  subtitle: Text(messageDetail),
                  trailing: Text(fmtTime),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

//---------------------------------------------------------------------------------------------------
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

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------

class SimpleImportantMessage extends StatelessWidget {
  final String roomname;
  const SimpleImportantMessage({Key? key, required this.roomname})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('exchat')
            .doc(roomname)
            .collection('imp_msg')
            .orderBy('timeStamp', descending: true) // 최근 시간 순으로 정렬
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data!.docs;

          // 해당 채팅방의 중요한 메시지만 필터링하여 보여줌

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;

              final messageDetail = data['msg_detail'] ?? '';
              final sendTime = data['timeStamp'] as Timestamp;
              final userId = data['user_id'] ?? '';
              //final impMsgId = documents[index].id;
              final forSimpleMsg = '$userId : $messageDetail';
              final dateTime = sendTime.toDate();
              final fmtTime = DateFormat('M/d').format(dateTime);

              return ListTile(
                title: Text(
                  forSimpleMsg,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                trailing: Text(fmtTime),
              );
            },
          );
        },
      ),
    );
  }
}
