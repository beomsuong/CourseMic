import 'package:capston/chatting/chat/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String roomName;
  late String commanderID;
  late List<MyUser> userList;

  Chat(
      {required this.roomName,
      this.commanderID = '',
      this.userList = const <MyUser>[]});

  Chat.fromJson(DocumentSnapshot<Object?> json)
      : this(
          roomName: json['톡방이름'],
          commanderID: json['commanderID'],
          userList: <MyUser>[
            for (var jsonData in (json['userList'] as List<dynamic>))
              MyUser.fromData(jsonData),
          ],
        );

  // don't use set, use update!!!
  Map<String, dynamic> toJson() {
    return {
      'commanderID': commanderID,
      'userList': <Map<String, dynamic>>[
        for (var user in userList) user.toJson(),
      ]
    };
  }

  int getIndexOfUser({required String userID}) {
    for (int i = 0; i < userList.length; i++) {
      if (userList[i].userID == userID) return i;
    }
    // non-exist : false
    return -1;
  }
}
