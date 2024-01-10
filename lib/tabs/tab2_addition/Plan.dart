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
  Map<String, dynamic> data = {};
  int days = 0;
  String startDate = "";
  String endDate = "";

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
    data = await getPostDetails(widget.post_index);

    user_id = data['user_id'];
    city = data['city'];
    days = data['day_count'];
    startDate = data['start_day'];
    endDate = data['end_day'];

    imagePath = "$user_id.jpg";

    userName = await getUserNickname(user_id);

    print(userName);

    setState(() {});
  }

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: TextStyle(fontSize: 22, color: Colors.white)),
                  ],
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 20), // 여백 조절
                  child: Row(
                    children: [
                      // SizedBox(
                      //   width: 30,
                      // ),
                      ImageIcon(
                        AssetImage("assets/icon_post.png"), // 호텔 아이콘 추가
                        size: 24.0, // 아이콘 크기
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        // Expanded를 사용하여 텍스트가 공간을 벗어나지 않도록 함
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${city}, ${days}일',
                              style:
                                  TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w800),
                              overflow:
                                  TextOverflow.ellipsis, // 긴 텍스트는 말줄임표로 처리
                            ),
                            Text(
                              '${startDate} ~ ${endDate}',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                              overflow:
                                  TextOverflow.ellipsis, // 긴 텍스트는 말줄임표로 처리
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: ImageIcon(
                          AssetImage(
                              "assets/icon_map.png"),
                          color: Colors.white,// Assuming this is the correct path to your asset
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Plan_map(
                                    travelData: futureTravelData,
                                    post_index: widget.post_index)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
    );
  }

  final String iconMapPath = 'assets/icon_map.png';
  final String iconHotelPath = 'assets/icon_hotel.png';
  final String iconSpotPath = 'assets/icon_spot.png';

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
                  // return  ListView.builder(
                  //     shrinkWrap: true, // 이 부분을 추가하였습니다.
                  //     itemCount: snapshot.data!.day.length, // 일정의 총 일수
                  //     itemBuilder: (context, index) {
                  //       // 각 일차의 데이터를 가져옵니다.
                  //       Map<String, dynamic> dayData =
                  //           snapshot.data!.day[index];
                  //       String dateKey = dayData.keys.first; // 날짜를 키로 사용
                  //
                  //       // 여기에서 각 일차별 정보를 ListTile로 표시
                  //       return ExpansionTile(
                  //         title: Text('${index + 1}일차'),
                  //         subtitle: Text(dateKey),
                  //         children: [
                  //           buildHotelTile(
                  //               dayData[dateKey]['start_hotel'], '시작 호텔'),
                  //           ...buildSpotsTiles(dayData[dateKey]['spots']),
                  //           buildHotelTile(
                  //               dayData[dateKey]['end_hotel'], '종료 호텔'),
                  //         ],
                  //       );
                  List<Widget> dayCards = [];
                  for (int i = 0; i < snapshot.data!.day.length; i++) {
                    var dayData = snapshot.data!.day[i];
                    String dateKey = dayData.keys.first; // 날짜를 키로 사용
                    var card = Card(
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      color: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.white.withOpacity(0.25),
                      child: Column(
                        children: [
                          ExpansionTile(
                            leading: ImageIcon(AssetImage('assets/icon_post.png')),
                            title: Text(('${i + 1}일차'),
                            style:
                            TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w800)),
                            // subtitle: Text(dayData['details']),\
                            children: <Widget>[
                              buildHotelTile(
                                  dayData[dateKey]['start_hotel'], '시작 호텔'),
                              ...buildSpotsTiles(dayData[dateKey]['spots']),
                              buildHotelTile(
                                  dayData[dateKey]['end_hotel'], '종료 호텔'),
                            ],
                          ),
                          // 다른 세부 정보와 위젯을 여기에 추가...
                        ],
                      ),
                    );
                    dayCards.add(card);
                  }
                  return Column(children: dayCards);
                } else {
                  return Text('데이터가 없습니다.');
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
          return Card(
            surfaceTintColor: Colors.transparent,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.25),
            child: ListTile(
              leading: ImageIcon(
                AssetImage("assets/icon_hotel.png"),
                size: 24.0,
              ),
              title: Text(
                snapshot.data!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        } else {
          return ListTile(title: Text('정보가 없습니다.'));
        }
      },
    );
  }

  List<Widget> buildLocationTiles(List<dynamic> locationData) {
    if (locationData == null || locationData.isEmpty) {
      return [ListTile(title: Text('스팟 정보가 없습니다.'))];
    }
    return [
      FutureBuilder<Map<String, dynamic>>(
        future: getSpotDetail(locationData[0]),
        builder: (context, snapshot) {
          print("{$locationData[0]} : ${snapshot.data}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListTile(title: Text('스팟 정보를 불러오는 중...'));
          } else if (snapshot.hasError) {
            return ListTile(title: Text('스팟 정보를 불러오는데 실패했습니다.'));
          } else if (snapshot.hasData) {
            var detail = snapshot.data!;
            print("detail : $detail");
            return Card(
              surfaceTintColor: Colors.transparent,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.25),
              child: ListTile(
                leading: ImageIcon(
                  AssetImage("assets/icon_spot.png"),
                  size: 24.0,
                ),
                title: Text(detail['location_name'],
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                          text: '\n${detail['vicinity']}',
                          style: TextStyle(fontSize: 13)),
                      // TextSpan(text: '\nRating: ${spot[4]}, Reviews: ${spot[5]}', style: TextStyle(fontSize: 15)),
                      TextSpan(
                          text: '\n${detail['stars']} ',
                          style: TextStyle(fontSize: 13)),
                      //Rating
                      ...generateStarSpans(
                          getStarCounts(
                              detail['stars'].toDouble() ?? 0.0)['full']!,
                          getStarCounts(
                              detail['stars'].toDouble() ?? 0.0)['half']!,
                          getStarCounts(
                              detail['stars'].toDouble() ?? 0.0)['empty']!),
                      TextSpan(
                          text: ' (${detail['nReview']})',
                          style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return ListTile(title: Text('정보가 없습니다.'));
          }
        },
      ),
    ];
  }

  int calculateFullStars(double rating) {
    return rating ~/
        1; // Use integer division to calculate the number of full stars
  }

  int calculateHalfStars(double rating) {
    int fullStars = calculateFullStars(rating);
    return (rating - fullStars >= 0.5)
        ? 1
        : 0; // Add a half star if there's a remainder of 0.5 or more
  }

  int calculateEmptyStars(double rating) {
    int fullStars = calculateFullStars(rating);
    int halfStars = calculateHalfStars(rating);
    return 5 -
        fullStars -
        halfStars; // Subtract the number of full and half stars from the total of 5 stars
  }

  Map<String, int> getStarCounts(double rating) {
    return {
      'full': calculateFullStars(rating),
      'half': calculateHalfStars(rating),
      'empty': calculateEmptyStars(rating),
    };
  }

  List<InlineSpan> generateStarSpans(int full, int half, int empty) {
    List<InlineSpan> spans = [];

    // Add full stars
    for (int i = 0; i < full; i++) {
      spans.add(
        WidgetSpan(
          child: Icon(Icons.star, size: 15, color: Colors.yellow),
        ),
      );
    }

    // Add half stars
    for (int i = 0; i < half; i++) {
      spans.add(
        WidgetSpan(
          child: Icon(Icons.star_half, size: 15, color: Colors.yellow),
        ),
      );
    }

    // Add empty stars
    for (int i = 0; i < empty; i++) {
      spans.add(
        WidgetSpan(
          child: Icon(Icons.star_border, size: 15, color: Colors.grey),
        ),
      );
    }

    return spans;
  }

  List<Widget> buildSpotsTiles(List<dynamic>? spotsData) {
    if (spotsData == null) {
      return [ListTile(title: Text('스팟 정보가 없습니다.'))];
    }
    List<Widget> tiles = [];
    for (var spot in spotsData) {
      tiles.addAll(buildLocationTiles(spot));
    }
    return tiles;
  }
}
