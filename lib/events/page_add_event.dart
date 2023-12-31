import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:jday/events/event_firestore_service.dart';
import 'package:jday/events/model_app_event.dart';
import 'package:jday/palette.dart';

class AddEventPage extends StatefulWidget {
  DateTime? selectedDay;
  AppEvent? event; // 일정 편집용
  AddEventPage({super.key, this.selectedDay, this.event});
  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 정보 입력', style: TextStyle(color: Colors.black)),
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.clear, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Row(children: [
            ElevatedButton(
              onPressed: () async {
                // save event
                bool validated = _formKey.currentState!.validate();
                if (validated) {
                  _formKey.currentState!.save();
                  final data =
                      Map<String, dynamic>.from(_formKey.currentState!.value);
                  if (widget.event == null) {
                    await eventDBS.create(data); // 일정 추가
                    if (context.mounted) Navigator.pop(context);
                  } else {
                    await eventDBS.updateData(widget.event!.id, data);
                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              child: const Text("저장"),
            ),
            const Padding(padding: EdgeInsets.only(right: 10))
          ])
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(25.0),
        children: <Widget>[
          FormBuilder(
            key: _formKey,
            child: Column(children: [
              Material(
                borderRadius: BorderRadius.circular(20),
                elevation: 1.5,
                child: FormBuilderDateTimePicker(
                  name: "date",
                  inputType: InputType.date,
                  format: DateFormat('yyyy년 MM월 dd일 (EE)', 'ko'),
                  initialValue: widget.event != null
                      ? widget.event?.date
                      : widget.selectedDay,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    filled: true,
                    fillColor: Palette.whiteP,
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Palette.whiteP),
                        borderRadius: BorderRadius.circular(20)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Palette.whiteP),
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const Divider(),
              Material(
                borderRadius: BorderRadius.circular(20),
                elevation: 1.5,
                child: FormBuilderTextField(
                  validator: FormBuilderValidators.compose([
                    (val) {
                      return val == null ? "일정 이름을 입력해주세요." : null;
                    },
                    FormBuilderValidators.required(),
                  ]),
                  name: "title",
                  initialValue: widget.event?.title,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.abc_outlined),
                    hintText: "이름 입력",
                    filled: true,
                    fillColor: Palette.whiteP,
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Palette.whiteP),
                        borderRadius: BorderRadius.circular(20)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Palette.whiteP),
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const Divider(),
              Material(
                borderRadius: BorderRadius.circular(20),
                elevation: 1.5,
                child: FormBuilderTextField(
                  name: "desc",
                  initialValue: widget.event?.desc ?? '',
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.short_text_rounded),
                    hintText: "설명 입력",
                    filled: true,
                    fillColor: Palette.whiteP,
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Palette.whiteP),
                        borderRadius: BorderRadius.circular(20)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Palette.whiteP),
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const Divider(),
              Material(
                borderRadius: BorderRadius.circular(20),
                elevation: 1.5,
                child: FormBuilderDateTimePicker(
                  name: "time",
                  initialValue:
                      widget.event?.time != null && widget.event?.time != ''
                          ? DateFormat("h:mm a").parse(widget.event!.time)
                          : null,
                  inputType: InputType.time,
                  format: DateFormat('hh:mm a'),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.access_alarm_rounded),
                    hintText: "시간 지정",
                    filled: true,
                    fillColor: Palette.whiteP,
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Palette.whiteP),
                        borderRadius: BorderRadius.circular(20)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Palette.whiteP),
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  cursorColor: const Color(0xff4c4c4c),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
