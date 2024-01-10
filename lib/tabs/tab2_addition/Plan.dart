import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../functional.dart';
import 'Plan_map.dart';
import 'package:path_provider/path_provider.dart';



class Plan extends StatefulWidget {
  final int post_index;

  Plan({Key? key, required this.post_index}) : super(key: key);
  @override
  _PlanState createState() => _PlanState();
}

class _PlanState extends State<Plan> {
  String? imagePath;
  int? user_id;
  String? userName = "강정환";
  String city = "도쿄";
  // late int days;
  // late String startDate;
  // late String endDate;

  TravelData travelData = TravelData(postIndex: 0, day: []);
  late Future<TravelData> futureTravelData;
  late Map<int, Future<Map<String, dynamic>>> spotDetails = {};


  @override
  void initState() {
    super.initState();
    futureTravelData = fetchTravelData(widget.post_index); // 비동기 데이터 가져오기
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
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
                    SizedBox(width: 28),
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
                    ImageIcon(
                      AssetImage("assets/marker_spot.png"), // 호텔 아이콘 추가
                      size: 24.0, // 아이콘 크기
                      color: Colors.white,
                    ),
                  //   Text('${city}, ${days}일',
                  //       style: TextStyle(
                  //           fontSize: 20,
                  //           color: Colors.white)),
                  //   SizedBox(width: 8),
                  // ],
                  // Text('${startDate}~${endDate}일',
                  //     style: TextStyle(
                  //         fontSize: 20,
                  //         color: Colors.white)),
                  IconButton(
                    icon: ImageIcon(
                      AssetImage("assets/icon_map.png"), // Assuming this is the correct path to your asset
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Plan_map(travelData: futureTravelData, post_index: widget.post_index)),
                      );
                    },
                  ),
                  ],
                ),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 22,
          bottom: 30,
          left: 28,
          right: 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          FutureBuilder<TravelData>(
            future: futureTravelData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('데이터를 불러오는데 실패했습니다.'));
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.day.length, // 일정의 총 일수
                  itemBuilder: (context, index) {
                    // 각 일차의 데이터를 가져옵니다.
                    Map<String, dynamic> dayData = snapshot.data!.day[index];
                    String dateKey = dayData.keys.first; // 날짜를 키로 사용

                    // 여기에서 각 일차별 정보를 ListTile로 표시
                    return ExpansionTile(
                      title: Text('${index + 1}일차'),
                      subtitle: Text(dateKey),
                      children: [
                        buildHotelTile(dayData[dateKey]['start_hotel'], '시작 호텔'),
                        ...buildSpotsTiles(dayData[dateKey]['spots']),
                        buildHotelTile(dayData[dateKey]['end_hotel'], '종료 호텔'),
                      ],
                    );
                  },
                );
              } else {
                return Center(child: Text('데이터가 없습니다.'));
              }
            },
          ),
          ],
        ),
      ),
    );
  }

  Widget buildHotelTile(dynamic hotelData, String title) {
    print(hotelData);
    return FutureBuilder<String>(
      future: get_hotel_name(hotelData[0]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(title: Text('$title 정보를 불러오는 중...'));
        } else if (snapshot.hasError) {
          return ListTile(title: Text('$title 정보를 불러오는데 실패했습니다.'));
        } else if (snapshot.hasData) {
          return ListTile(title: Text(snapshot.data!));
        } else {
          return ListTile(title: Text('정보가 없습니다.'));
        }
      },
    );
  }

  List<Widget> buildLocationTiles(List<dynamic>? locationData, String title) {
    if (locationData == null || locationData.isEmpty) {
      return [ListTile(title: Text('$title 정보가 없습니다.'))];
    }
    return [
      FutureBuilder<Map<String, dynamic>> (
        future: getSpotDetail(locationData[0]),
        builder: (context, snapshot) {
          print("{$locationData[0]} : ${snapshot.data}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListTile(title: Text('$title 정보를 불러오는 중...'));
          } else if (snapshot.hasError) {
            return ListTile(title: Text('$title 정보를 불러오는데 실패했습니다.'));
          } else if (snapshot.hasData) {
            var detail = snapshot.data!;
            return ExpansionTile(
              title: Text(detail['location_name']),
              children: [
                // ListTile(title: Text('위도: ${detail['location_lat']}')),
                // ListTile(title: Text('경도: ${detail['location_lng']}')),
                ListTile(title: Text('주소: ${detail['vicinity']}')),
                ListTile(title: Text('평점: ${detail['stars']}')),
                ListTile(title: Text('리뷰 수: ${detail['nReview']}')),
              ],
            );
          } else {
            return ListTile(title: Text('정보가 없습니다.'));
          }
        },
      ),
    ];
  }

  List<Widget> buildSpotsTiles(List<dynamic>? spotsData) {
    if (spotsData == null) {
      return [ListTile(title: Text('스팟 정보가 없습니다.'))];
    }
    List<Widget> tiles = [];
    for (var spot in spotsData) {
      tiles.addAll(buildLocationTiles(spot, '스팟'));
    }
    return tiles;
  }
}
