import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:jday/weather/weather_calcXY.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  // default address = 강남구 역삼동
  late String _addrText;
  late double _latY;
  late double _longX;
  late int _gridX;
  late int _gridY;
  Map<String, dynamic> _weatherValue = <String, dynamic>{};
  late final weatherInfo = getWeather();

  @override
  void initState() {
    super.initState();

    _addrText = '강남구 역삼동';
    _latY = 37.49530540462;
    _longX = 127.03312866105163;
    _gridX = 61;
    _gridY = 125;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.location_searching),
              onPressed: () {
                getLocation();
              },
            ),
            Text(
              _addrText,
              style: const TextStyle(fontSize: 14.0),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          child: FutureBuilder(
            future: weatherInfo,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              return Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 15, 5),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: _weatherValue.containsKey('icon')
                            ? Image.asset(_weatherValue['icon'])
                            : const SizedBox(),
                        // Image.asset(_weatherValue['icon'])),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Text(
                          '${_weatherValue['cuTMP']}℃',
                          style: const TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${_weatherValue['fcTMN']}° / ${_weatherValue['fcTMX']}°',
                          style: const TextStyle(
                              fontSize: 19.0, fontWeight: FontWeight.w200),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '현재 날씨 ',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w200),
                              ),
                              Text(
                                _weatherValue['txt'] ?? "",
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w700),
                              ),
                            ]),
                        _weatherValue.containsKey('fcPOP')
                            ? Text(
                                '${_weatherValue['fcPOPtxt']}시부터 강수확률 ${_weatherValue['fcPOP'][1]}%',
                                style: const TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      getAddress(position.longitude.toString(), position.latitude.toString());
      getWeather();
    } on Exception {
      getAddress(_longX.toString(), _latY.toString());
      getWeather();
    }
  }

  Future getAddress(String longV, String latV) async {
    var apiUrl =
        'https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=$longV&y=$latV';
    var apiKey = dotenv.get("ADDRESS_KEY");

    var result = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{'Authorization': "KakaoAK $apiKey"});

    var resBody = jsonDecode(result.body);
    String addrText = resBody['documents'][0]['region_2depth_name'] +
        ' ' +
        resBody['documents'][0]['region_3depth_name'];

    setState(() {
      _addrText = addrText;
      _longX = resBody['documents'][0]['x'];
      _latY = resBody['documents'][0]['y'];
    });

    CalcXY curr = transfer(_longX, _latY);

    setState(() {
      _gridX = curr.gridX;
      _gridY = curr.gridY;
    });
  }

  Future getWeather() async {
    Map<String, dynamic> weatherValue = <String, dynamic>{};
    var apiKey = dotenv.get("WEATHER_KEY");
    var tdy = DateTime.now();
    var apiDate = DateFormat('yyyyMMdd').format(tdy);
    var apiDate1 = DateFormat('yyyyMMdd')
        .format(DateTime(tdy.year, tdy.month, tdy.day - 1));

    int time = int.parse(DateFormat('HH').format(DateTime.now()));
    int apiTimeTmp = forecastTime(time);
    var apiTime = '${apiTimeTmp}00';
    var apiTime2 = '${time + 1}00';

    var apiUrlForecast1 =
        "https://proxy.cors.sh/http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=$apiKey&numOfRows=500&pageNo=1&base_date=$apiDate&base_time=1700&nx=$_gridX&ny=$_gridY&dataType=JSON";
    var forecastResult1 = await http.get(Uri.parse(apiUrlForecast1),
        headers: {'x-cors-api-key': dotenv.get("CORS_KEY")});
    var forecastResBody1 = jsonDecode(forecastResult1.body);

    if (forecastResBody1['response']['header']['resultCode'] == '03') {
      apiUrlForecast1 =
          "https://proxy.cors.sh/http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=$apiKey&numOfRows=500&pageNo=1&base_date=$apiDate1&base_time=2300&nx=$_gridX&ny=$_gridY&dataType=JSON";
      forecastResult1 = await http.get(Uri.parse(apiUrlForecast1),
          headers: {'x-cors-api-key': dotenv.get("CORS_KEY")});
      forecastResBody1 = jsonDecode(forecastResult1.body);

      forecastResBody1 = forecastResBody1['response']['body']['items']['item'];
      forecastResBody1.forEach((element) {
        if (element['fcstDate'] == apiDate) {
          if (element['category'] == 'TMN') {
            // 일 최저기온
            weatherValue['fcTMN'] = double.parse(element['fcstValue']).round();
          } else if (element['category'] == 'TMX') {
            // 일 최고기온
            weatherValue['fcTMX'] = double.parse(element['fcstValue']).round();
          }
        }
      });
    } else {
      forecastResBody1 = forecastResBody1['response']['body']['items']['item'];
      forecastResBody1.forEach((element) {
        if (element['category'] == 'TMN') {
          // 일 최저기온
          weatherValue['fcTMN'] = double.parse(element['fcstValue']).round();
        } else if (element['category'] == 'TMX') {
          // 일 최고기온
          weatherValue['fcTMX'] = double.parse(element['fcstValue']).round();
        }
      });
    }

    var apiUrlForecast2 =
        "https://proxy.cors.sh/http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=$apiKey&numOfRows=500&pageNo=1&base_date=$apiDate&base_time=$apiTime&nx=$_gridX&ny=$_gridY&dataType=JSON";
    var forecastResult2 = await http.get(Uri.parse(apiUrlForecast2),
        headers: {'x-cors-api-key': dotenv.get("CORS_KEY")});
    var forecastResBody2 = jsonDecode(forecastResult2.body);

    if (forecastResBody2['response']['header']['resultCode'] == '03') {
      if (time < 3) {
        apiTime = '2300';
        apiUrlForecast2 =
            "https://proxy.cors.sh/http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=$apiKey&numOfRows=500&pageNo=1&base_date=$apiDate1&base_time=$apiTime&nx=$_gridX&ny=$_gridY&dataType=JSON";
        forecastResult2 = await http.get(Uri.parse(apiUrlForecast2),
            headers: {'x-cors-api-key': dotenv.get("CORS_KEY")});
        forecastResBody2 = jsonDecode(forecastResult2.body);
      } else {
        apiTime = '${apiTimeTmp - 3}00';
        apiUrlForecast2 =
            "https://proxy.cors.sh/http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=$apiKey&numOfRows=500&pageNo=1&base_date=$apiDate&base_time=$apiTime&nx=$_gridX&ny=$_gridY&dataType=JSON";
        forecastResult2 = await http.get(Uri.parse(apiUrlForecast2),
            headers: {'x-cors-api-key': dotenv.get("CORS_KEY")});
        forecastResBody2 = jsonDecode(forecastResult2.body);
      }
    }
    forecastResBody2 = forecastResBody2['response']['body']['items']['item'];
    forecastResBody2.forEach((element) {
      if (element['fcstDate'] == apiDate) {
        if (apiTime2.length == 3) {
          apiTime2 = '0$apiTime2';
        }
        if (element['category'] == 'SKY' && element['fcstTime'] == apiTime2) {
          // 하늘 상태
          weatherValue['fcSKY'] = element['fcstValue'];
        } else if (element['category'] == 'POP' &&
            int.parse(element['fcstValue']) > 0) {
          // 강수확률
          if (weatherValue.containsKey('fcPOP') == false) {
            weatherValue['fcPOP'] = [element['fcstTime'], element['fcstValue']];
            var fcPtime = DateFormat('hh')
                .parse(element['fcstTime'].toString().substring(0, 2));
            weatherValue['fcPOPtxt'] = DateFormat('aa h', 'ko').format(fcPtime);
          }
        }
      }
    });

    var apiUrlCurrent =
        "https://proxy.cors.sh/http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?serviceKey=$apiKey&numOfRows=10&pageNo=1&base_date=$apiDate&base_time=$apiTime2&nx=$_gridX&ny=$_gridY&dataType=JSON";
    var currentResult = await http.get(Uri.parse(apiUrlCurrent),
        headers: {'x-cors-api-key': dotenv.get("CORS_KEY")});
    var currentResBody = jsonDecode(currentResult.body);

    if (currentResBody['response']['header']['resultCode'] == '03') {
      apiTime2 = '${time - 1}00';
      apiUrlCurrent =
          "https://proxy.cors.sh/http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?serviceKey=$apiKey&numOfRows=10&pageNo=1&base_date=$apiDate&base_time=$apiTime2&nx=$_gridX&ny=$_gridY&dataType=JSON";
      currentResult = await http.get(Uri.parse(apiUrlCurrent),
          headers: {'x-cors-api-key': dotenv.get("CORS_KEY")});
      currentResBody = jsonDecode(currentResult.body);
    }
    currentResBody = currentResBody['response']['body']['items']['item'];
    currentResBody.forEach((element) {
      if (element['category'] == 'T1H') {
        weatherValue['cuTMP'] = double.parse(element['obsrValue']).round();
      } else if (element['category'] == 'PTY') {
        weatherValue['cuPTY'] = element['obsrValue'];
      }
    });

    weatherValue = weatherUI(weatherValue);
    setState(() {
      _weatherValue = weatherValue;
    });
  }

  int forecastTime(int time) {
    int apiTimeTmp = 5;

    if (2 <= time && time < 5) {
      apiTimeTmp = 2;
    } else if (5 <= time && time < 8) {
      apiTimeTmp = 5;
    } else if (8 <= time && time < 11) {
      apiTimeTmp = 8;
    } else if (11 <= time && time < 14) {
      apiTimeTmp = 11;
    } else if (14 <= time && time < 17) {
      apiTimeTmp = 14;
    } else if (17 <= time && time < 20) {
      apiTimeTmp = 17;
    } else if (20 <= time && time < 23) {
      apiTimeTmp = 20;
    } else if (23 <= time && time < 2) {
      apiTimeTmp = 23;
    }
    return apiTimeTmp;
  }

  Map<String, dynamic> weatherUI(weatherValue) {
    int time = int.parse(DateFormat('HH').format(DateTime.now()));

    if (weatherValue['cuPTY'] == '0') {
      if (weatherValue['fcSKY'] == '1') {
        weatherValue['icon'] =
            (time < 18) ? 'assets/img-res/sun.png' : 'assets/img-res/moon.png';
        weatherValue['txt'] = '맑음';
      } else if (weatherValue['fcSKY'] == '3') {
        weatherValue['icon'] = (time < 18)
            ? 'assets/img-res/cloudy_sun.png'
            : 'assets/img-res/cloudy_moon.png';
        weatherValue['txt'] = '구름많음';
      } else if (weatherValue['fcSKY'] == '4') {
        weatherValue['icon'] = 'assets/img-res/cloud.png';
        weatherValue['txt'] = '흐림';
      }
    } else {
      if (weatherValue['cuPTY'] == '1') {
        weatherValue['icon'] = 'assets/img-res/rain.png';
        weatherValue['txt'] = '비';
      } else if (weatherValue['cuPTY'] == '2') {
        weatherValue['icon'] = 'assets/img-res/rainsnow.png';
        weatherValue['txt'] = '비·눈';
      } else if (weatherValue['cuPTY'] == '3') {
        weatherValue['icon'] = 'assets/img-res/snow.png';
        weatherValue['txt'] = '눈';
      } else if (weatherValue['cuPTY'] == '5') {
        weatherValue['icon'] = 'assets/img-res/raindrop.png';
        weatherValue['txt'] = '빗방울';
      } else if (weatherValue['cuPTY'] == '6') {
        weatherValue['icon'] = 'assets/img-res/rainsnow.png';
        weatherValue['txt'] = '빗방울·눈날림';
      }
    }
    return weatherValue;
  }
}
