import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'FirstStartPage.dart';
import 'alarm.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure plugin services are initialized
  final prefs = await SharedPreferences.getInstance();
  final isFirstStart = prefs.getBool('isFirstStart') ??
      true; // Get isFirstStart value, default to true
  // final isFirstStart = true;

  runApp(MyApp(isFirstStart: isFirstStart));
}

class MyApp extends StatelessWidget {
  final bool isFirstStart;

  MyApp({required this.isFirstStart});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      home: isFirstStart
          ? FirstStartPage()
          : MainPage(), // Show FirstStartPage or MainPage based on isFirstStart
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  List<TextEditingController> waypointControllers = List.generate(
    5,
    (index) => TextEditingController(),
  );
  String coordinates = '';
  String travelTime = '';
  int toggleValue = 0;
  int selectedChip = 0;

  String startCoord_N = '';
  String endCoord_N = '';
  String startCoord = '';
  String endCoord = '';
  List<dynamic> recommendedPosts = [];
  final List<String> chipLabels = [
    '전체',
    '서비스기획',
    '개발',
    '데이터/AI/ML',
    '마케팅/광고/홍보',
    '디자인',
    '미디어/커뮤니케이션',
    '이커머스/리테일',
    '금융/컨설팅/VC',
    '회계/재무',
    '인사/채용/노무',
    '고객/영업',
    '게임 기획/개발',
    '물류/구매',
    '의료/제약/바이오',
    '연구/R&D',
    '엔지니어링/설계',
    '생산/품질',
    '교육',
    '법률/특허',
    '공공/복지/환경',
  ];
  final List<String> items = [
    'IT',
    '인사',
    '품질관리',
    '마케팅',
    '회계',
    '취직',
    '재무관리',
    '응용통계',
  ];

  @override
  void initState() {
    super.initState();
    checkFirstStartAndFetchData();
  }

  // 콘솔에 출발지와 도착지 좌표 출력
  void printCoordinates() {
    print(startCoord);
    print(endCoord);
  }

  Future<void> checkFirstStartAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstStart = prefs.getBool('isFirstStart') ?? true;

