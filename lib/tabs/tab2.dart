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
    this.imageUrl =
        "https://image1.lottetour.com/static/trvtour/201910/1715/011ee82200cbf4f301c382e19f44b28e",
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

    setState(() {});
  }

  // @override
  // Widget build(BuildContext context) {
  //   // int userId = widget.intValue;
  //   return Scaffold(
  //     body: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Row(
  //               children: [
  //                 CircleAvatar(
  //                   radius: 20,
  //                   backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : null,
  //                 ),
  //                 SizedBox(width: 8),
  //                 Text(userName ?? '사용자',
  //                     style: TextStyle(fontSize: 20)),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(16.0),
  //               child: Container(
  //                 padding: EdgeInsets.all(16.0),
  //                 width: double.infinity, //Container를 화면 너비만큼 확장
  //                 decoration: BoxDecoration(
  //                   border: Border.all(color: Colors.grey),
  //                   borderRadius: BorderRadius.circular(8.0),
  //                 ),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text('새로운 여행 만들기', style: TextStyle(fontSize: 18)),
  //                     SizedBox(height: 8),
  //                     Row(
  //                       children: [
  //                         ElevatedButton(
  //                           onPressed: () async {
  //                             final selectedCity = await Navigator.push(
  //                               context,
  //                               MaterialPageRoute(builder: (context) => AddCity()),
  //                             );
  //                             if (selectedCity != null) {
  //                               setState(() {
  //                                 tempCity = selectedCity; // 선택된 도시 이름으로 tempCity 업데이트
  //                               });
  //                               // tempStartDate와 tempEndDate가 비어있으면 날짜 선택 다이얼로그 표시
  //                               if (tempStartDate.isEmpty && tempEndDate.isEmpty) {
  //                                 _showAddDateDialog(context);
  //                               }
  //                             }
  //                           },
  //                           child: Text(getCityButtonText(), style: TextStyle(fontSize: 16)),
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.white, // 버튼 배경색
  //                             foregroundColor: Colors.black, // 버튼 텍스트 및 아이콘 색상
  //                             side: BorderSide(color: Colors.grey), // 테두리 색상
  //                             shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(8.0), // 버튼 모서리 둥글게
  //                             ),
  //                             padding: EdgeInsets.all(8.0), // 패딩
  //                           ),
  //                         ),
  //                         SizedBox(width: 8),
  //                         ElevatedButton(
  //                           onPressed: () async {
  //                             await _showAddDateDialog(context);
  //                             // tempCity가 비어있으면 AddCity 페이지로 이동
  //                             if (tempCity.isEmpty) {
  //                               final selectedCity = await Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(builder: (context) => AddCity()),
  //                               );
  //                               if (selectedCity != null) {
  //                                 setState(() {
  //                                   tempCity = selectedCity;
  //                                 });
  //                               }
  //                             }
  //                           },
  //                           child: Text(getDateButtonText(), style: TextStyle(fontSize: 16)),
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.white, // 버튼 배경색
  //                             foregroundColor: Colors.black, // 버튼 텍스트 및 아이콘 색상
  //                             side: BorderSide(color: Colors.grey), // 테두리 색상
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(8.0), // 버튼 모서리 둥글게
  //                             ),
  //                             padding: EdgeInsets.all(8.0), // 패딩
  //                           ),
  //                         ),
  //                       ], // Children
  //                     ),
  //                     SizedBox(height: 8),
  //                     ElevatedButton(
  //                       onPressed: tempCity.isNotEmpty && tempStartDate.isNotEmpty && tempEndDate.isNotEmpty
  //                           ? () async {
  //                         // 새로운 TravelPlan 객체 생성
  //                         TravelPlan newPlan = TravelPlan(
  //                           city: tempCity,
  //                           startDate: tempStartDate,
  //                           endDate: tempEndDate,
  //                           // dateRange: "$tempStartDate~$tempEndDate",
  //                           // imageUrl: imageUrl, // 예시 URL
  //                         );
  //                         // travelPlans 리스트에 추가
  //                         setState(() {
  //                           travelPlans.add(newPlan);
  //                         });
  //
  //                         // AddHotel 페이지로 이동하기 전에 tempCity 값을 저장
  //                         String currentCity = tempCity;
  //                         String currentStartDate = tempStartDate;
  //                         String currentEndDate = tempEndDate;
  //
  //                         // tempCity, tempStartDate, tempEndDate 초기화
  //                         setState(() {
  //                           tempCity = '';
  //                           tempStartDate = '';
  //                           tempEndDate = '';
  //                         });
  //
  //                         startDate = DateTime.now();
  //                         endDate = null;
  //
  //                         var post_index = await init_post(currentCity, currentStartDate, currentEndDate, 20);
  //                         // AddHotel 페이지로 이동하면서 currentCity 값을 전달
  //                         Navigator.push(
  //                           context,
  //                           MaterialPageRoute(builder: (context) => AddHotel(city: currentCity, startDate: currentStartDate, endDate: currentEndDate, post_index: post_index)),
  //                         );
  //
  //                         // 버튼 동작을 여기에 작성하세요.
  //                         // 예: 여행 정보 저장, 다음 페이지로 이동 등
  //
  //                       }
  //                           : null, // tempCity, tempStartDate, tempEndDate 중 하나라도 비어있으면 버튼 비활성화
  //                       child: Text("여행 시작하기", style: TextStyle(fontSize: 16)),
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.white, // 버튼 배경색
  //                         foregroundColor: Colors.black, // 버튼 텍스트 및 아이콘 색상
  //                         side: BorderSide(color: Colors.grey), // 테두리 색상
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(8.0), // 버튼 모서리 둥글게
  //                         ),
  //                         padding: EdgeInsets.all(8.0), // 패딩
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Text('계획 중인 여행', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
  //           ),
  //           Expanded(
  //             child: ListView.builder(
  //               itemCount: travelPlans.length, // travelPlans는 여행 계획들의 리스트입니다.
  //               itemBuilder: (context, index) {
  //                 return Card(
  //                   margin: EdgeInsets.all(8.0),
  //                   child: ListTile(
  //                     title: Text(travelPlans[index].city), // 도시 이름
  //                     subtitle: Text("${travelPlans[index].startDate}~${travelPlans[index].endDate}"), // 날짜 범위
  //                     trailing: Image.network(travelPlans[index].imageUrl), // 이미지 (네트워크 이미지 예시)
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ], // Children
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFF07923C),
      body: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 사용자 정보, 새로운 여행 만들기 섹션, 도시/날짜 선택 버튼들
          // ...

          Positioned(
            top: 50,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width:28),
                      CircleAvatar(
                        radius: 15,
                        backgroundImage: imagePath != null
                            ? FileImage(File(imagePath!))
                            : null,
                      ),
                      SizedBox(width: 8),
                      Text(userName ?? '사용자',
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(width: 30,),
                      Text('이번 여행은 도쿄 어때요?',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white)),
                      SizedBox(width: 8),],
                  )

                ],
              ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
    );
  }

  Widget _buildCustomBottomNavigationBar() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.75,
      decoration: BoxDecoration(
        color: Colors.white, // White background color
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // 그림자 색상과 투명도
            spreadRadius: 0, // 그림자의 확장 범위
            blurRadius: 4, // 그림자의 흐림 정도
            offset: Offset(0, -4), // 수평 및 수직 오프셋
          ),
        ],
      ),
      // child: ClipRRect(
      //   borderRadius: BorderRadius.only(
      //   topLeft: Radius.circular(30),
      //   topRight: Radius.circular(30),
      //   ),
      //   child: SingleChildScrollView(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 22,
          bottom: 30,
          left: 28,
          right: 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 0,
                bottom: 0,
                left: 5,
                right: 0,
              ),
              child: Text(
                '새로운 여행 만들기',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 0,
                bottom: 10,
                left: 0,
                right: 180,
              ),
              child: Divider(
                color: Colors.black, // 검은색 구분선
                thickness: 2.5, // 선의 두께
                height: 12.0, // 선 위아래의 여백
              ),
            ),
            Text(
              '도시', // 여기에 원하는 텍스트를 입력
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4), // 텍스트와 버튼 사이의 간격을 위한 SizedBox
            // 도시 선택 버튼
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: ImageIcon(
                  AssetImage("assets/icon_selectCity.png"),
                  // AssetImage를 사용하여 아이콘 이미지 지정
                  size: 25.0, // 아이콘 크기 설정
                  color: Colors.black, // 아이콘 색상 설정
                ),
                label: Text(
                  getCityButtonText(),
                  style: getCityButtonTextStyle(),
                ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  // 버튼 배경색
                  foregroundColor: Colors.black,
                  // 버튼 텍스트 및 아이콘 색상
                  side: BorderSide(color: Colors.grey),
                  // 테두리 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0), // 버튼 모서리 둥글게
                  ),
                  padding: EdgeInsets.all(5.0),
                  // 패딩
                  alignment: Alignment.centerLeft, // 버튼 내부의 정렬을 왼쪽으로 설정
                ),
              ),
            ),
            SizedBox(height: 6), // 텍스트와 버튼 사이의 간격을 위한 SizedBox
            Text(
              '날짜', // 여기에 원하는 텍스트를 입력
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4), // 텍스트와 버튼 사이의 간격을 위한 SizedBox
            // 날짜 선택 버튼
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: ImageIcon(
                  AssetImage("assets/icon_selectDate.png"),
                  // AssetImage를 사용하여 아이콘 이미지 지정
                  size: 30.0, // 아이콘 크기 설정
                  color: Colors.black, // 아이콘 색상 설정
                ),
                label: Text(
                  getDateButtonText(),
                  style: getDateButtonTextStyle(),
                ),
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
                        print(tempCity);
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  // 버튼 배경색
                  foregroundColor: Colors.black,
                  // 버튼 텍스트 및 아이콘 색상
                  side: BorderSide(color: Colors.grey),
                  // 테두리 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0), // 버튼 모서리 둥글게
                  ),
                  padding: EdgeInsets.all(5.0),
                  // 패딩
                  alignment: Alignment.centerLeft, // 버튼 내부의 정렬을 왼쪽으로 설정
                ),
              ),
            ),
            SizedBox(height: 12), // 텍스트와 버튼 사이의 간격을 위한 SizedBox
            // 여행 시작하기 버튼
            SizedBox(
              height: 35.0,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: tempCity.isNotEmpty &&
                        tempStartDate.isNotEmpty &&
                        tempEndDate.isNotEmpty
                    ? () async {
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
                        print(tempStartDate);
                        print(tempEndDate);
                        // tempCity, tempStartDate, tempEndDate 초기화
                        setState(() {
                          tempCity = '';
                          tempStartDate = '';
                          tempEndDate = '';
                        });

                        startDate = DateTime.now();

                        endDate = null;

                        var post_index = await init_post(
                            currentCity, currentStartDate, currentEndDate, 20);

                        print(post_index);
                        // AddHotel 페이지로 이동하면서 currentCity 값을 전달
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddHotel(
                                  city: currentCity,
                                  startDate: currentStartDate,
                                  endDate: currentEndDate,
                                  post_index: post_index)),
                        );
                      }
                    : null, // 조건이 만족하지 않으면 버튼 비활성화
                child: Text("여행 시작하기",
                    style:
                        TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF07923C),
                  // 버튼 배경색
                  foregroundColor: Colors.white,
                  // 버튼 텍스트 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3), // 버튼 모서리 둥글기
                  ),
                  padding: EdgeInsets.all(5),
                  // 버튼 내부 패딩
                  elevation: 0, // 버튼 그림자 강도
                  // 기타 스타일 설정
                ),
              ),
            ),
            SizedBox(height: 25), // 텍스트와 버튼 사이의 간격을 위한 SizedBox
            Padding(
              padding: const EdgeInsets.only(
                top: 0,
                bottom: 0,
                left: 5,
                right: 0,
              ),
              child: Text(
                '계획 중인 여행',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 0,
                bottom: 10,
                left: 0,
                right: 180,
              ),
              child: Divider(
                color: Colors.black, // 검은색 구분선
                thickness: 2.5, // 선의 두께
                height: 12.0, // 선 위아래의 여백
              ),
            ),
            // 계획 중인 여행 리스트가 스크롤 가능하도록 Expanded로 감싼 ListView.builder
            ListView.builder(
              itemCount: travelPlans.length,
              // travelPlans는 여행 계획들의 리스트입니다.
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(travelPlans[index].city),
                    // 도시 이름
                    subtitle: Text(
                        "${travelPlans[index].startDate}~${travelPlans[index].endDate}"),
                    // 날짜 범위
                    trailing: Image.network(
                        travelPlans[index].imageUrl), // 이미지 (네트워크 이미지 예시)
                  ),
                );
              },
              shrinkWrap: true, // 스크롤 가능하도록 설정
              // physics: NeverScrollableScrollPhysics() 는 제거합니다.
            ),
          ],
        ),
      ),
    );
  }

  String getCityButtonText() {
    if (tempCity.isEmpty) {
      return '도시를 선택해주세요';
    } else {
      return tempCity; // 이미 선택된 도시 이름
    }
  }

  TextStyle getCityButtonTextStyle() {
    if (tempCity.isEmpty) {
      return TextStyle(fontSize: 18, color: Colors.grey);
    } else {
      return TextStyle(fontSize: 18, color: Colors.black);
    }
  }

  String getDateButtonText() {
    if (tempStartDate.isEmpty) {
      return '날짜를 선택해주세요';
    } else {
      return '$tempStartDate~$tempEndDate'; // 이미 선택된 도시 이름
    }
  }

  TextStyle getDateButtonTextStyle() {
    if (tempStartDate.isEmpty) {
      return TextStyle(fontSize: 18, color: Colors.grey);
    } else {
      return TextStyle(fontSize: 18, color: Colors.black);
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
        startDate = DateTime(picked.start.year, picked.start.month,
            picked.start.day); // 날짜 부분만 저장
        endDate = DateTime(
            picked.end.year, picked.end.month, picked.end.day); // 날짜 부분만 저장
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
