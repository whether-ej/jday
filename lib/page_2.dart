import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jday/events/model_app_event.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:jday/palette.dart';
import 'events/page_add_event.dart';
import 'events/page_event_detail.dart';

class Page2 extends StatefulWidget {
  var snapshot;
  Page2({super.key, this.snapshot});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  late LinkedHashMap<DateTime, List<AppEvent>> _groupedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
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

  List<dynamic> _getEventsForDay(DateTime date) {
    return _groupedEvents[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> documents = widget.snapshot.data!.docs;
    _groupEvents(documents);
    final selectedEvents = _groupedEvents[_selectedDay] ?? [];

    return Scaffold(
        backgroundColor: Palette.blackP[50],
        appBar: AppBar(
          title: const Text('jday', style: TextStyle(color: Colors.black)),
          elevation: 0.5,
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(25, 25, 20, 0),
                child: Text(
                  'Calendar',
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            TableCalendar(
              firstDay: DateTime(2019, 1, 1),
              lastDay: DateTime(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              locale: 'ko-KR',
              eventLoader: _getEventsForDay,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronIcon: Icon(Icons.chevron_left_rounded,
                    color: Palette.whiteP[500]),
                rightChevronIcon: Icon(Icons.chevron_right_rounded,
                    color: Palette.whiteP[500]),
                headerMargin: const EdgeInsets.only(top: 5, bottom: 10),
              ),
              calendarStyle: const CalendarStyle(
                todayTextStyle: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xff4ea24e),
                ),
                todayDecoration: BoxDecoration(
                  color: Color.fromARGB(0, 255, 255, 255),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(
                    fontWeight: FontWeight.w900, color: Palette.whiteP),
                selectedDecoration: BoxDecoration(
                  color: Color(0xff64ae64),
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
              onPageChanged: ((focusedDay) {
                _focusedDay = focusedDay;
              }),
              calendarBuilders:
                  CalendarBuilders(markerBuilder: (context, day, events) {
                int eventCnt = events.length;
                return Container(
                  width: 8,
                  height: 8,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: eventCnt == 0
                        ? Colors.transparent
                        : const Color.fromARGB(255, 51, 108, 51),
                  ),
                );
              }),
            ),
            const Padding(padding: EdgeInsets.only(top: 10.00)),
            const Divider(
              color: Color.fromARGB(255, 205, 201, 201),
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            const Padding(padding: EdgeInsets.only(top: 20.00)),
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
            const Padding(padding: EdgeInsets.only(bottom: 10.00)),
            Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      AppEvent event = selectedEvents[index];
                      return ListTile(
                          title: Text(event.title),
                          subtitle: Text(event.desc),
                          trailing: Text(event.time),
                          onTap: (() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EventDetail(event: event)));
                          }));
                    })),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text("Add Event"),
          icon: const Icon(Icons.add),
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xff64ae64),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          onPressed: (() {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddEventPage(selectedDay: _selectedDay)));
          }),
        ));
  }
}
