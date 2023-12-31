import 'dart:math';

class CalcXY {
  late int gridX;
  late int gridY;

  CalcXY(this.gridX, this.gridY);
}

CalcXY transfer(double long, double lati) {
  double RE = 6371.00877; // 지구 반경(km)
  double GRID = 5.0; // 격자 간격(km)
  double SLAT1 = 30.0; // 표준위도 1
  double SLAT2 = 60.0; // 표준위도 2
  double OLON = 126.0; // 기준점 경도
  double OLAT = 38.0; // 기준점 위도
  double XO = 210 / GRID;
  double YO = 675 / GRID;

  double DEGRAD = pi / 180.0;

  double re = RE / GRID;
  double slat1 = SLAT1 * DEGRAD;
  double slat2 = SLAT2 * DEGRAD;
  double olon = OLON * DEGRAD;
  double olat = OLAT * DEGRAD;

  double sn = tan(pi * 0.25 + slat2 * 0.5) / tan(pi * 0.25 + slat1 * 0.5);
  sn = log(cos(slat1) / cos(slat2)) / log(sn);
  double sf = tan(pi * 0.25 + slat1 * 0.5);
  sf = pow(sf, sn) * cos(slat1) / sn;
  double ro = tan(pi * 0.25 + olat * 0.5);
  ro = re * sf / pow(ro, sn);

  double ra = tan(pi * 0.25 + lati * DEGRAD * 0.5);
  ra = re * sf / pow(ra, sn);
  double theta = long * DEGRAD - olon;
  if (theta > pi) theta -= 2.0 * pi;
  if (theta < -pi) theta += 2.0 * pi;
  theta *= sn;

  double x = (ra * sin(theta)) + XO;
  double y = (ro - ra * cos(theta)) + YO;
  x = x + 1.5;
  y = y + 1.5;
  return CalcXY(x.toInt(), y.toInt());
}
