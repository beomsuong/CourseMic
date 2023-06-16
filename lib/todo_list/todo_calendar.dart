import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/palette.dart';
import 'package:capston/todo_list/todo.dart';
import 'package:capston/todo_list/todo_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/material.dart';

class ToDoCalendar extends StatefulWidget {
  final ChatScreenState chatDataState;
  final ToDoListState todoDataState;
  const ToDoCalendar(
      {super.key, required this.chatDataState, required this.todoDataState});

  @override
  State<ToDoCalendar> createState() => _ToDoCalendarState();
}

typedef StateWithToDo = Map<String, QuerySnapshot<Object?>>;

class _ToDoCalendarState extends State<ToDoCalendar> {
  final _appbarTitleNotifier = ValueNotifier<String>('');
  List<Color> eventColors = <Color>[
    Palette.brightViolet,
    Palette.pastelPurple,
    Palette.brightBlue
  ];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    setTitle(now.year, now.month);
    widget.todoDataState.todoStream = widget.todoDataState.initToDoNodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder(
          valueListenable: _appbarTitleNotifier,
          builder: (context, value, child) => Text(value),
        ),
        centerTitle: true,
        actions: const [
          Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 12),
                child: Text("할 일 캘린더"),
              )),
        ],
      ),
      body: StreamBuilder(
        stream: widget.todoDataState.todoStream,
        builder: (context, AsyncSnapshot<StateWithToDo> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Palette.pastelPurple));
          }
          DateTime now = DateTime.now();
          List<CalendarEventModel>? eventList = List.empty(growable: true);

          StateWithToDo data = snapshot.data as StateWithToDo;
          for (ToDoState state in ToDoState.values) {
            var toDoDocs = data[state.name]?.docs;
            if (toDoDocs == null) continue;
            for (var doc in toDoDocs) {
              ToDo todo = ToDo.fromJson(doc);
              eventList.add(CalendarEventModel(
                  name: todo.task,
                  begin: todo.createDate.toDate(),
                  end: todo.deadline.toDate(),
                  eventColor: eventColors[todo.state.index]));
            }
          }

          return CrCalendar(
            firstDayOfWeek: WeekDay.monday,
            eventsTopPadding: 32,
            initialDate: now,
            maxEventLines: 4,
            controller: CrCalendarController(
              onSwipe: setTitle,
              events: eventList,
            ),
            dayItemBuilder: null,
            weekDaysBuilder: (day) => MyWeekDaysWidget(day: day),
            eventBuilder: null,
            onDayClicked: null,
            minDate: now.subtract(const Duration(days: 180)),
            maxDate: now.add(const Duration(days: 180)),
          );
        },
      ),
    );
  }

  void setTitle(int year, int month) {
    _appbarTitleNotifier.value =
        "${year % 100}/${month.toString().padLeft(2, '0')}";
  }
}

class MyWeekDaysWidget extends StatelessWidget {
  final WeekDay day;
  List<String> weekDay = ['일', '월', '화', '수', '목', '금', '토'];

  MyWeekDaysWidget({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Center(
        child: Text(
          weekDay[day.index],
          style: const TextStyle(
              color: Palette.lightBlack, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
