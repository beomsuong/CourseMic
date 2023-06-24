import 'package:capston/chatting/chat/chat.dart';
import 'package:capston/chatting/chat/chat_user.dart';
import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/palette.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ParticipationPage extends StatefulWidget {
  final ChatScreenState chatDataParent;
  const ParticipationPage({super.key, required this.chatDataParent});

  @override
  State<ParticipationPage> createState() => _ParticipationPageState();
}

class _ParticipationPageState extends State<ParticipationPage> {
  bool bDetail = false;

  @override
  void initState() {
    super.initState();
    widget.chatDataParent.chatStream =
        widget.chatDataParent.chatDocRef.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.chatDataParent.chatStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          Chat chat = Chat.fromJson(snapshot.data!);

          return Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.lightGray,
                      offset: Offset(0.0, 5.0), //(x,y)
                      blurRadius: 3.0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 2.0, top: 1.0, bottom: 9.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            bDetail = !bDetail;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(!bDetail ? " + 상세보기" : " + 그래프보기",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Colors.black54)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Text(
                          "나의 참여지수 : ${chat.getUser(userID: widget.chatDataParent.currentUser.uid)!.participation}포인트",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: !bDetail
                    ? ParticipationGraph(
                        chatDataParent: widget.chatDataParent,
                        userList: chat.userList)
                    : ParticipationDetail(
                        chatDataParent: widget.chatDataParent,
                        userList: chat.userList,
                        doneCount: chat
                            .getUser(
                                userID: widget.chatDataParent.currentUser.uid)!
                            .doneCount,
                      ),
              )
            ],
          );
        });
  }
}

class ParticipationGraph extends StatefulWidget {
  final ChatScreenState chatDataParent;
  final List<ChatUser> userList;
  const ParticipationGraph(
      {super.key, required this.chatDataParent, required this.userList});

  @override
  State<ParticipationGraph> createState() => _ParticipationGraphState();
}

class _ParticipationGraphState extends State<ParticipationGraph> {
  final double minWidth = 8.0;
  final double maxWidth = 220.0;
  double maxRatio = 0;
  bool bGraphAnimationEnd = false;

  @override
  void initState() {
    super.initState();
    updateMaxParticipation();
  }

  void updateMaxParticipation() {
    int max = 0;
    for (var user in widget.userList) {
      if (user.participation >= max) {
        max = user.participation;
      }
    }
    maxRatio = max / maxWidth;
    if (maxRatio == 0) return;
    maxRatio = 1 / maxRatio;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    updateMaxParticipation();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var user in widget.userList)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    widget.chatDataParent.userNameList[user.userID]!,
                    textAlign: TextAlign.end,
                    style: widget.chatDataParent.currentUser.uid == user.userID
                        ? const TextStyle(
                            color: Palette.pastelPurple,
                            fontWeight: FontWeight.bold)
                        : null,
                  ),
                ),
            ],
          ),
        ]),
        Wrap(children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 7.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var user in widget.userList)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14.5),
                    child: LinearPercentIndicator(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.only(right: 8.0),
                      width: maxRatio != 0
                          ? user.participation * maxRatio
                          : minWidth,
                      animation: true,
                      animationDuration: 500,
                      lineHeight: 15.0,
                      percent: maxRatio != 0 ? 1.0 : 0,
                      onAnimationEnd: () {
                        setState(() {
                          bGraphAnimationEnd = true;
                        });
                      },
                      trailing: Text(user.participation.toString(),
                          style: TextStyle(
                              color: bGraphAnimationEnd
                                  ? Colors.black
                                  : Colors.transparent,
                              fontWeight: FontWeight.w500,
                              fontSize: 12)),
                      // only one color can accept
                      linearGradient: const LinearGradient(colors: [
                        Palette.brightViolet,
                        Palette.pastelPurple,
                        Palette.brightBlue
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        ]),
      ],
    );
  }
}

class ParticipationDetail extends StatefulWidget {
  final ChatScreenState chatDataParent;
  final List<ChatUser> userList;
  final int doneCount;
  const ParticipationDetail(
      {super.key,
      required this.chatDataParent,
      required this.userList,
      required this.doneCount});

  @override
  State<ParticipationDetail> createState() => _ParticipationDetailState();
}

class _ParticipationDetailState extends State<ParticipationDetail> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text("팀원 점수"),
              ),
              for (var user in widget.userList)
                Text(
                    "${widget.chatDataParent.userNameList[user.userID]} : ${user.participation}포인트")
            ],
          ),
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text("내가 참여한 활동"),
              ),
              const Text("채팅 : 0회"),
              const Text("자료공유 : 0회"),
              const Text("반응 : 0회"),
              Text("완료한 일 : ${widget.doneCount}회"),
            ],
          )
        ],
      ),
    );
  }
}
