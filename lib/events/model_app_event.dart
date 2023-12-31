// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppEvent {
  final String title;
  final String id;
  final String desc;
  final DateTime date;
  final String time;
  AppEvent({
    required this.title,
    required this.id,
    required this.desc,
    required this.date,
    required this.time,
  });

  AppEvent copyWith({
    String? title,
    String? id,
    String? desc,
    DateTime? date,
    String? time,
  }) {
    return AppEvent(
      title: title ?? this.title,
      id: id ?? this.id,
      desc: desc ?? this.desc,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'id': id,
      'desc': desc,
      'date': date,
      'time': time,
    };
  }

  factory AppEvent.fromMap(Map<String, dynamic> map) {
    return AppEvent(
      title: map['title'] as String,
      id: map['id'] as String,
      desc: map['desc'] as String,
      date: map['date'],
      time: map['time'],
    );
  }

  factory AppEvent.fromDS(String id, Map<String, dynamic> map) {
    return AppEvent(
      title: map['title'] as String,
      id: id,
      desc: map['desc'] as String,
      date: map['date']?.toDate(),
      time: map['time'].toTime(),
    );
  }

  factory AppEvent.fromDocument(DocumentSnapshot doc) {
    final map = doc.data();
    var timeV = doc.get('time');
    var timeS = '';

    if (timeV != null) {
      DateTime dt = (timeV as Timestamp).toDate();
      timeS = DateFormat('h:mm a').format(dt);
    }

    return AppEvent(
        date: map.toString().contains('date') ? doc.get('date').toDate() : '',
        id: doc.reference.id,
        desc: map.toString().contains('desc') ? doc.get('desc') : '',
        title: map.toString().contains('title') ? doc.get('title') : '',
        time: timeS);
  }

  String toJson() => json.encode(toMap());

  factory AppEvent.fromJson(String source) =>
      AppEvent.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AppEvent(title: $title, id: $id, desc: $desc, date: $date, time: $time)';
  }

  @override
  bool operator ==(covariant AppEvent other) {
    if (identical(this, other)) return true;
    return other.title == title &&
        other.id == id &&
        other.desc == desc &&
        other.date == date &&
        other.time == time;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        id.hashCode ^
        desc.hashCode ^
        date.hashCode ^
        time.hashCode;
  }
}
