import 'package:firebase_helpers/firebase_helpers.dart';
import 'package:jday/events/model_app_event.dart';
import 'package:jday/tasks/model_todo_task.dart';

final eventDBS = DatabaseService<AppEvent>(
  AppDBConstants.eventsCollection,
  fromDS: (id, data) => AppEvent.fromDS(id, data!),
  toMap: (event) => event.toMap(),
);

final taskDBS = DatabaseService<TodoTask>(
  AppDBConstants.tasksCollection,
  fromDS: (id, data) => TodoTask.fromDS(id, data!),
  toMap: (task) => task.toMap(),
);

class AppDBConstants {
  static const String eventsCollection = "events";
  static const String tasksCollection = "task";
}
