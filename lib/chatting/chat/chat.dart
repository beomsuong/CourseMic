import 'package:capston/chatting/chat/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String roomName;
  late String commanderID;
  late List<ChatUser> userList;

  Chat(
      {required this.roomName,
      this.commanderID = '',
      this.userList = const <ChatUser>[]});

  factory Chat.fromJson(DocumentSnapshot<Object?> json) {
    return Chat(
      roomName: json['roomName'],
      commanderID: json['commanderID'],
      userList: <ChatUser>[
        for (var jsonData in (json['userList'] as List<dynamic>))
          ChatUser.fromData(jsonData),
      ],
    );
  }

  // don't use set, use update!!!
  Map<String, dynamic> toJson() {
    return {
      'commanderID': commanderID,
      'userList': <Map<String, dynamic>>[
        for (var user in userList) user.toJson(),
      ]
    };
  }

  // update only userList
  Map<String, dynamic> userListToJson() {
    return {
      'userList': <Map<String, dynamic>>[
        for (var user in userList) user.toJson(),
      ]
    };
  }

  ChatUser? getUser({required String userID}) {
    for (int i = 0; i < userList.length; i++) {
      if (userList[i].userID == userID) return userList[i];
    }
    return null;
  }

  int getIndexOfUser({required String userID}) {
    for (int i = 0; i < userList.length; i++) {
      if (userList[i].userID == userID) return i;
    }
    // non-exist : false
    return -1;
  }
}
