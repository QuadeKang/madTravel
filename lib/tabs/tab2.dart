import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'tab2_addition/AddCity.dart';
import 'tab2_addition/AddHotel.dart';
import 'package:intl/intl.dart';

class TravelPlan {
  String city;
  String dateRange;
  String imageUrl;

  TravelPlan({
    required this.city,
    required this.dateRange,
    required this.imageUrl,
  });
}

class Tab2 extends StatefulWidget {
  @override
  Tab2State createState() => Tab2State();
}

class Tab2State extends State<Tab2> {
  List<TravelPlan> travelPlans = []; // 여행 계획을 저장할 리스트
  String tempCity = ''; // 임시로 도시 이름 저장
  String tempStartDate = ''; // 임시로 날짜 시작 저장
  String tempEndDate = ''; // 임시로 날짜 끝 저장

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black, // 검은 동그라미
                    radius: 20,
                  ),
                  SizedBox(width: 8),
                  Text('강정환 님', style: TextStyle(fontSize: 20)),
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
                            onPressed: () => _showAddDateDialog(context), // 익명 함수를 사용하여 현재 컨텍스트 전달
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
                        onPressed: tempCity.isNotEmpty && tempStartDate.isNotEmpty
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddHotel()),
                          );
                          // 버튼 동작을 여기에 작성하세요.
                          // 예: 여행 정보 저장, 다음 페이지로 이동 등

                        }
                            : null, // tempCity와 tempStartDate 중 하나라도 비어있으면 버튼 비활성화
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
                      subtitle: Text(travelPlans[index].dateRange), // 날짜 범위
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

  void _showAddCityDialog() {
    //버튼 누르면 새로운 창으로
  }


  Future<void> _showAddDateDialog(BuildContext context) async {
    DateTime? startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );

    if (startDate == null) return; // 사용자가 날짜를 선택하지 않으면 함수를 종료합니다.

    DateTime? endDate = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: startDate,
      lastDate: DateTime(2025),
    );

    if (endDate != null) {
      // 여기에서 선택된 시작 날짜와 종료 날짜를 처리합니다.
      // 예: 상태 업데이트 또는 다른 함수 호출
      setState(() {
        tempStartDate = formatDate(startDate); // tempStartDate 업데이트
        tempEndDate = formatDate(endDate); // tempEndDate 업데이트
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

