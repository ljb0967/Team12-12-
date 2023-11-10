import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // main.dart import
import 'package:http/http.dart' as http;

class FirstStartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFBFD), // 배경색 설정
      body: SafeArea(child: FirstPage()),
    );
  }
}

class UserData {
  String nickname = '';
  String homeAddress = '';
  String workAddress = '';
  String phone = '';
  String age = '';
  String field = '';
  String role = '';
  String tenure = '';
  String company = '';
  String profile = '';
  final Set<String> personalities = {};
  final Set<String> interests = {};
  int? userId; // userId를 저장할 변수 추가

  // JSON 데이터로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'image': '이미지 URL', // 이 부분은 적절하게 수정하세요.
      'age': int.tryParse(age) ?? 0,
      'category': field,
      'job': role,
      'company': company,
      'phoneNumber': phone,
      'yearOfExperience': int.tryParse(tenure) ?? 0,
      'departureAddress': homeAddress,
      'destinationAddress': workAddress,
      'departureLat': 35.123124, // 임의의 값
      'departureLon': 127.123124, // 임의의 값
      'destinationLat': 35.123124, // 임의의 값
      'destinationLon': 127.123124, // 임의의 값
      'description': profile,
      'personality': personalities.toList(),
      'interests': interests.toList(),
    };
  }

  // 서버에 데이터 전송 및 응답 처리
  Future<void> sendData(BuildContext context) async {
    var response = await http.post(
      Uri.parse('http://43.202.218.152/user'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(this.toJson()),
    );

    var data = jsonDecode(response.body);
    if (data.containsKey('userId')) {
      this.userId = data['userId'];
      print('Received userId: ${this.userId}');

      // SharedPreferences를 사용하여 userId 저장
      final prefs = await SharedPreferences.getInstance();
      if (this.userId != null) {
        await prefs.setInt('userAppCode', this.userId!); // Non-nullable로 변환
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      _showErrorDialog(context, '서버 연결 에러 500');
    }
  }

  // 에러 메시지를 표시하는 메서드
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('에러'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // SharedPreferences를 사용하여 사용자의 "첫 시작" 상태를 false로 설정
  Future<void> _setFirstStartFalse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstStart', false);
  }

  // 사용자의 입력 결과를 팝업으로 표시하는 메서드
  void showResults(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("입력한 정보"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("닉네임: $nickname"),
                Text("집 주소: $homeAddress"),
                Text("회사 주소: $workAddress"),
                Text("전화번호: $phone"),
                Text("나이: $age"),
                Text("분야: $field"),
                Text("직무: $role"),
                Text("연차: $tenure"),
                Text("재직중인 회사: $company"),
                Text("프로필 상세 정보: $profile"),
                Text("성격: ${personalities.join(", ")}"),
                Text("관심사: ${interests.join(", ")}"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () async {
                Navigator.of(context).pop(); // 대화상자 닫기
                await _setFirstStartFalse(); // isFirstStart를 false로 설정
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => MainPage()), // MainPage로 이동
                  ModalRoute.withName('/'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final userData = UserData();

  final nicknameController = TextEditingController(); // 닉네임 컨트롤러
  final homeAddressController = TextEditingController(); // 집 주소 컨트롤러
  final workAddressController = TextEditingController(); // 회사 주소 컨트롤러
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final fieldController = TextEditingController();
  final roleController = TextEditingController();
  final tenureController = TextEditingController();
  final companyController = TextEditingController();
  final profileController = TextEditingController();

  String selectedJob = '경영/비즈니스';
  String selectedSubJob = '직무';

  List<String> jobs = [
    '경영/비즈니스',
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
    '공공/복지/환경'
  ];

  Map<String, List<String>> subJobs = {
    '경영/비즈니스': [
      '직무',
      '전략/기획',
      '신규사업/사업개발',
      '경영기획',
      '해외사업 기획/개발',
      'CEO',
      '사업제휴',
      '기획조사',
      'CFO',
      '법인 관리',
      'CSO',
      '조직 관리',
      '피플유닛 리더',
      '경영 전략/해외 사업 개발',
      '경영/기획/조직관리/유통/마케팅',
      'HR'
    ],
    '서비스기획': [
      '직무',
      'PM',
      '서비스 기획',
      'PO',
      '운영 전략/기획',
      '서비스 운영',
      'CPO',
      '애자일 코치',
      'Product Manager',
      '상품기획',
      '콘텐츠 기획',
      '플랫폼 기획',
      'Product Designer',
      '그로스 해킹',
      'UX consulting'
    ],
    '개발': [
      '직무',
      '백엔드 개발',
      '프론트엔드 개발',
      '안드로이드 개발',
      '소프트웨어 개발',
      '풀스택 개발',
      'iOS 개발',
      '클라우드',
      'QA',
      'DevOps',
      '네트워크',
      '웹 개발',
      '정보보안',
      'CTO',
      '리서치 엔지니어',
      '하드웨어 개발',
      '임베디드 개발',
      'ERP/DBA'
    ],
    '데이터/AI/ML': [
      '직무',
      '데이터 분석',
      'AI/ML',
      '데이터 사이언스',
      '데이터 엔지니어',
      '빅데이터 분석',
      'MLOps 엔지니어',
      '데이터/플랫폼 아키텍트',
      '태블로 대시보드 개발자',
      'DevRel',
      '마케팅 데이터 및 통계 분석',
      'DataScientist',
      '데이터 파이프라인',
      'Linguist'
    ],
    '마케팅/광고/홍보': [
      '직무',
      '브랜드 마케팅',
      '디지털 마케팅',
      '퍼포먼스 마케팅',
      '콘텐츠 마케팅',
      '광고/AE',
      'PR',
      '글로벌 마케팅',
      '프로모션 마케팅',
      '제품/솔루션 마케팅',
      '카피라이터',
      'CRM',
      '그로스 마케팅',
      'CMO'
    ],
    '디자인': [
      '직무',
      '프로덕트 디자인',
      'UX/UI 디자인',
      '그래픽 디자인',
      '제품 디자인',
      '인테리어 디자인',
      'GUI디자인',
      'BI/BX 디자인',
      '패키지 디자인',
      '영상/모션 디자인',
      '패션 디자인',
      '건축/공간 디자인',
      'UX 분석가',
      '아트디렉터',
      '일러스트레이터',
      '콘텐츠 디자인',
      'UX 리서치'
    ],
    '미디어/커뮤니케이션': [
      '직무',
      'PD',
      '콘텐츠 유통',
      '저널리스트',
      '에디터',
      '전시기획/운영',
      '기자/아나운서',
      '연출',
      '영상편집',
      '해외세일즈',
      '촬영/제작',
      '콘텐츠 사업',
      '콘텐츠 기획/제작',
      '영화/배급',
      '전시기획 및 관리',
      '아티스트 마케팅'
    ],
    '이커머스/리테일': [
      '직무',
      'MD',
      '이커머스',
      '온라인 MD',
      '패션 MD',
      '라이브커머스',
      '식품 MD',
      '리테일',
      '상품 전략',
      '유통 전략',
      '기획 MD',
      '바잉 MD',
      '라이브 MD'
    ],
    '금융/컨설팅/VC': [
      '직무',
      '전략컨설턴트',
      '투자심사/VC',
      '기업금융/여수신',
      'IB',
      '펀드매니저',
      'M&A',
      '대체투자',
      '부동산 금융',
      '애널리스트',
      '사모펀드',
      '계리사',
      '언더라이터',
      '트레이딩/퀀트',
      'Crypto/NFT',
      'IT 컨설턴트',
      '부동산 개발',
      '부실채권 인수',
      '상품전략',
      '오퍼레이션 컨설턴트'
    ],
    '회계/재무': [
      '직무',
      '재무',
      '회계',
      'KICPA 공인회계사',
      'AICPA 미국회계사',
      '감사',
      '세무',
      '예산/결산',
      '경영기획팀',
      '펀드매니저',
      'IR',
      '원가/회계/재무'
    ],
    '인사/채용/노무': [
      '직무',
      '인사',
      '채용',
      '인재개발/교육',
      '테크 리크루터',
      '조직문화',
      '경영지원/총무',
      'HR 컨설턴트',
      '노무사',
      '헤드헌터',
      '피플매니저',
      '인사/총무',
      'PeopleOps&Culture',
      'HR 리드',
      'HRM&HRD'
    ],
    '고객/영업': [
      '직무',
      '해외영업',
      'B2B 영업',
      '영업 관리',
      '기술 영업',
      '솔루션 컨설턴트',
      '영업 기획',
      '파트너십',
      'CX',
      'CSM',
      '제약 영업',
      '금융 영업',
      '의료기기 영업',
      'CS',
      '승무원'
    ],
    '게임 기획/개발': [
      '직무',
      '게임 기획',
      '게임 PM',
      '게임 개발',
      '게임 아티스트',
      '테크니컬 아티스트',
      '게임 운영',
      '게임그래픽 디자이너',
      '게임 툴 디자이너',
      '유저 리서치'
    ],
    '물류/구매': [
      '직무',
      'SCM',
      '구매/자재',
      'Logistics',
      'Trade Compliance',
      '무역 사무',
      'SCM',
      '구매 소싱 기획',
      '구매/물류/통관',
      '관세사',
      '항공/운송'
    ],
    '의료/제약/바이오': [
      '직무',
      '임상',
      '간호사',
      'MSL',
      '약사',
      '정제',
      '인허가 담당',
      '의료행정/사무',
      '질병역학 박사',
      '수의사',
      '연구',
      '물리치료사'
    ],
    '연구/R&D': [
      '직무',
      '기계/자동차',
      '반도체',
      '전기/전자',
      '생명공학',
      '제조/공정',
      '의료/제약',
      '항공/우주',
      '경영/경제',
      '로봇/자동화',
      '화학/섬유',
      '신소재개발',
      '식품',
      '환경',
      '신사업기획',
      '네트워크 보안',
      '배터리/전기자동차',
      '화장품 연구',
      '유기재료개발',
      '원자력/에너지'
    ],
    '엔지니어링/설계': [
      '직무',
      '반도체',
      '기계',
      '건축/토목',
      'IT/통신',
      '자동차/배터리',
      '전기',
      '화학',
      '에너지',
      '디스플레이',
      '공무',
      '항공정비',
      '전기' '가스 에너지',
      '시스템 감사',
      'IT/클라우드' '기술번역'
    ],
    '생산/품질': [
      '직무',
      'QA/QC',
      '생산 관리',
      '생산 기술 개발',
      '공정 관리',
      '생산',
      '인증 규격',
      '신제품 스케일업',
      '생산기술',
      '품질'
    ],
    '교육': ['직무', '교육 기획', '교직원', '교수', '교육 콘텐츠 기획', '강사'],
    '법률/특허': ['직무', '변호사', '법률 사무', '변리사', '로펌 비서', 'Contracts Manger'],
    '공공/복지/환경': [
      '직무',
      '행정/공직',
      '국제기구/협력',
      '사회복지',
      'NGO/시민단체',
      '소방/안전',
      '공기업 기술직',
      '사회공헌/ESG',
      '국제교류',
      '정부사업'
    ]
  };

  @override
  void dispose() {
    nicknameController.dispose(); // dispose 메서드에서 컨트롤러 해제
    homeAddressController.dispose();
    workAddressController.dispose();
    phoneController.dispose();
    ageController.dispose();
    fieldController.dispose();
    roleController.dispose();
    tenureController.dispose();
    companyController.dispose();
    profileController.dispose();
    super.dispose();
  }

  Future<void> _setFirstStartFalse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstStart', false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '회원 프로필',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '자신의 정보를 정확하게 작성해 주세요',
                              style: TextStyle(
                                color: Color(0xFF8A8BB1),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                SizedBox(height: 32),
                Container(
                  height: 40.0, // 높이를 40으로 설정
                  child: TextField(
                    controller: nicknameController,
                    decoration: InputDecoration(
                      hintText: '닉네임',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFBFC0C7)), // 테두리 색상
                        borderRadius: BorderRadius.circular(10), // 테두리 둥근 모서리
                      ),
                      filled: true,
                      fillColor: Color(0xFFFAFBFD), // 배경 색상
                    ),
                  ),
                ),
                SizedBox(height: 13),
                Container(
                  height: 40.0, // 높이를 40으로 설정
                  child: TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: '핸드폰 번호',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFBFC0C7)), // 테두리 색상
                        borderRadius: BorderRadius.circular(10), // 테두리 둥근 모서리
                      ),
                      filled: true,
                      fillColor: Color(0xFFFAFBFD), // 배경 색상
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                SizedBox(height: 13),
                Container(
                  height: 40.0, // 높이를 40으로 설정
                  child: TextField(
                    controller: ageController,
                    decoration: InputDecoration(
                      hintText: '나이',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFBFC0C7)), // 테두리 색상
                        borderRadius: BorderRadius.circular(10), // 테두리 둥근 모서리
                      ),
                      filled: true,
                      fillColor: Color(0xFFFAFBFD), // 배경 색상
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(height: 13),
                Container(
                  height: 40.0,
                  child: DropdownButtonFormField<String>(
                    value: selectedJob,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedJob = newValue!;
                        selectedSubJob = '직무';
                        fieldController.text =
                            newValue; // 선택한 값을 fieldController에 저장
                      });
                    },
                    items: jobs.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Container(
                          child: Text(value),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.5,
                          ),
                        ),
                      );
                    }).toList(),
                    isExpanded: true,
                    iconSize: 24,
                    iconEnabledColor: Color(0xFFBFC0C7),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFBFC0C7)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      filled: true,
                      fillColor: Color(0xFFFAFBFD),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 40.0,
                  child: TextField(
                    controller: roleController,
                    decoration: InputDecoration(
                      hintText: '직무',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFBFC0C7)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Color(0xFFFAFBFD),
                      suffixIcon: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          value: selectedSubJob,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSubJob = newValue!;
                              roleController.text = newValue;
                            });
                          },
                          items: subJobs[selectedJob]!.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          isExpanded: true,
                          iconSize: 24,
                          iconEnabledColor: Color(0xFFBFC0C7),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 10.0), // 선택된 텍스트 내부 여백
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 13),
                Container(
                  height: 40.0, // 높이를 40으로 설정
                  child: TextField(
                    controller: tenureController,
                    decoration: InputDecoration(
                      hintText: '연차',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFBFC0C7)), // 테두리 색상
                        borderRadius: BorderRadius.circular(10), // 테두리 둥근 모서리
                      ),
                      filled: true,
                      fillColor: Color(0xFFFAFBFD), // 배경 색상
                    ),
                  ),
                ),
                SizedBox(height: 13),
                Container(
                  height: 40.0, // 높이를 40으로 설정
                  child: TextField(
                    controller: companyController,
                    decoration: InputDecoration(
                      hintText: '재직중인 회사',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFBFC0C7)), // 테두리 색상
                        borderRadius: BorderRadius.circular(10), // 테두리 둥근 모서리
                      ),
                      filled: true,
                      fillColor: Color(0xFFFAFBFD), // 배경 색상
                    ),
                  ),
                ),
                // SizedBox(height: 13),
                // Container(
                //   height: 40.0, // 높이를 40으로 설정
                //   child: TextField(
                //     controller: homeAddressController,
                //     decoration: InputDecoration(
                //       hintText: '집 주소',
                //       contentPadding: EdgeInsets.symmetric(
                //           vertical: 10.0, horizontal: 10.0),
                //       border: OutlineInputBorder(
                //         borderSide:
                //             BorderSide(color: Color(0xFFBFC0C7)), // 테두리 색상
                //         borderRadius: BorderRadius.circular(10), // 테두리 둥근 모서리
                //       ),
                //       filled: true,
                //       fillColor: Color(0xFFFAFBFD), // 배경 색상
                //     ),
                //   ),
                // ),
                // SizedBox(height: 13),
                // Container(
                //   height: 40.0, // 높이를 40으로 설정
                //   child: TextField(
                //     controller: workAddressController,
                //     decoration: InputDecoration(
                //       hintText: '회사 주소',
                //       contentPadding: EdgeInsets.symmetric(
                //           vertical: 10.0, horizontal: 10.0),
                //       border: OutlineInputBorder(
                //         borderSide:
                //             BorderSide(color: Color(0xFFBFC0C7)), // 테두리 색상
                //         borderRadius: BorderRadius.circular(10), // 테두리 둥근 모서리
                //       ),
                //       filled: true,
                //       fillColor: Color(0xFFFAFBFD), // 배경 색상
                //     ),
                //   ),
                // ),
                SizedBox(height: 13),
                Container(
                  height: 100.0, // 10줄짜리 텍스트를 위한 대략적인 높이
                  child: TextFormField(
                    controller: profileController,
                    maxLines: 10, // 최대 10줄까지 표시
                    keyboardType:
                        TextInputType.multiline, // 여러 줄 입력을 위한 키보드 타입 설정
                    decoration: InputDecoration(
                      hintText: '프로필 상세 정보', // 힌트 텍스트 설정
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFBFC0C7)), // 테두리 색상
                        borderRadius: BorderRadius.circular(10), // 테두리 둥근 모서리
                      ),
                      filled: true,
                      fillColor: Color(0xFFFAFBFD), // 배경 색상
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF615CEC), // 버튼 배경색 설정
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // 버튼 모서리 둥글게 설정
              ),
              minimumSize: Size(double.infinity, 49), // 버튼의 최소 크기 설정
            ),
            // onPressed: () {
            //   updateUserData();
            //   Navigator.of(context).push(
            //     MaterialPageRoute(
            //       builder: (context) => SecondPage(userData: userData),
            //     ),
            //   );
            // },
            onPressed: () {
              updateUserData();
              if (nicknameController.text.isEmpty ||
                  phoneController.text.isEmpty ||
                  ageController.text.isEmpty ||
                  fieldController.text.isEmpty ||
                  roleController.text.isEmpty ||
                  tenureController.text.isEmpty ||
                  companyController.text.isEmpty ||
                  profileController.text.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("경고"),
                      content: Text("모든 정보를 입력해주세요."),
                      actions: <Widget>[
                        TextButton(
                          child: Text('확인'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 대화 상자 닫기
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SecondPage(userData: userData),
                  ),
                );
              }
            },
            child: Text(
              "다음",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // 글자색 설정
              ),
            ),
          ),
        ),
      ],
    );
  }

  void updateUserData() {
    userData.nickname = nicknameController.text;
    userData.homeAddress = homeAddressController.text;
    userData.workAddress = workAddressController.text;
    userData.phone = phoneController.text;
    userData.age = ageController.text;
    userData.field = fieldController.text;
    userData.role = roleController.text;
    userData.tenure = tenureController.text;
    userData.company = companyController.text;
    userData.profile = profileController.text;
  }
}

