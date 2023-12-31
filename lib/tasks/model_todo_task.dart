import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TodoTask {
  final String title;
  final String id;
  final String date;
  final String time;
  final bool done;
  TodoTask({
    required this.title,
    required this.id,
    required this.date,
    required this.time,
    required this.done,
  });

  TodoTask copyWith({
    String? title,
    String? id,
    String? date,
    String? time,
    bool? done,
  }) {
    return TodoTask(
      title: title ?? this.title,
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'id': id,
      'date': date,
      'time': time,
      'done': done,
    };
  }

  factory TodoTask.fromMap(Map<String, dynamic> map) {
    return TodoTask(
      title: map['title'] as String,
      id: map['id'] as String,
      date: map['date'],
      time: map['time'],
      done: map['done'] as bool,
    );
  }

  factory TodoTask.fromDS(String id, Map<String, dynamic> map) {
    return TodoTask(
      title: map['title'] as String,
      id: id,
      date: map['date'].toDate(),
      time: map['time'].toTime(),
      done: map['done'] as bool,
    );
  }

  factory TodoTask.fromDocument(DocumentSnapshot doc) {
    final map = doc.data();

    var dateV = doc.get('date');
    var dateS = '';

    var timeV = doc.get('time');
    var timeS = '';

    if (dateV != null && dateV != '') {
      DateTime dt = dateV.toDate();
      dateS = DateFormat('yyyy-MM-dd').format(dt);
    }

    if (timeV != null && timeV != '') {
      DateTime dt = (timeV as Timestamp).toDate();
      timeS = DateFormat('h:mm a').format(dt);
    }

    return TodoTask(
      date: dateS,
      id: doc.reference.id,
      title: map.toString().contains('title') ? doc.get('title') : '',
      time: timeS,
      done: map.toString().contains('done') ? doc.get('done') : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory TodoTask.fromJson(String source) =>
      TodoTask.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TodoTask(title: $title, id: $id, date: $date, time: $time, done: $done)';
  }

  @override
  bool operator ==(covariant TodoTask other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.id == id &&
        other.date == date &&
        other.time == time &&
        other.done == done;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        id.hashCode ^
        date.hashCode ^
        time.hashCode ^
        done.hashCode;
  }
}
