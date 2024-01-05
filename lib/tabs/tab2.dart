import 'package:flutter/material.dart';

class Tab2 extends StatefulWidget {
  @override
  Tab2State createState() => Tab2State();
}

class Tab2State extends State<Tab2> {
  List<TravelPlan> travelPlans = []; // 여행 계획을 저장할 리스트
  String tempCity = ''; // 임시로 도시 이름 저장
  String tempDate = ''; // 임시로 날짜 범위 저장

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
                            onPressed: _showAddCityDialog,
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
                            onPressed: _showAddDateDialog,
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
                    ],
                  ),
                ),
            ),
          ], // Children

            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Text('계획 중인 여행', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            // ),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: travelPlans.length,
            //     itemBuilder: (context, index) {
            //       return Card(
            //         margin: EdgeInsets.all(8.0),
            //         child: ListTile(
            //           title: Text(travelPlans[index].city),
            //           subtitle: Text(travelPlans[index].dateRange),
            //           trailing: Image.asset(travelPlans[index].imageUrl), // 이미지 표시
            //         ),
            //       );
            //     },
            //   ),
            // ),
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
    if (tempDate.isEmpty) {
      return '날짜 선택';
    } else {
      return tempDate; // 이미 선택된 도시 이름
    }
  }

  void _showAddCityDialog() {
    TextEditingController cityController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('새로운 여행 만들기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: getCityButtonText(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: Text('추가'),
              onPressed: cityController.text.isNotEmpty
                  ? () {
                if (tempDate.isEmpty) {
                  // 날짜가 입력되지 않았을 경우 _showAddDateDialog 호출
                  Navigator.of(context).pop(); // 현재 다이얼로그 닫기
                  _showAddDateDialog(); // 날짜 선택 다이얼로그 표시
                } else {
                  // 도시와 날짜 모두 입력된 경우 여행 계획 추가
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                }
              }
                  : null, // 도시 이름이 비어있으면 버튼 비활성화
            ),
          ],
        );
      },
    );
  }

  void _showAddDateDialog() {
    TextEditingController dateController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('새로운 여행 만들기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: getDateButtonText(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: Text('추가'),
              onPressed: dateController.text.isNotEmpty
                  ? () {
                if (tempCity.isEmpty) {
                  // 날짜가 입력되지 않았을 경우 _showAddDateDialog 호출
                  Navigator.of(context).pop(); // 현재 다이얼로그 닫기
                  _showAddCityDialog(); // 도시 선택 다이얼로그 표시
                } else {
                  // 도시와 날짜 모두 입력된 경우 여행 계획 추가
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                }
              }
                  : null, // 도시 이름이 비어있으면 버튼 비활성화
            ),
          ],
        );
      },
    );
  }
}

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
