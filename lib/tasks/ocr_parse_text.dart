import 'package:intl/intl.dart';

Map<String, List<String>> parseText(response) {
  final parsedTasks = <String, List<String>>{};
  RegExp dateFormat = RegExp(
      r"((\d{4})|\d{2})?(-|\/|.|년 )?([1-9]|0[1-9]|1[0-2])( )?(-|\/|.|월 )( )?(([1-9]|0[1-9]|[1-2][0-9]|3[01]))일?( )?$");

  String taskDate = '';
  String parsedtxt = '';

  for (var field in response['images'][0]['fields']) {
    String txt = field['inferText'];
    if (txt == '') continue;
    parsedtxt == '' ? parsedtxt += txt : parsedtxt += ' $txt';

    if (field['lineBreak']) {
      String td = dateFormat.stringMatch(parsedtxt) ?? '';

      if (td != '') {
        taskDate = getDate(dateFormat.stringMatch(parsedtxt));
        parsedtxt = parsedtxt.replaceAll(td, '');
      }

      if (parsedTasks[taskDate] == null) parsedTasks[taskDate] = [];
      if (parsedtxt != '') parsedTasks[taskDate]!.add(parsedtxt);
      parsedtxt = '';
    }
  }
  return parsedTasks;
}

String getDate(dateParsed) {
  String dateTmp = dateParsed.replaceAll(RegExp(r"[\/|.|월|년]"), '-');
  dateTmp = dateTmp.replaceAll(RegExp(r"[ |일]"), '');

  try {
    DateTime dateVal = DateFormat('yy-M-d').parse(dateTmp);
    return DateFormat('yyyy-MM-dd').format(dateVal);
  } on FormatException {
    try {
      String yMd = '';
      DateTime parseTmp = DateFormat('M-d').parse(dateTmp);
      if (parseTmp.month < DateTime.now().month ||
          (parseTmp.month == DateTime.now().month) &&
              (parseTmp.day < DateTime.now().day)) {
        yMd = '${DateTime.now().year + 1}-$dateTmp';
      } else {
        yMd = '${DateTime.now().year}-$dateTmp';
      }
      DateTime dateVal = DateFormat('yy-M-d').parse(yMd);
      return DateFormat('yyyy-MM-dd').format(dateVal);
    } catch (e) {
      return '';
    }
  }
}
