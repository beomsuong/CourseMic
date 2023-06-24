import 'package:capston/chatting/chat/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  late bool bEndProject;
  final String roomName;
  late String commanderID;
  late List<ChatUser> userList;
  late String recentMessage;

  Chat(
      {this.bEndProject = false,
      required this.roomName,
      this.commanderID = '',
      required this.userList,
      required this.recentMessage});

  factory Chat.fromJson(DocumentSnapshot<Object?> json) {
    return Chat(
        bEndProject: json['bEndProject'],
        roomName: json['roomName'],
        commanderID: json['commanderID'],
        userList: <ChatUser>[
          for (var jsonData in (json['userList'] as List<dynamic>))
            ChatUser.fromData(jsonData),
        ],
        recentMessage: json["recentMessage"]);
  }

  // don't use set, use update!!! / 다른 필드들은 개별적으로 업데이트
  Map<String, dynamic> toJson() {
    return {
      'bEndProject': bEndProject,
      'roomName': roomName,
      'commanderID': commanderID,
      'userList': <Map<String, dynamic>>[
        for (var user in userList) user.toJson(),
      ],
      'recentMessage': recentMessage,
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
