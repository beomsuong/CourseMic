final Map<String, int> userRole = {
  '역할없음': 0,
  '커맨더': 16,
  '익스플로러': 8,
  '아티스트': 4,
  '엔지니어': 2,
  '커뮤니케이터': 1,
};

class ChatUser {
  final String userID;
  late int role;
  late int participation;
  late int doneCount;

  ChatUser(
      {required this.userID,
      this.role = 0,
      this.participation = 0,
      this.doneCount = 0});

  factory ChatUser.fromData(Map<String, dynamic> data) {
    return ChatUser(
        userID: data['userID'],
        role: data['role'] as int,
        participation: data['participation'] as int,
        doneCount: data['doneCount'] as int);
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'role': role,
      'participation': participation,
      'doneCount': doneCount,
    };
  }

  List<String> getRoleList() {
    List<String> roleList = List<String>.empty(growable: true);

    for (var roleKey in userRole.keys) {
      var bRole = role & userRole[roleKey]!;
      if (bRole == userRole[roleKey]) roleList.add(roleKey);
    }

    return roleList;
  }

  void setRole(List<dynamic> roleList) {
    if (roleList is List<String>) {
      for (var roleStr in roleList) {
        role |= userRole[roleStr]!;
      }
      return;
    }

    if (roleList is List<int>) {
      for (var roleInt in roleList) {
        role |= roleInt;
      }
      return;
    }
  }

  void updateRole(List<dynamic> roleList) {
    role = 0;
    if (roleList is List<String>) {
      for (var roleStr in roleList) {
        role += userRole[roleStr]!;
      }
      return;
    }

    if (roleList is List<int>) {
      for (var roleInt in roleList) {
        role += roleInt;
      }
      return;
    }
  }
}