class SecondPage extends StatefulWidget {
  final UserData userData;

  SecondPage({required this.userData});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final List<String> options = [
    "대화를 잘 이끌어주는 사람",
    "따뜻한 위로가 되는 사람",
    "논리적으로 팩트를 제시하는 사람",
    "친절하게 설명을 잘 해주는 사람",
    "전문성이 느껴지는 사람"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFBFD),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '희망하는 파트너 성향',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '자신의 정보를 정확하게 작성해 주세요',
                                  style: TextStyle(
                                    color: Color(0xFF8A8BB1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                    SizedBox(height: 32),
                    ...options
                        .map((option) => ListTile(
                              title: Text(option),
                              onTap: () {
                                setState(() {
                                  if (widget.userData.personalities
                                      .contains(option)) {
                                    widget.userData.personalities
                                        .remove(option);
                                  } else if (widget
                                          .userData.personalities.length <
                                      3) {
                                    widget.userData.personalities.add(option);
                                  }
                                  // 3개 이상 선택 방지
                                });
                              },
                              leading: Icon(
                                Icons.favorite,
                                color: widget.userData.personalities
                                        .contains(option)
                                    ? Colors.green
                                    : Colors.grey, // 선택 시 초록색, 아닐 시 회색
                              ),
                              // leading: Icon(
                              //   Icons.check_circle,
                              //   color: widget.userData.personalities
                              //           .contains(option)
                              //       ? Colors.green
                              //       : Colors.grey, // 선택 시 초록색, 아닐 시 회색
                              // ),
                              // trailing:
                              //     widget.userData.personalities.contains(option)
                              //         ? Icon(Icons.check, color: Colors.blue)
                              //         : null,
                            ))
                        .toList(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: widget.userData.personalities.isEmpty
                      ? Color(0xFFB9BBE9) // 선택이 없을 때 색상
                      : Color(0xFF615CEC), // 선택이 있을 때 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  minimumSize: Size(double.infinity, 49),
                ),
                onPressed: widget.userData.personalities.isNotEmpty
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ThirdPage(userData: widget.userData),
                          ),
                        );
                      }
                    : null, // 버튼 비활성화
                child: Text(
                  "다음",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdPage extends StatefulWidget {
  final UserData userData;

  ThirdPage({required this.userData});

  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  final List<String> options = [
    "이직 준비",
    "커리어 방향 설정",
    "업계 동향 파악",
    "창업 및 투자 조언",
    "해외 커리어 탐색",
    "공고 문의"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFBFD),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '희망하는 파트너 성향',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '자신의 정보를 정확하게 작성해 주세요',
                                  style: TextStyle(
                                    color: Color(0xFF8A8BB1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                    SizedBox(height: 32),
                    ...options
                        .map((option) => ListTile(
                              title: Text(option),
                              onTap: () {
                                setState(() {
                                  if (widget.userData.interests
                                      .contains(option)) {
                                    widget.userData.interests.remove(option);
                                  } else if (widget.userData.interests.length <
                                      3) {
                                    widget.userData.interests.add(option);
                                  }
                                  // 3개 이상 선택 방지
                                });
                              },
                              leading: Icon(
                                Icons.favorite,
                                color:
                                    widget.userData.interests.contains(option)
                                        ? Colors.green
                                        : Colors.grey, // 선택 시 초록색, 아닐 시 회색
                              ),
                              // leading: Icon(
                              //   Icons.check_circle,
                              //   color: widget.userData.personalities
                              //           .contains(option)
                              //       ? Colors.green
                              //       : Colors.grey, // 선택 시 초록색, 아닐 시 회색
                              // ),
                              // trailing:
                              //     widget.userData.personalities.contains(option)
                              //         ? Icon(Icons.check, color: Colors.blue)
                              //         : null,
                            ))
                        .toList(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: widget.userData.interests.isEmpty
                      ? Color(0xFFB9BBE9) // 선택이 없을 때 색상
                      : Color(0xFF615CEC), // 선택이 있을 때 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  minimumSize: Size(double.infinity, 49),
                ),
                // onPressed: widget.userData.interests.isNotEmpty
                //     ? () {
                //         widget.userData.showResults(context);
                //       }
                //     : null, // 버튼 비활성화
                onPressed: widget.userData.interests.isNotEmpty
                    ? () {
                        widget.userData.sendData(context); // 서버에 데이터 전송 및 응답 처리
                      }
                    : null, // 버튼 비활성화

                child: Text(
                  "완료",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
