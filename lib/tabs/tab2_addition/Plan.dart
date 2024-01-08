import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../functional.dart';
import 'Plan_map.dart';


class Plan extends StatefulWidget {
  final int post_index;

  Plan({Key? key, required this.post_index}) : super(key: key);
  @override
  _PlanState createState() => _PlanState();
}

class _PlanState extends State<Plan> {
  TravelData travelData = TravelData(postIndex: 0, day: []);
  late Future<TravelData> futureTravelData;
  late Map<int, Future<Map<String, dynamic>>> spotDetails = {};

  @override
  void initState() {
    super.initState();
    futureTravelData = fetchTravelData(widget.post_index); // 비동기 데이터 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('여행 일정'),
        backgroundColor: Colors.green[700],
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // 버튼을 눌렀을 때 실행할 동작을 여기에 작성합니다.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Plan_map(travelData: futureTravelData)), // Plan_map 페이지로 이동
              );
            },
            child: Text(
              '전환',
              style: TextStyle(
                color: Colors.white, // 텍스트 버튼의 색상
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<TravelData>(
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
                ListTile(title: Text('위도: ${detail['location_lat']}')),
                ListTile(title: Text('경도: ${detail['location_lng']}')),
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