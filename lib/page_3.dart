import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:jday/events/event_firestore_service.dart';
import 'package:jday/palette.dart';
import 'package:jday/tasks/model_todo_task.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:jday/tasks/page_add_task_byimage_mobile.dart';
import 'package:jday/tasks/page_add_task_byimage_web.dart';

import 'package:table_calendar/table_calendar.dart';

class Page3 extends StatefulWidget {
  var snapshot;
  Page3({super.key, this.snapshot});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  final _taskForm = GlobalKey<FormBuilderState>();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  late LinkedHashMap<DateTime, List<TodoTask>> _groupedTasks;
  late List<TodoTask> _noDateTasks;

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  _groupTasks(List<dynamic> tasks) {
    _groupedTasks = LinkedHashMap(equals: isSameDay, hashCode: getHashCode);
    _noDateTasks = [];
    for (var task in tasks) {
      TodoTask tTask = TodoTask.fromDocument(task);
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

  List<dynamic> _getTasksForDay(DateTime date) {
    return _groupedTasks[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> documents = widget.snapshot.data!.docs;
    _groupTasks(documents);
    final selectedTasks = _groupedTasks[_selectedDay] ?? [];

    return Scaffold(
      backgroundColor: Palette.blackP[50],
      appBar: AppBar(
        title: const Text('jday', style: TextStyle(color: Colors.black)),
        elevation: 0.5,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(25, 25, 20, 20),
                child: Text(
                  'Todo',
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            _taskList(_noDateTasks),
            const Padding(padding: EdgeInsets.only(top: 20.00)),
            const Divider(
              color: Color.fromARGB(255, 205, 201, 201),
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            _calendarview(),
            const Padding(padding: EdgeInsets.only(top: 30.00)),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 25.00),
                ),
                Text(
                  DateFormat('MM월 dd일', 'ko').format(_selectedDay),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            _taskList(selectedTasks),
          ],
        ),
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        SizedBox(
            width: 55,
            height: 55,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff64ae64),
                shape: const CircleBorder(),
              ),
              child: const Icon(
                Icons.photo,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () {
                if (kIsWeb) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddTaskPageW()));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddTaskPageM()));
                }
              },
            )),
        const Padding(padding: EdgeInsets.only(top: 8.00)),
        SizedBox(
            width: 55,
            height: 55,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff64ae64),
                shape: const CircleBorder(),
              ),
              child: const Icon(
                Icons.keyboard,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () => _taskAdd(null),
            ))
      ]),
    );
  }

  ListView _taskList(tasks) {
    return ListView.builder(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tasks.length,
        itemBuilder: ((context, index) {
          TodoTask task = tasks[index];
          return ListTile(
            leading: IconButton(
              icon: task.done
                  ? Image.asset('assets/img-res/task-done.png')
                  : Image.asset('assets/img-res/task-undone.png'),
              padding: const EdgeInsets.all(0.0),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () async {
                DateTime? tDate;
                if ((task.date != "")) {
                  tDate = DateTime.parse(task.date);
                } else {
                  tDate = null;
                }
                DateTime? tTime;
                if ((task.time != "")) {
                  tTime = DateFormat('h:mm a').parse(task.time);
                } else {
                  tTime = null;
                }

                final updateDone = <String, dynamic>{
                  "date": tDate,
                  "done": !task.done,
                  "time": tTime,
                  "title": task.title
                };
                final data = Map<String, dynamic>.from(updateDone);
                await taskDBS.updateData(task.id, data);
              },
            ),
            title: Text(
              task.title,
              style: TextStyle(
                  decoration: task.done
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: task.done ? Colors.grey : Colors.black),
            ),
            trailing: Text(task.time),
            onTap: () => _taskAdd(task),
          );
        }));
  }

  CalendarFormat _calendarFormat = CalendarFormat.week;

  Padding _calendarview() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: TableCalendar(
        firstDay: DateTime(2019, 1, 1),
        lastDay: DateTime(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: 'ko-KR',
        eventLoader: _getTasksForDay,
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: true,
          formatButtonShowsNext: true,
          leftChevronIcon:
              Icon(Icons.chevron_left_rounded, color: Palette.whiteP[500]),
          rightChevronIcon:
              Icon(Icons.chevron_right_rounded, color: Palette.whiteP[500]),
          headerMargin: const EdgeInsets.only(top: 10, bottom: 10),
        ),
        calendarStyle: const CalendarStyle(
          markersAlignment: Alignment.bottomRight,
          todayTextStyle: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xff4ea24e),
          ),
          todayDecoration: BoxDecoration(
            color: Color.fromARGB(0, 255, 255, 255),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(
              fontWeight: FontWeight.w900, color: Color.fromARGB(255, 0, 0, 0)),
          selectedDecoration: BoxDecoration(
            color: Color.fromARGB(0, 100, 174, 100),
            shape: BoxShape.circle,
          ),
        ),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        calendarBuilders:
            CalendarBuilders(markerBuilder: (context, day, events) {
          int eventCnt = events.length;
          return Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  eventCnt == 0 ? Colors.transparent : const Color(0xff4ea24e),
            ),
            child: Text(
              eventCnt.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          );
        }),
      ),
    );
  }

  _taskAdd(TodoTask? task) async {
    final confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title:
                      task != null ? const Text('할일 수정') : const Text('할일 추가'),
                  content: SizedBox(
                    width: 300,
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16.0),
                      children: <Widget>[
                        FormBuilder(
                            key: _taskForm,
                            child: Column(
                              children: [
                                FormBuilderTextField(
                                  validator: FormBuilderValidators.compose([
                                    (val) {
                                      return val == null
                                          ? "할 일이 입력되지 않았습니다."
                                          : null;
                                    },
                                    FormBuilderValidators.required(),
                                  ]),
                                  name: "title",
                                  initialValue: task?.title,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.abc_outlined),
                                    hintText: "할일 입력",
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.blackP),
                                    ),
                                    enabledBorder: InputBorder.none,
                                  ),
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(top: 16.00)),
                                FormBuilderDateTimePicker(
                                  name: "date",
                                  inputType: InputType.date,
                                  format:
                                      DateFormat('yyyy년 MM월 dd일 (EE)', 'ko'),
                                  initialValue: task != null && task.date != ''
                                      ? DateFormat('yyyy-MM-dd')
                                          .parse(task.date)
                                      : null,
                                  decoration: const InputDecoration(
                                    prefixIcon:
                                        Icon(Icons.calendar_today_rounded),
                                    hintText: "날짜 설정",
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.blackP),
                                    ),
                                    enabledBorder: InputBorder.none,
                                  ),
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(top: 16.00)),
                                FormBuilderDateTimePicker(
                                  name: "time",
                                  inputType: InputType.time,
                                  format: DateFormat('hh:mm a'),
                                  initialValue: task != null && task.time != ''
                                      ? DateFormat("h:mm a").parse(task.time)
                                      : null,
                                  decoration: const InputDecoration(
                                    prefixIcon:
                                        Icon(Icons.access_alarm_rounded),
                                    hintText: "시간 설정",
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.blackP),
                                    ),
                                    enabledBorder: InputBorder.none,
                                  ),
                                ),
                                FormBuilderField(
                                  validator: FormBuilderValidators.compose(
                                      [FormBuilderValidators.required()]),
                                  name: "done",
                                  enabled: false,
                                  initialValue:
                                      task != null ? task.done : false,
                                  builder: (FormFieldState<dynamic> field) {
                                    return const SizedBox.shrink();
                                  },
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: task != null
                              ? () async {
                                  await taskDBS.removeItem(task.id);
                                  if (context.mounted) Navigator.pop(context);
                                }
                              : null,
                          child: Text(
                            '삭제',
                            style: TextStyle(
                                color: task != null
                                    ? Colors.red
                                    : Colors.transparent,
                                fontSize: 15),
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                '취소',
                                style: TextStyle(
                                    color: Color(0xff4c4c4c), fontSize: 15),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const Text(
                                '저장',
                                style: TextStyle(
                                    color: Color(0xff4c4c4c), fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )) ??
        false;

    if (confirm) {
      bool validated = _taskForm.currentState!.validate();
      if (validated) {
        _taskForm.currentState!.save();
        final data = Map<String, dynamic>.from(_taskForm.currentState!.value);
        if (task == null) {
          await taskDBS.create(data);
        } else {
          await taskDBS.updateData(task.id, data);
        }
      }
    }
  }
}
