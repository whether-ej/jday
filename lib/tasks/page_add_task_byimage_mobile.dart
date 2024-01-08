import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jday/events/event_firestore_service.dart';
import 'package:jday/tasks/ocr_parse_text.dart';

class AddTaskPageM extends StatefulWidget {
  const AddTaskPageM({super.key});

  @override
  State<AddTaskPageM> createState() => _AddTaskPageMState();
}

class _AddTaskPageMState extends State<AddTaskPageM> {
  late File pickedImage;
  String img64 = '';
  var text = '';
  bool imageLoaded = false;
  bool taskParsed = false;
  late String imageType;

  var _parsedTasks = <String, List<String>>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진으로 할일 추가', style: TextStyle(color: Colors.black)),
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.clear, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Row(
            children: [
              ElevatedButton(
                onPressed: saveTasks,
                child: const Text("저장"),
              ),
              const Padding(padding: EdgeInsets.only(right: 10))
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/img-res/todo_guide.png'),
            ElevatedButton.icon(
                icon: const Icon(Icons.photo_camera, size: 20),
                label: const Text('이미지 선택'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff64ae64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    )),
                onPressed: pickImage),
            const Padding(padding: EdgeInsets.only(top: 10)),
            imageLoaded
                ? Center(
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      margin: const EdgeInsets.only(bottom: 8),
                      height: 250,
                      child: Image.file(pickedImage, fit: BoxFit.cover),
                    ),
                  )
                : Container(),
            const Padding(padding: EdgeInsets.only(top: 20)),
            FutureBuilder(
                future: pickImage(),
                builder: (context, snapshot) {
                  if (imageLoaded) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.connectionState ==
                            ConnectionState.done &&
                        taskParsed) {
                      return Flexible(
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _parsedTasks.keys.length,
                              itemBuilder: ((ctx, idx) {
                                return tasksListView(
                                    _parsedTasks.keys.elementAt(idx));
                              })));
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                })
          ],
        ),
      ),
    );
  }

  Future pickImage() async {
    final ImagePicker picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      pickedImage = File(image.path);
      img64 = base64Encode(pickedImage.readAsBytesSync());
      imageLoaded = true;
      imageType = image.path.split('.').last;
    });

    var apiUrl =
        "https://mo58gefq0m.apigw.ntruss.com/custom/v1/18971/52eb23e2abfcf09a6fa33340f207ae64708a9d1da37de19958a8fcfa1d5c9b80/general";
    var apiKey = dotenv.get("OCR_KEY");

    Map data = {
      "images": [
        {"format": imageType, "name": "pickedImage", "data": img64, "url": null}
      ],
      "lang": "ko",
      "requestId": "string",
      "resultType": "string",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "version": "V2"
    };

    var result = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'X-OCR-SECRET': apiKey,
        },
        body: json.encode(data));

    var resBody = jsonDecode(result.body);

    setState(() {
      _parsedTasks = parseText(resBody);
      taskParsed = true;
    });
  }

  Future _selectDate(key) async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateFormat('yy-M-d').parse(key),
        firstDate: DateTime(2020),
        lastDate: DateTime(2080));
    if (picked != null) {
      setState(() {
        String origKey = key;
        String newKey = DateFormat('yyyy-MM-dd').format(picked);
        _parsedTasks[newKey] = _parsedTasks[origKey] ?? [];
        _parsedTasks.remove(origKey);
      });
    }
  }

  Widget tasksListView(key) {
    var tLV = Column(
      children: [
        TextFormField(
          decoration: key != ''
              ? const InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 5.0, right: 20.0),
                    child: Icon(Icons.calendar_today_rounded),
                  ),
                  prefixIconConstraints:
                      BoxConstraints(minWidth: 0, minHeight: 0),
                  border: InputBorder.none,
                )
              : const InputDecoration(
                  border: InputBorder.none,
                ),
          controller: TextEditingController(text: key),
          enabled: key == '' ? false : true,
          onTap: key != ''
              ? () {
                  FocusScope.of(context).requestFocus(FocusNode()); //키보드 방지
                  _selectDate(key);
                }
              : () {},
          onChanged: (value) {},
        ),
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _parsedTasks[key]!.length,
            itemBuilder: ((context, index) {
              return Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      initialValue: _parsedTasks[key]![index],
                      decoration: InputDecoration(
                        prefixIcon: Text('Task $index     '),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        _parsedTasks[key]![index] = value;
                      },
                    ),
                  )
                ],
              );
            })),
        const Padding(padding: EdgeInsets.only(bottom: 30.0))
      ],
    );
    return tLV;
  }

  saveTasks() async {
    for (var key in _parsedTasks.keys) {
      DateTime? tDate;
      if (key != "") {
        tDate = DateTime.parse(key);
      } else {
        tDate = null;
      }

      if (_parsedTasks[key] != []) {
        for (var task in _parsedTasks[key]!) {
          final newTask = <String, dynamic>{
            "date": tDate,
            "done": false,
            "time": null,
            "title": task
          };
          final data = Map<String, dynamic>.from(newTask);
          await taskDBS.create(data);
        }
      }
    }
    if (context.mounted) Navigator.pop(context);
  }
}
