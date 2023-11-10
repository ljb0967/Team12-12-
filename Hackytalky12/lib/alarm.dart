import 'package:flutter/material.dart';

class alarmPage extends StatefulWidget {
  @override
  _alarmPageState createState() => _alarmPageState();
}

class UserData {
  Set<String> personalities = {};

  void addPersonality(String personality) {
    if (personalities.length < 3) {
      personalities.add(personality);
    }
  }

  void removePersonality(String personality) {
    personalities.remove(personality);
  }
}

class _alarmPageState extends State<alarmPage> {
  List<bool> isHeartPressed = List.generate(5, (index) => false);
  int selectedIndex = 0; // 현재 선택된 인덱스
  UserData userData = UserData();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 선택지를 가로로 나열
            Container(
              margin: EdgeInsets.fromLTRB(10, 20, 0, 0),
              child: Text(
                '알림 메시지',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(
                '알림 현황을 확인해 주세요',
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: CustomToggleSwitch(
                height: 30,
                borderRadius: 15,
                backgroundColor: Color(0xFFB9BBE9),
                options: ['교류 현황', '받은 요청', '보낸 요청'],
                toggleValue: selectedIndex,
                onChanged: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            // 선택된 선택지에 따라 다른 리스트뷰 표시
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: [
                  buildListView('교류 현황'),
                  buildListView('받은 요청'),
                  buildListView('보낸 요청'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 선택지 버튼 생성
  Widget buildChoiceButton(int index, String text) {
    return Expanded(
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Text(text),
      ),
    );
  }

  // 리스트뷰 생성
  Widget buildListView(String text) {
    return ListView.builder(
      itemCount: items.length, // 데이터 리스트의 아이템 개수
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: Container(
            width: 44,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR5TulwreiAilalNuCPYfWqf1uaFawcRHBSgekfTY-WMC3hCz449Gq3Tnnl08SikllFBXE&usqp=CAU'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$text 타이틀', // 타이틀
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '서브 타이틀', // 서브 타이틀
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8A8BB1),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Color(0xFFFFD600), // 배경색
                  borderRadius: BorderRadius.circular(8), // 모서리 둥글기
                ),
                child: Text(
                  '멘토', // 멘토 혹은 멘티
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          // trailing: text == "교류 현황"
          //     ? ElevatedButton(
          //         onPressed: () {
          //           showReviewPopup(context, '$text 아이템 $index');
          //         },
          //         child: Text('리뷰 작성'),
          //       )
          //     : null,
          trailing: text == "교류 현황"
              ? ElevatedButton(
                  onPressed: () {
                    showReviewPopup(context, '$text 아이템 $index');
                  },
                  child: Text('리뷰 작성'),
                )
              : text == "받은 요청"
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // 수락 버튼 동작
                          },
                          child: Text('수락'),
                        ),
                        SizedBox(width: 8), // 버튼 사이 간격
                        ElevatedButton(
                          onPressed: () {
                            // 거절 버튼 동작
                          },
                          child: Text('거절'),
                        ),
                      ],
                    )
                  : null, // 다른 카테고리일 경우 표시하지 않음
        );
      },
    );
  }

  void showReviewPopup(BuildContext context, String item) {
    final List<String> options = [
      "대화를 잘 이끌어주는 사람",
      "따뜻한 위로가 되는 사람",
      "논리적으로 팩트를 제시하는 사람",
      "친절하게 설명을 잘 해주는 사람",
      "전문성이 느껴지는 사람"
    ];

    int selectedRatingIndex = 0; // 기본적으로 "매우 좋아요" 선택
    final List<String> ratings = ["매우 좋아요", "좋아요", "보통", "아쉬워요"];

    TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "리뷰 작성",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: 10),
                    Divider(color: Color(0xFFE1E1E1)),
                    ...options
                        .map((option) => Container(
                              height: 50, // 높이 설정
                              margin: EdgeInsets.only(bottom: 5), // 아래쪽 마진 설정
                              decoration: BoxDecoration(
                                color: userData.personalities.contains(option)
                                    ? Colors.green // 선택된 경우 초록색 배경
                                    : Colors.transparent, // 기본 배경
                                border: Border.all(
                                  color: userData.personalities.contains(option)
                                      ? Colors.green // 선택된 경우 초록색
                                      : Color(0xFF8A8BB1), // 기본 색상
                                  width: 1, // 보더 두께
                                ),
                                borderRadius:
                                    BorderRadius.circular(5), // 모서리 둥글기
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (userData.personalities
                                        .contains(option)) {
                                      userData.personalities.remove(option);
                                    } else if (userData.personalities.length <
                                        3) {
                                      userData.personalities.add(option);
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        color: userData.personalities
                                                .contains(option)
                                            ? Colors.white // 선택된 경우 아이콘 초록색
                                            : Colors.grey, // 기본 색상
                                      ),
                                      SizedBox(width: 10), // 아이콘과 텍스트 사이 간격
                                      Text(
                                        option,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, // 볼드체
                                          fontSize: 14, // 폰트 크기 14포인트
                                          color: userData.personalities
                                                  .contains(option)
                                              ? Colors.white // 선택된 경우 흰색 텍스트
                                              : Colors.black, // 기본 텍스트 색상
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(ratings.length, (index) {
                        // 이모티콘과 텍스트를 위한 데이터
                        final List<String> emojis = ["😃", "🙂", "😐", "🙁"];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRatingIndex = index;
                            });
                          },
                          child: Container(
                            height: 50, // 버튼의 높이
                            width: MediaQuery.of(context).size.width /
                                    ratings.length -
                                40, // 너비는 동일하게 분할
                            decoration: BoxDecoration(
                              color: selectedRatingIndex == index
                                  ? Colors.blue
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  emojis[index], // 이모티콘
                                  style: TextStyle(fontSize: 24),
                                ),
                                Text(
                                  ratings[index], // 텍스트
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF5521EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: Size(120, 40),
                          ),
                          child: Text('등록'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFFAFBFD),
                            side: BorderSide(color: Color(0xFF5521EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: Size(120, 40),
                          ),
                          child: Text(
                            '닫기',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF5521EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showDetailPopup(BuildContext context, String item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('상세 정보'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('선택된 아이템: $item'),
              // 여기에 추가적인 상세 정보 표시를 원하는 대로 구현할 수 있습니다.
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 팝업을 닫기
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  Widget buildReviewCategoryItem(String category, int index) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              isHeartPressed[index] = !isHeartPressed[index];
            });
          },
          child: Icon(
            isHeartPressed[index] ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 8.0),
        Text(category),
      ],
    );
  }
}

Widget buildButton(String text, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    child: Text(text),
  );
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
        color: backgroundColor,
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
                  color: isSelected ? Color(0xFF615CEC) : Colors.transparent,
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
