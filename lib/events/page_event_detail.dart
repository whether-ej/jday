import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jday/events/event_firestore_service.dart';
import 'package:jday/events/page_add_event.dart';
import 'model_app_event.dart';

class EventDetail extends StatelessWidget {
  final AppEvent event;
  const EventDetail({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 세부사항'),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddEventPage(event: event)));
              }),
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('일정 삭제'),
                        content: Text("일정 '${event.title}'을 삭제하시겠습니까?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                "취소",
                                style: TextStyle(color: Colors.grey.shade700),
                              )),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("삭제")),
                        ],
                      ),
                    ) ??
                    false;

                if (confirm) {
                  await eventDBS.removeItem(event.id);
                  if (context.mounted) Navigator.pop(context);
                }
              }),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.event),
            title: Text(
              event.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            subtitle:
                Text(DateFormat('yyyy년 MM월 dd일 (EE)', 'ko').format(event.date)),
          ),
          const SizedBox(
            height: 10.0,
          ),
          if (event.desc != 'null' && event.desc != '')
            ListTile(
              leading: const Icon(Icons.short_text_rounded),
              title: Text(event.desc),
            ),
          if (event.time != '')
            ListTile(
              leading: const Icon(Icons.access_alarm_rounded),
              title: Text(event.time),
            )
        ],
      ),
    );
  }
}
