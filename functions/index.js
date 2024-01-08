const functions = require("firebase-functions");
const cors = require("cors")({
  origin: true,
});
const axios = require("axios");

// // 단기예보 조회
// exports.getVilageFcst = functions.https.onRequest((request, response) => {
//   const rq = request.query;
//   console.log(rq);
//   cors(request, response, () => {
//     console.log(request.get("origin"));
//     if (request.get("origin") === "https://jday-4df6b.web.app" || request.get("origin") === "http://localhost:5001") {
//       console.log(`http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=${rq.apiKey}&numOfRows=500&pageNo=1&base_date=${rq.apiDate}&base_time=${rq.baseTime}&nx=${rq.gridX}&ny=${rq.gridY}&dataType=JSON`);

//       // request(`http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=${rq.apiKey}&numOfRows=500&pageNo=1&base_date=${rq.apiDate}&base_time=${rq.baseTime}&nx=${rq.gridX}&ny=${rq.gridY}&dataType=JSON`,
//       //     function(error, res, body) {
//       //       response.send(res);
//       //     });
//       return axios.get(`http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=${rq.apiKey}&numOfRows=500&pageNo=1&base_date=${rq.apiDate}&base_time=${rq.baseTime}&nx=${rq.gridX}&ny=${rq.gridY}&dataType=JSON`)
//           .then((res) => {
//             response.send(res);
//           });
//     }
//   });
// });

// // 초단기 실황 조회
// exports.getUltraSrtNcst = functions.https.onRequest((request, response) => {
//   const rq = request.query;
//   cors(request, response, () => {
//     if (request.get("origin") === "https://jday-4df6b.web.app" || request.get("origin") === "http://localhost:5001") {
//       // request(`http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?serviceKey=${rq.apiKey}&numOfRows=10&pageNo=1&base_date=${rq.apiDate}&base_time=${rq.baseTime}&nx=${rq.gridX}&ny=${rq.gridY}&dataType=JSON`,
//       //   function (error, res, body) {
//       //     response.send(res);
//       //   });
//       return axios.get(`http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?serviceKey=${rq.apiKey}&numOfRows=10&pageNo=1&base_date=${rq.apiDate}&base_time=${rq.baseTime}&nx=${rq.gridX}&ny=${rq.gridY}&dataType=JSON`)
//           .then((res) => {
//             response.send(res);
//           });
//     }
//   });
// });


exports.callOCR = functions.https.onRequest(
    (request, response) => {
      const rq = request.query;
      cors(request, response, () => {
        if (request.get("origin") === "https://jday-4df6b.web.app" || request.get("origin") === "http://localhost:5001") {
          return axios.post("https://mo58gefq0m.apigw.ntruss.com/custom/v1/18971/52eb23e2abfcf09a6fa33340f207ae64708a9d1da37de19958a8fcfa1d5c9b80/general",
              request.body,
              {
                headers: {
                  "Content-Type": "application/json",
                  "X-OCR-SECRET": rq.aK,
                },
              })
              .then((res) => {
                response.send(res.data);
              });
        }
      });
    }
);

// 단기예보 조회
exports.getVilageFcst = functions.https.onRequest(
    (request, response) => {
      const rq = request.query;
      cors(request, response, () => {
        if (request.get("origin") === "https://jday-4df6b.web.app" || request.get("origin") === "http://localhost:5001") {
          return axios.get(`http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?serviceKey=${encodeURIComponent(rq.apiKey)}&numOfRows=500&pageNo=1&base_date=${rq.apiDate}&base_time=${rq.baseTime}&nx=${rq.gridX}&ny=${rq.gridY}&dataType=JSON`)
              .then((res) => {
                console.log(`**basedate=${rq.apiDate}&basetime=${rq.baseTime}`);
                console.log(res.data);
                response.send(res.data);
              });
        }
      });
    }
);

// 초단기 실황 조회
exports.getUltraSrtNcst = functions.https.onRequest(
    (request, response) => {
      const rq = request.query;
      cors(request, response, () => {
        if (request.get("origin") === "https://jday-4df6b.web.app" || request.get("origin") === "http://localhost:5001") {
          return axios.get(`http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?serviceKey=${encodeURIComponent(rq.apiKey)}&numOfRows=10&pageNo=1&base_date=${rq.apiDate}&base_time=${rq.baseTime}&nx=${rq.gridX}&ny=${rq.gridY}&dataType=JSON`)
              .then((res) => {
                console.log(`**basedate=${rq.apiDate}&basetime=${rq.baseTime}`);
                console.log(res.data);
                response.send(res.data);
              });
        }
      });
    }
);