    if (!isFirstStart) {
      // isFirstStart가 false일 경우
      final userId = prefs.getInt('userAppCode') ?? 0;
      await fetchRecommendedPosts(userId);
      print(recommendedPosts); // 콘솔에 추천 게시글 데이터 출력
    }
  }

  Future<void> fetchRecommendedPosts(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("http://43.202.218.152/user/$userId/recommended-post"),
      );

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);

        setState(() {
          recommendedPosts = json.decode(responseBody);
        });
      } else {
        print("Failed to load recommended posts");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> searchCoord_s(
      String startName, String endName, List<String> waypointNames) async {
    String baseUrl =
        "https://apis.openapi.sk.com/tmap/pois?version=1&count=1&searchKeyword=";
    String appKey = "l7xxf27945b5f29e4c9d8e9c478bcae12841"; // 실제 앱 키를 입력해야 함.
    startCoord_N = startName;
    endCoord_N = endName;

    try {
      var startResponse = await http.get(
        Uri.parse("$baseUrl$startName&appKey=$appKey"),
      );
      var startData = json.decode(startResponse.body);
      var startId = startData['searchPoiInfo']['pois']['poi'][0]['id'];
      var sx = startData['searchPoiInfo']['pois']['poi'][0]['noorLon'];
      var sy = startData['searchPoiInfo']['pois']['poi'][0]['noorLat'];

      var endResponse = await http.get(
        Uri.parse("$baseUrl$endName&appKey=$appKey"),
      );
      var endData = json.decode(endResponse.body);
      var endId = endData['searchPoiInfo']['pois']['poi'][0]['id'];
      var ex = endData['searchPoiInfo']['pois']['poi'][0]['noorLon'];
      var ey = endData['searchPoiInfo']['pois']['poi'][0]['noorLat'];

      String passList = "";

      for (int i = 0; i < waypointNames.length; i++) {
        if (waypointNames[i].isNotEmpty) {
          var waypointResponse = await http.get(
            Uri.parse("$baseUrl${waypointNames[i]}&appKey=$appKey"),
          );
          var waypointData = json.decode(waypointResponse.body);
          var waypointId =
              waypointData['searchPoiInfo']['pois']['poi'][0]['id'];
          var waypointX =
              waypointData['searchPoiInfo']['pois']['poi'][0]['noorLon'];
          var waypointY =
              waypointData['searchPoiInfo']['pois']['poi'][0]['noorLat'];

          if (passList.isNotEmpty) {
            passList += "_";
          }
          passList += "$waypointX,$waypointY,$waypointId";
        }
      }

      setState(() {
        coordinates = "출발: ($sx, $sy, $startId), 도착: ($ex, $ey, $endId)";
        if (passList.isNotEmpty) {
          coordinates += ", 경유지: $passList";
        }
      });

      // fetchTravelTime(sx, sy, ex, ey);
      // _showMapPopup(sx, sy, ex, ey, endId, passList);

      // 출발지와 도착지 좌표를 변수에 저장
      startCoord = "출발지: ($sx, $sy)";
      endCoord = "도착지: ($ex, $ey)";
    } catch (e) {
      setState(() {
        coordinates = "오류 발생: $e";
      });
    }
  }

  Future<void> searchCoord(
      String startName, String endName, List<String> waypointNames) async {
    String baseUrl =
        "https://apis.openapi.sk.com/tmap/pois?version=1&count=1&searchKeyword=";
    String appKey = "l7xxf27945b5f29e4c9d8e9c478bcae12841"; // 실제 앱 키를 입력해야 함.
    startCoord_N = startName;
    endCoord_N = endName;

    try {
      var startResponse = await http.get(
        Uri.parse("$baseUrl$startName&appKey=$appKey"),
      );
      var startData = json.decode(startResponse.body);
      var startId = startData['searchPoiInfo']['pois']['poi'][0]['id'];
      var sx = startData['searchPoiInfo']['pois']['poi'][0]['noorLon'];
      var sy = startData['searchPoiInfo']['pois']['poi'][0]['noorLat'];

      var endResponse = await http.get(
        Uri.parse("$baseUrl$endName&appKey=$appKey"),
      );
      var endData = json.decode(endResponse.body);
      var endId = endData['searchPoiInfo']['pois']['poi'][0]['id'];
      var ex = endData['searchPoiInfo']['pois']['poi'][0]['noorLon'];
      var ey = endData['searchPoiInfo']['pois']['poi'][0]['noorLat'];

      String passList = "";

      for (int i = 0; i < waypointNames.length; i++) {
        if (waypointNames[i].isNotEmpty) {
          var waypointResponse = await http.get(
            Uri.parse("$baseUrl${waypointNames[i]}&appKey=$appKey"),
          );
          var waypointData = json.decode(waypointResponse.body);
          var waypointId =
              waypointData['searchPoiInfo']['pois']['poi'][0]['id'];
          var waypointX =
              waypointData['searchPoiInfo']['pois']['poi'][0]['noorLon'];
          var waypointY =
              waypointData['searchPoiInfo']['pois']['poi'][0]['noorLat'];

          if (passList.isNotEmpty) {
            passList += "_";
          }
          passList += "$waypointX,$waypointY,$waypointId";
        }
      }

      setState(() {
        coordinates = "출발: ($sx, $sy, $startId), 도착: ($ex, $ey, $endId)";
        if (passList.isNotEmpty) {
          coordinates += ", 경유지: $passList";
        }
      });

      // fetchTravelTime(sx, sy, ex, ey);
      _showMapPopup(sx, sy, ex, ey, endId, passList);

      // 출발지와 도착지 좌표를 변수에 저장
      startCoord = "출발지: ($sx, $sy)";
      endCoord = "도착지: ($ex, $ey)";
    } catch (e) {
      setState(() {
        coordinates = "오류 발생: $e";
      });
    }
  }

  void onPostClicked(dynamic post) {
    if (startCoord_N.isEmpty || endCoord_N.isEmpty) {
      showPopup("출발지와 도착지를 입력해주셔야 상세 정보를 확인할 수 있습니다");
      return;
    }

    // 게시글에서 출발지와 도착지를 가져옵니다.
    String postDeparture = post['departureAddress'];
    String postDestination = post['destinationAddress'];

    // 경유지 목록에 게시글의 출발지와 도착지를 추가합니다.
    List<String> waypointNames = [postDeparture, postDestination];

    // searchCoord 함수를 호출합니다.
    searchCoord(startCoord_N, endCoord_N, waypointNames);
  }

  Future<void> fetchTravelTime(
      String sx, String sy, String ex, String ey) async {
    String url =
        "https://apis.openapi.sk.com/tmap/routes?version=1&format=json&callback=result";
    Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded"
    };
    Map<String, String> body = {
      "appKey": "l7xxf27945b5f29e4c9d8e9c478bcae12841",
      "startX": sx,
      "startY": sy,
      "endX": ex,
      "endY": ey,
      "reqCoordType": "WGS84GEO",
      "resCoordType": "EPSG3857",
      "searchOption": "0",
      "trafficInfo": "N"
    };

    try {
      var response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var totalTime =
            data['features'][0]['properties']['totalTime']; // 실제 응답에 맞게 조정
        setState(() {
          travelTime = "예상 이동 시간: ${totalTime ~/ 60} 분";
        });
      } else {
        setState(() {
          travelTime = "이동 시간 가져오기 실패";
        });
      }
    } catch (e) {
      setState(() {
        travelTime = "오류 발생: $e";
      });
    }
  }

  void _showMapPopup(String sx, String sy, String ex, String ey, String endId,
      String passList) {
    String appKey = "l7xxf27945b5f29e4c9d8e9c478bcae12841"; // 실제 앱 키를 입력해야 함.
    String initialUrl =
        'https://apis.openapi.sk.com/tmap/routeStaticMap?appKey=$appKey&endX=$ex&endY=$ey&startX=$sx&startY=$sy&reqCoordType=WGS84GEO&endPoiId=$endId';

    if (passList.isNotEmpty) {
      initialUrl += "&passList=$passList";
    }
    initialUrl += "&lineColor=red&width=512&height=512";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            height: 350,
            child: WebView(
              initialUrl: initialUrl,
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("알림"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("닫기"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showPostDialog(BuildContext context) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String title = '';
    String startLocation = '';
    String endLocation = '';
    String details = '';
    int mentorMenteeToggle = 0;
    int carpoolTaxiToggle = 0;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userAppCode') ?? '없음';

    Future<void> sendPostData() async {
      // 출발지와 도착지의 좌표를 검색합니다.
      await searchCoord_s(startLocation, endLocation, []);

      String url = 'http://43.202.218.152/post'; // 실제 서버 URL로 변경 필요
      Map<String, dynamic> postData = {
        "title": title,
        "body": details,
        "userId": userId,
        "departureAddress": startLocation,
        "destinationAddress": endLocation,
        "departLat": startCoord.split('(')[1].split(',')[0],
        "departLon": startCoord.split(',')[1].split(')')[0],
        "destiLat": endCoord.split('(')[1].split(',')[0],
        "destiLon": endCoord.split(',')[1].split(')')[0],
        "timeRange": {
          "from": "2023-11-11:00:00", // 실제 시간 데이터로 변경 필요
          "to": "2023-11-12:12:00" // 실제 시간 데이터로 변경 필요
        },
        "payRatio": 0.3,
        "type": mentorMenteeToggle == 0 ? "MENTOR" : "MENTEE",
        "transformation": carpoolTaxiToggle == 0 ? "CARPOOL" : "TAXI"
      };

      try {
        var response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(postData),
        );

        // if (response.statusCode == 200) {
        //   print('Server Response: ${response.body}');
        // } else {
        //   print('Request failed with status: ${response.statusCode}.');
        // }
      } catch (e) {
        print('Error sending post data: $e');
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "게시글 등록",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          shape: RoundedRectangleBorder(
            // 모서리 둥글게
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 10), // 여기서 조정합니다
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Divider(color: Color(0xFFE1E1E1)),
                      SizedBox(height: 10),
                      CustomToggleSwitch(
                        height: 30,
                        borderRadius: 15,
                        backgroundColor: Colors.grey,
                        options: ['멘토', '멘티'],
                        toggleValue: mentorMenteeToggle,
                        onChanged: (index) {
                          setState(() {
                            mentorMenteeToggle = index;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      CustomToggleSwitch(
                        height: 30,
                        borderRadius: 15,
                        backgroundColor: Colors.grey,
                        options: ['카풀', '택시'],
                        toggleValue: carpoolTaxiToggle,
                        onChanged: (index) {
                          setState(() {
                            carpoolTaxiToggle = index;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      buildTextField('게시글 제목', (value) => title = value!),
                      buildTextField('출발지', (value) => startLocation = value!),
                      buildTextField('도착지', (value) => endLocation = value!),
                      buildTextField('상세내용', (value) => details = value!),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                sendPostData(); // 서버에 데이터 전송
                                Navigator.pop(context);
                                // showDialog(
                                //   context: context,
                                //   builder: (context) => AlertDialog(
                                //     title: Text("등록 내용 확인"),
                                //     content: SingleChildScrollView(
                                //       child: ListBody(
                                //         children: <Widget>[
                                //           Text("제목: $title"),
                                //           Text("출발지: $startLocation"),
                                //           Text("도착지: $endLocation"),
                                //           Text("상세내용: $details"),
                                //           Text(
                                //               "멘토/멘티: ${mentorMenteeToggle == 0 ? "멘토" : "멘티"}"),
                                //           Text(
                                //               "카풀/택시: ${carpoolTaxiToggle == 0 ? "카풀" : "택시"}"),
                                //         ],
                                //       ),
                                //     ),
                                //     actions: <Widget>[
                                //       TextButton(
                                //         child: Text("닫기"),
                                //         onPressed: () =>
                                //             Navigator.of(context).pop(),
                                //       ),
                                //     ],
                                //   ),
                                // );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF5521EB), // 배경색
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10), // 라운드 모서리
                              ),
                              minimumSize: Size(120, 40), // 너비와 높이
                            ),
                            child: Text('등록'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFFFAFBFD), // 배경색
                              side:
                                  BorderSide(color: Color(0xFF5521EB)), // 보더 색상
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10), // 라운드 모서리
                              ),
                              minimumSize: Size(120, 40), // 너비와 높이
                            ),
                            child: Text(
                              '닫기',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF5521EB), // 글씨색
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildTextField(String label, void Function(String?) onSave) {
    return Container(
      height: 40,
      margin: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFBFC0C7)),
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
        ),
        onSaved: onSave,
      ),
    );
  }

  // 필터 옵션을 저장하는 변수 추가
  String filterOption = '전체';

  // 필터에 따라 게시글 목록을 조건부로 반환하는 함수
  List<dynamic> getFilteredPosts() {
    // 현재 선택된 카테고리
    String selectedCategory = chipLabels[selectedChip];

    // 필터링된 게시글 목록
    List<dynamic> filteredPosts = recommendedPosts;

    // 멘토/멘티 필터링
    if (filterOption != '전체') {
      filteredPosts = filteredPosts
          .where((post) =>
              post['type'] == (filterOption == '멘토' ? 'MENTOR' : 'MENTEE'))
          .toList();
    }

    // 카테고리 필터링 (전체가 아닌 경우에만)
    if (selectedChip != 0) {
      filteredPosts = filteredPosts
          .where((post) => post['userInfo']['category'] == selectedCategory)
          .toList();
    }

    return filteredPosts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '경로 검색',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '이동하실 경로를 검색해 주세요',
                          style: TextStyle(
                            color: Color(0xFF8A8BB1),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => alarmPage()), // AlarmPage로 이동
                      );
                    },
                    // showPopup("알림입니다"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getInt('userAppCode') ?? '없음';
                      showPopup("User ID: $userId");
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 30.0, // Container의 높이를 30.0으로 고정
                          child: TextField(
                            controller: startController,
                            decoration: InputDecoration(
                              hintText: '출발지',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                            ),
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 30.0, // Container의 높이를 30.0으로 고정
                          child: TextField(
                            controller: endController,
                            decoration: InputDecoration(
                              hintText: '도착지',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                            ),
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // List<String> waypointNames =
                      //     waypointControllers.map((c) => c.text).toList();
                      // searchCoord(startController.text, endController.text,
                      //     waypointNames);
                      startCoord_N = startController.text;
                      endCoord_N = endController.text;
                      showPopup("이제 상세 경로를 확인하실 수 있습니다.");
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFFAFBFD), // 배경색
                      side: BorderSide(color: Color(0xFF615CEC)), // 보더 색상
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // 라운드 모서리
                      ),
                      minimumSize: Size(79, 70), // 너비와 높이
                    ),
                    child: Text(
                      '검색',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF615CEC), // 글씨색
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 3-way toggle switch widget
                      CustomToggleSwitch(
                        height: 30,
                        borderRadius: 15,
                        backgroundColor: Color(0xFFB9BBE9),
                        options: ['전체', '멘토', '멘티'],
                        toggleValue: filterOption == '전체'
                            ? 0
                            : (filterOption == '멘토' ? 1 : 2),
                        onChanged: (index) {
                          setState(() {
                            filterOption = ['전체', '멘토', '멘티'][index];
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ]),
              SizedBox(height: 16),
              Container(
                height: 32.0, // 원하는 높이로 설정
                child: ListView.builder(
                  padding: EdgeInsets.zero, // ListView의 패딩을 제거합니다.
                  scrollDirection: Axis.horizontal,
                  itemCount: chipLabels.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedChip == index;
                    return GestureDetector(
                      onTap: () {
                        if (!isSelected) {
                          // 이미 선택된 상태가 아닐 때만 상태 업데이트
                          setState(() {
                            selectedChip = index;
                          });
                        }
                      },
                      child: Container(
                        // Container의 높이를 지정합니다.
                        height: 32.0, // 원하는 높이로 설정
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0), // 컨테이너 내부의 좌우 패딩
                        margin: EdgeInsets.symmetric(
                            horizontal: 4.0), // 컨테이너 외부의 좌우 마진
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey
                                    .withOpacity(0.5), // 선택되지 않았을 때의 테두리 색상
                          ),
                        ),
                        child: Text(
                          chipLabels[index],
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Container(
                child: Expanded(
                  child: ListView.builder(
                    itemCount: getFilteredPosts().length, // 필터링된 게시글 목록 길이 사용
                    itemBuilder: (BuildContext context, int index) {
                      var post = getFilteredPosts()[index]; // 필터링된 게시글 목록 사용
                      var title = post['title']; // 'title' 키를 사용하여 타이틀을 가져옵니다.
                      var departure = post['departureAddress'] ??
                          '출발지 정보 없음'; // 'departureAddress' 키를 사용합니다.
                      var destination = post['destinationAddress'] ??
                          '도착지 정보 없음'; // 'destinationAddress' 키를 사용합니다.
                      var subtitle =
                          '$departure - $destination'; // 출발지와 도착지를 연결하여 표시합니다.
                      var tag = post['type'] == 'MENTOR'
                          ? '멘토'
                          : '멘티'; // 'type' 키를 기반으로 태그를 결정합니다.

                      return GestureDetector(
                        onTap: () => onPostClicked(post),
                        child: Container(
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR5TulwreiAilalNuCPYfWqf1uaFawcRHBSgekfTY-WMC3hCz449Gq3Tnnl08SikllFBXE&usqp=CAU'), // 네트워크 이미지
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title ?? '제목 없음', // 타이틀
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      subtitle, // 서브 타이틀: 출발지 - 도착지
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF8A8BB1),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFD600),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        tag, // 태그
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF615CEC), // 버튼 배경색 설정
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // 버튼 모서리 둥글게 설정
                    ),
                    minimumSize: Size(double.infinity, 49), // 버튼의 최소 크기 설정
                  ),
                  onPressed: () {
                    showPostDialog(context);
                  },
                  child: Text(
                    "게시글 등록",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // 글자색 설정
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// CustomToggleSwitch 클래스를 수정하여, 옵션 개수와 옵션 이름을 지정할 수 있도록 함
class CustomToggleSwitch extends StatelessWidget {
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final List<String> options;
  final int toggleValue;
  final Function(int) onChanged;

  CustomToggleSwitch({
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
    required this.options,
    required this.toggleValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Color(0xFFB9BBE9), // 수정됨: 배경색을 흰색으로 설정
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: options.asMap().entries.map((entry) {
          int idx = entry.key;
          String val = entry.value;
          bool isSelected = toggleValue == idx;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(idx),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF615CEC) : Color(0xFFB9BBE9),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                alignment: Alignment.center,
                child: Text(
                  val,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
