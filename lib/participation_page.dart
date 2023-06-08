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
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
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
                  "나의 참여지수 : ${widget.chatDataParent.chat.getUser(userID: widget.chatDataParent.currentUser.uid)!.participation}포인트",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 8.0, right: 8.0),
          child: Divider(
            color: Colors.black54,
            thickness: 1.5,
          ),
        ),
        ParticipationGraph(chatDataParent: widget.chatDataParent)
        // ParticipationDetail(chatDataParent: widget.chatDataParent)
      ],
    );
  }
}

class ParticipationGraph extends StatefulWidget {
  final ChatScreenState chatDataParent;
  const ParticipationGraph({super.key, required this.chatDataParent});

  @override
  State<ParticipationGraph> createState() => _ParticipationGraphState();
}

class _ParticipationGraphState extends State<ParticipationGraph> {
  int maxParticipation = 0;

  @override
  void initState() {
    super.initState();
  }

  void updateMaxParticipation() {
    for (var user in widget.chatDataParent.chat.userList) {
      if (user.participation >= maxParticipation) {
        maxParticipation = user.participation;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var user in widget.chatDataParent.chat.userList)
          Row(
            children: [
              Text(widget.chatDataParent.userNameList[user.userID]!),
              LinearPercentIndicator(
                padding: const EdgeInsets.all(0),
                animation: true,
                animationDuration: 500,
                lineHeight: 15.0,
                percent: maxParticipation != 0
                    ? user.participation / maxParticipation
                    : 0,
                trailing: Text(user.participation.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12)),
                // only one color can accept
                linearGradient: const LinearGradient(colors: [
                  Palette.brightViolet,
                  Palette.pastelPurple,
                  Palette.brightBlue
                ]),
              ),
            ],
          )
      ],
    );
  }
}

class ParticipationDetail extends StatefulWidget {
  final ChatScreenState chatDataParent;
  const ParticipationDetail({super.key, required this.chatDataParent});

  @override
  State<ParticipationDetail> createState() => _ParticipationDetailState();
}

class _ParticipationDetailState extends State<ParticipationDetail> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
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
              for (var user in widget.chatDataParent.chat.userList)
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
              Text(
                  "완료한 일 : ${widget.chatDataParent.chat.getUser(userID: widget.chatDataParent.currentUser.uid)!.doneCount}회"),
            ],
          )
        ],
      ),
    );
  }
}
