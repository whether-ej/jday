import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jday/events/event_firestore_service.dart';
import 'package:jday/events/model_app_event.dart';
import 'package:jday/tasks/model_todo_task.dart';
import 'package:jday/weather/widget_weather.dart';

class Page1 extends StatefulWidget {
  var snapshotE;
  var snapshotT;
  Page1({super.key, this.snapshotE, this.snapshotT});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  String yearString = DateFormat('yyyy').format(DateTime.now());
  String dateString = DateFormat('MM.d').format(DateTime.now());
  String weekdayString = DateFormat.EEEE('ko').format(DateTime.now());

  late LinkedHashMap<DateTime, List<AppEvent>> _groupedEvents;
  late LinkedHashMap<DateTime, List<TodoTask>> _groupedTasks;
  late List<TodoTask> _noDateTasks;
  final DateTime _today = DateTime.now();

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  _groupEvents(List<dynamic> events) {
    _groupedEvents = LinkedHashMap(equals: isSameDay, hashCode: getHashCode);
    for (var event in events) {
      AppEvent tEvent = AppEvent.fromDocument(event);
      DateTime date = DateTime.utc(
          tEvent.date.year, tEvent.date.month, tEvent.date.day, 12);
      if (_groupedEvents[date] == null) _groupedEvents[date] = [];
      _groupedEvents[date]!.add(tEvent);
    }
  }

  _groupTasks(List<dynamic> tasks) {
    _groupedTasks = LinkedHashMap(equals: isSameDay, hashCode: getHashCode);
    _noDateTasks = [];
    for (var task in tasks) {
      TodoTask tTask = TodoTask.fromDocument(task!);
      if (tTask.date != "") {
        DateTime tDate = DateTime.parse(tTask.date);
        DateTime date = DateTime.utc(tDate.year, tDate.month, tDate.day, 12);
        if (_groupedTasks[date] == null) _groupedTasks[date] = [];
        _groupedTasks[date]!.add(tTask);
      } else {
        _noDateTasks.add(tTask);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> documentsE = widget.snapshotE.data.docs;
    List<DocumentSnapshot> documentsT = widget.snapshotT.data.docs;
    _groupEvents(documentsE);
    _groupTasks(documentsT);
    final todayEvents = _groupedEvents[_today] ?? [];
    final todayTasks = _groupedTasks[_today] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('jday', style: TextStyle(color: Colors.black)),
        elevation: 0.5,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              alignment: Alignment.bottomLeft,
              margin: const EdgeInsets.fromLTRB(35, 30, 0, 0),
              child: Text(
                yearString,
                style: const TextStyle(fontSize: 20.0),
              )),
          Flexible(
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.fromLTRB(20, 0, 10, 10),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      dateString,
                      style: const TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      weekdayString,
                      style: const TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.w300),
                    ),
                  ]),
            ),
          ),
          SizedBox(
              width: double.infinity,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                elevation: 2.0,
                margin: const EdgeInsets.fromLTRB(20, 5, 20, 15),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: WeatherWidget(),
                ),
              )),
          SizedBox(
            width: double.infinity,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              elevation: 2.0,
              margin: const EdgeInsets.fromLTRB(20, 15, 20, 15),
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10, top: 10),
                        child: Text(
                          '일정',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 20),
                        ),
                      ),
                      _eventList(todayEvents),
                    ],
                  )),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              elevation: 2.0,
              margin: const EdgeInsets.fromLTRB(20, 15, 20, 15),
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
                        child: Text(
                          '투두',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 20),
                        ),
                      ),
                      (_noDateTasks.isEmpty && todayTasks.isEmpty)
                          ? const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Center(
                                child: Text('등록된 투두가 없습니다.'),
                              ),
                            )
                          : Column(
                              children: [
                                _taskList(_noDateTasks),
                                (todayTasks.isNotEmpty)
                                    ? const Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: Color.fromARGB(
                                                  255, 205, 201, 201),
                                              thickness: 1,
                                              indent: 20,
                                              endIndent: 20,
                                            ),
                                          ),
                                          Text(
                                            '오늘 할일',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(
                                                    255, 205, 201, 201)),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: Color.fromARGB(
                                                  255, 205, 201, 201),
                                              thickness: 1,
                                              indent: 20,
                                              endIndent: 20,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                _taskList(todayTasks),
                              ],
                            ),
                    ],
                  )),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _eventList(items) {
    return (items.length != 0)
        ? ListView.builder(
            padding: const EdgeInsets.only(top: 10),
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: ((context, index) {
              AppEvent item = items[index];
              return ListTile(
                title: Text(item.title),
                trailing: Text(item.time),
              );
            }))
        : const Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Text('등록된 일정이 없습니다.'),
            ),
          );
  }

  Widget _taskList(items) {
    return ListView.builder(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          TodoTask item = items[index];
          return ListTile(
              leading: IconButton(
                icon: item.done
                    ? Image.asset('assets/img-res/task-done.png')
                    : Image.asset('assets/img-res/task-undone.png'),
                padding: const EdgeInsets.all(0.0),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () async {
                  DateTime? tDate;
                  if ((item.date != "")) {
                    tDate = DateTime.parse(item.date);
                  } else {
                    tDate = null;
                  }
                  DateTime? tTime;
                  if ((item.time != "")) {
                    tTime = DateFormat('h:mm a').parse(item.time);
                  } else {
                    tTime = null;
                  }

                  final updateDone = <String, dynamic>{
                    "date": tDate,
                    "done": !item.done,
                    "time": tTime,
                    "title": item.title
                  };
                  final data = Map<String, dynamic>.from(updateDone);
                  await taskDBS.updateData(item.id, data);
                },
              ),
              title: Text(
                item.title,
                style: TextStyle(
                    decoration: item.done
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: item.done ? Colors.grey : Colors.black),
              ),
              trailing: Text(item.time));
        });
  }
}
