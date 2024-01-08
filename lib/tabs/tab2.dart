import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'tab2_addition/AddCity.dart';
import 'tab2_addition/AddHotel.dart';
import 'package:intl/intl.dart';
import '../functional.dart';
import 'package:path_provider/path_provider.dart';

class TravelPlan {
  String city;
  String startDate;
  String endDate;
  String imageUrl;

  TravelPlan({
    required this.city,
    required this.startDate,
    required this.endDate,
    this.imageUrl = "https://image1.lottetour.com/static/trvtour/201910/1715/011ee82200cbf4f301c382e19f44b28e",
  });
}

class Tab2 extends StatefulWidget {
  // final int intValue; // 추가할 int 변수
  //
  // // 생성자를 통해 intValue를 받아옵니다.
  // Tab2({Key? key, required this.intValue}) : super(key: key);

  @override
  Tab2State createState() => Tab2State();
}

class Tab2State extends State<Tab2> {
  DateTime? startDate;
  DateTime? endDate;
  List<TravelPlan> travelPlans = []; // 여행 계획을 저장할 리스트
  String tempCity = ''; // 임시로 도시 이름 저장
  String tempStartDate = ''; // 임시로 날짜 시작 저장
  String tempEndDate = ''; // 임시로 날짜 끝 저장
  String? userName;
  String? imagePath;
  int? user_id;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      // 여기에 비동기 작업을 넣습니다.
      await setting();
    });
  }

  Future<void> setting() async {

    // 아바타 사진 다운로드
    user_id = await getUserId();
    String filename = "$user_id.jpg";

    userName = await getUserNickname(user_id);

    await downloadProfilePhoto(filename);

    Directory tempDir = await getApplicationDocumentsDirectory();
    String filePath = '${tempDir.path}/profile_photo/$filename';
    imagePath = filePath;

    setState(() {
    });

  }


  @override
  Widget build(BuildContext context) {
    // int userId = widget.intValue;
    return Scaffold(
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : null,
                  ),
                  SizedBox(width: 8),
                  Text(userName ?? '사용자',
                      style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  width: double.infinity, //Container를 화면 너비만큼 확장
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('새로운 여행 만들기', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final selectedCity = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AddCity()),
                              );
                              if (selectedCity != null) {
                                setState(() {
                                  tempCity = selectedCity; // 선택된 도시 이름으로 tempCity 업데이트
                                });
                                // tempStartDate와 tempEndDate가 비어있으면 날짜 선택 다이얼로그 표시
                                if (tempStartDate.isEmpty && tempEndDate.isEmpty) {
                                  _showAddDateDialog(context);
                                }
                              }
                            },
                            child: Text(getCityButtonText(), style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // 버튼 배경색
                              foregroundColor: Colors.black, // 버튼 텍스트 및 아이콘 색상
                              side: BorderSide(color: Colors.grey), // 테두리 색상
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), // 버튼 모서리 둥글게
                              ),
                              padding: EdgeInsets.all(8.0), // 패딩
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              await _showAddDateDialog(context);
                              // tempCity가 비어있으면 AddCity 페이지로 이동
                              if (tempCity.isEmpty) {
                                final selectedCity = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddCity()),
                                );
                                if (selectedCity != null) {
                                  setState(() {
                                    tempCity = selectedCity;
                                  });
                                }
                              }
                            },
                            child: Text(getDateButtonText(), style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // 버튼 배경색
                              foregroundColor: Colors.black, // 버튼 텍스트 및 아이콘 색상
                              side: BorderSide(color: Colors.grey), // 테두리 색상
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0), // 버튼 모서리 둥글게
                              ),
                              padding: EdgeInsets.all(8.0), // 패딩
                            ),
                          ),
                        ], // Children
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: tempCity.isNotEmpty && tempStartDate.isNotEmpty && tempEndDate.isNotEmpty
                            ? () {
                          // 새로운 TravelPlan 객체 생성
                          TravelPlan newPlan = TravelPlan(
                            city: tempCity,
                            startDate: tempStartDate,
                            endDate: tempEndDate,
                            // dateRange: "$tempStartDate~$tempEndDate",
                            // imageUrl: imageUrl, // 예시 URL
                          );
                          // travelPlans 리스트에 추가
                          setState(() {
                            travelPlans.add(newPlan);
                          });

                          // AddHotel 페이지로 이동하기 전에 tempCity 값을 저장
                          String currentCity = tempCity;
                          String currentStartDate = tempStartDate;
                          String currentEndDate = tempEndDate;

                          // tempCity, tempStartDate, tempEndDate 초기화
                          setState(() {
                            tempCity = '';
                            tempStartDate = '';
                            tempEndDate = '';
                          });

                          startDate = DateTime.now();
                          endDate = null;

                          // var post_index = init_post(currentCity, currentStartDate, currentEndDate, 20);
                          // print(post_index);
                          // AddHotel 페이지로 이동하면서 currentCity 값을 전달
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddHotel(city: currentCity, startDate: currentStartDate, endDate: currentEndDate)),
                          );

                          // 버튼 동작을 여기에 작성하세요.
                          // 예: 여행 정보 저장, 다음 페이지로 이동 등

                        }
                            : null, // tempCity, tempStartDate, tempEndDate 중 하나라도 비어있으면 버튼 비활성화
                        child: Text("여행 시작하기", style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // 버튼 배경색
                          foregroundColor: Colors.black, // 버튼 텍스트 및 아이콘 색상
                          side: BorderSide(color: Colors.grey), // 테두리 색상
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // 버튼 모서리 둥글게
                          ),
                          padding: EdgeInsets.all(8.0), // 패딩
                        ),
                      ),
                    ],
                  ),
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('계획 중인 여행', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: travelPlans.length, // travelPlans는 여행 계획들의 리스트입니다.
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(travelPlans[index].city), // 도시 이름
                      subtitle: Text("${travelPlans[index].startDate}~${travelPlans[index].endDate}"), // 날짜 범위
                      trailing: Image.network(travelPlans[index].imageUrl), // 이미지 (네트워크 이미지 예시)
                    ),
                  );
                },
              ),
            ),
          ], // Children
      ),
    );
  }

  String getCityButtonText() {
    if (tempCity.isEmpty) {
      return '도시 선택';
    } else {
      return tempCity; // 이미 선택된 도시 이름
    }
  }

  String getDateButtonText() {
    if (tempStartDate.isEmpty) {
      return '날짜 선택';
    } else {
      return '$tempStartDate~$tempEndDate'; // 이미 선택된 도시 이름
    }
  }

  Future<void> _showAddDateDialog(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime initialDate = DateTime(now.year, now.month, now.day); // 현재 날짜로 초기화

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: initialDate,
      lastDate: DateTime(2050),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null, // 이전에 선택된 날짜가 있으면 사용, 없으면 null
    );
    if (picked != null) {
      // 선택된 날짜 범위 처리
      // 예: 상태 업데이트 또는 다른 함수 호출
      setState(() {
        startDate = DateTime(picked.start.year, picked.start.month, picked.start.day); // 날짜 부분만 저장
        endDate = DateTime(picked.end.year, picked.end.month, picked.end.day); // 날짜 부분만 저장
        tempStartDate = DateFormat('yyyy-MM-dd').format(startDate!);
        tempEndDate = DateFormat('yyyy-MM-dd').format(endDate!);
      });
    }
  }

  String formatDate(DateTime dateTime) {
    // 날짜를 문자열로 포맷하는 함수
    // DateFormat 클래스를 사용하려면 'intl' 패키지가 필요합니다.
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

// void _showAddDateDialog() {
  //   TextEditingController dateController = TextEditingController();
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return AlertDialog(
  //             title: Text('날짜 선택'),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: <Widget>[
  //                 TextField(
  //                   controller: dateController,
  //                   decoration: const InputDecoration(
  //                     labelText: '날짜 선택',
  //                   ),
  //                   onChanged: (value) {
  //                     setState(() {});
  //                   },
  //                 ),
  //               ],
  //             ),
  //             actions: <Widget>[
  //               TextButton(
  //                 child: Text('취소'),
  //                 onPressed: () {
  //                   Navigator.of(context).pop(); // 다이얼로그 닫기
  //                 },
  //               ),
  //               TextButton(
  //                 child: Text('추가'),
  //                 onPressed: dateController.text.isNotEmpty ? () {
  //                   Navigator.of(context).pop(dateController.text); // 추가 시 선택된 날짜 전달
  //                 } : null,
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   ).then((selectedDate) {
  //     if (selectedDate != null) {
  //       setState(() {
  //         tempDate = selectedDate; // 선택된 날짜로 tempDate 업데이트
  //       });
  //     }
  //   });
  // }
}

