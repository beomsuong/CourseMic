import 'package:capston/chatting/chat_screen.dart';
import 'package:capston/palette.dart';
import 'package:capston/todo_list/todo.dart';
import 'package:capston/todo_list/todo_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ToDoCalendar extends StatefulWidget {
  final ChatScreenState chatDataParent;
  final ToDoListState todoDataParent;
  const ToDoCalendar(
      {super.key, required this.chatDataParent, required this.todoDataParent});

  @override
  State<ToDoCalendar> createState() => _ToDoCalendarState();
}

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
    widget.todoDataParent.todoStream =
        widget.chatDataParent.toDoColRef.snapshots();
    DateTime now = DateTime.now();
    setTitle(now.year, now.month);
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
        stream: widget.todoDataParent.todoStream,
        builder: (context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Palette.pastelPurple));
          }
          DateTime now = DateTime.now();
          List<CalendarEventModel>? eventList = List.empty(growable: true);

          var todoDocs = snapshot.data!.docs;
          StateWithToDo stateWithTodo =
              widget.todoDataParent.getStateWithToDo(todoDocs);

          for (ToDoState state in ToDoState.values) {
            var toDoDocs = stateWithTodo[state.name];
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
            dayItemBuilder: (builderArgument) =>
                MyDayItemWidget(properties: builderArgument),
            weekDaysBuilder: (day) => MyWeekDaysWidget(day: day),
            eventBuilder: null,
            onDayClicked: _showDayEventsInModalSheet,
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

  void _showDayEventsInModalSheet(
      List<CalendarEventModel> events, DateTime day) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
        isScrollControlled: true,
        context: context,
        builder: (context) => DayEventsBottomSheet(
              events: events,
              day: day,
              screenHeight: MediaQuery.of(context).size.height,
            ));
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

class MyDayItemWidget extends StatelessWidget {
  final DayItemProperties properties;

  const MyDayItemWidget({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Palette.darkGray, width: 0.3)),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 4),
            alignment: Alignment.topCenter,
            child: Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                color: properties.isCurrentDay
                    ? Palette.pastelPurple
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('${properties.dayNumber}',
                    style: TextStyle(
                        color: properties.isCurrentDay
                            ? Colors.white
                            : Palette.lightBlack
                                .withOpacity(properties.isInMonth ? 1 : 0.5),
                        fontWeight: properties.isInMonth
                            ? FontWeight.w500
                            : FontWeight.normal)),
              ),
            ),
          ),
          if (properties.notFittedEventsCount > 0)
            Container(
              padding: const EdgeInsets.only(right: 2, top: 2),
              alignment: Alignment.topRight,
              child: Text('+${properties.notFittedEventsCount}',
                  style: TextStyle(
                      fontSize: 10,
                      color: Palette.brightBlue
                          .withOpacity(properties.isInMonth ? 1 : 0.5))),
            ),
        ],
      ),
    );
  }
}

DateFormat simpleFormat = DateFormat("yy/MM/dd");
DateFormat dateFormat = DateFormat("yy/MM/dd HH:mm");

class DayEventsBottomSheet extends StatelessWidget {
  const DayEventsBottomSheet({
    required this.screenHeight,
    required this.events,
    required this.day,
    super.key,
  });

  final List<CalendarEventModel> events;
  final DateTime day;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        maxChildSize: 0.9,
        expand: false,
        builder: (context, controller) {
          return events.isEmpty
              ? const Center(child: Text('No events for this day'))
              : ListView.builder(
                  controller: controller,
                  itemCount: events.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 18,
                          top: 16,
                          bottom: 16,
                        ),
                        child: Text(simpleFormat.format(day)),
                      );
                    } else {
                      final event = events[index - 1];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: SizedBox(
                            height: 100,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Row(
                                      children: [
                                        Container(
                                          color: event.eventColor,
                                          width: 6,
                                        ),
                                        Expanded(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event.name,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '${dateFormat.format(event.begin)} - ',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    Text(
                                                      dateFormat
                                                          .format(event.end),
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: event.eventColor !=
                                                                  Palette
                                                                      .brightBlue
                                                              ? event.end
                                                                          .difference(DateTime
                                                                              .now())
                                                                          .inMinutes >=
                                                                      0
                                                                  ? Palette
                                                                      .brightBlue
                                                                  : Palette
                                                                      .brightViolet
                                                              : null),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ))
                                      ],
                                    )))),
                      );
                    }
                  });
        });
  }
}
