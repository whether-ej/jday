# jday   <img width='25' src='https://github.com/whether-ej/jday/assets/76941890/67ca39a3-79fc-416f-8e9d-ef99d8c79c18'> 

Flutter로 구현한 일정관리 애플리케이션


<img width='300' src='https://github.com/whether-ej/jday/assets/76941890/c2b8cb0c-be42-4996-b99e-e1cad7269c08'>
       
<img width='300' src='https://github.com/whether-ej/jday/assets/76941890/4ee4083b-0cdf-4914-a2ca-fd26abb2c85c'>
       
<img width='300' src='https://github.com/whether-ej/jday/assets/76941890/a42bfd81-4960-40e0-9a1b-38404f5d83d2'>
       
### 기능

1. 날씨 위젯
   
    현재 온도, 일 최저.최고기온, 현재 날씨 상태, 강수확률 확인
    - 카카오 Local API '좌표로 행정구역 정보 받기' (역지오코딩으로 Flutter에서 받은 좌표로 주소 표시)
    - 기상청 OpenAPI '단기예보 조회'(일 최저.최고기온, 날씨 상태, 강수확률)
    - 기상청 OpenAPI '초단기 실황 조회' (현재 온도, 강수형태)<br><br>


2. 캘린더
   
    한달 단위 캘린더에 일정 유무 여부 표시, 날짜를 선택해 당일 일정 목록 확인
   
    일정 추가, 수정, 삭제
   
      <img width='300' src='https://github.com/whether-ej/jday/assets/76941890/6a1afda3-407e-4a4e-84ad-122b8354d174'>
      <img width='300' src='https://github.com/whether-ej/jday/assets/76941890/d70f4e09-7c5b-4618-b4d7-e086839691d4'>
      
    - TableCalendar 패키지<br><br>


4. Todo

    날짜 지정.미지정 태스크 목록 확인 및 완료 여부 체크

    태스크 추가, 수정, 삭제

    OCR 기능을 이용해 이미지에서 태스크 목록 추출 가능
    - 네이버 클라우드 플랫폼 CLOVA OCR API
      
      <img width='300' src='https://github.com/whether-ej/jday/assets/76941890/278832e9-7223-45a1-af81-b63d605fd7be'>
      <img width='300' src='https://github.com/whether-ej/jday/assets/76941890/2fc53154-2904-4af4-b9bd-65a2875c5067'>
      
      현재 사진과 같이 `날짜 /n 태스크` 형식으로 작성할 경우 날짜 인식 가능<br><br>


---
<br>
    
### 유저 플로우
![process-flow](https://github.com/whether-ej/jday/assets/76941890/4575dd62-6329-4750-84d9-47b526a06084)
