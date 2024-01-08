import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../functional.dart';


class Plan extends StatefulWidget {
  final int post_index;

  Plan({Key? key, required this.post_index,}) : super(key: key);
  @override
  _PlanState createState() => _PlanState();
}

class _PlanState extends State<Plan> {
  TravelData travelData = TravelData(postIndex: 0, day: []);
  late Future<TravelData> futureTravelData;

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
      ),
      body: FutureBuilder<TravelData>(
        future: futureTravelData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('데이터를 불러오는데 실패했습니다.'));
          } else if (snapshot.hasData) {
            return buildTravelPlan(snapshot.data!);
          } else {
            return Center(child: Text('데이터가 없습니다.'));
          }
        },
      ),
    );
  }

  Widget buildTravelPlan(TravelData travelData) {
    return ListView.builder(
      itemCount: travelData.day.length,
      itemBuilder: (context, index) {
        // 첫 번째 계층의 ListTile (각 일차)
        Map<String, dynamic> dailyPlan = travelData.day[index];
        String dateKey = dailyPlan.keys.first;
        Map<String, dynamic> dayData = dailyPlan[dateKey];

        List<Widget> dayPlanWidgets = [
          ListTile(
            title: Text('${index + 1}일차'),
            subtitle: Text(dateKey),
          ),
        ];

        // 시작 호텔 정보
        List<dynamic> startHotelData = dayData['start_hotel'];
        dayPlanWidgets.add(ListTile(
          title: Text('시작 호텔'),
          subtitle: Text('Location Index: ${startHotelData[0]}, 위도: ${startHotelData[1]}, 경도: ${startHotelData[2]}'),
        ));

        // 스팟 정보
        List<dynamic> spotsData = dayData['spots'];
        for (var spot in spotsData) {
          dayPlanWidgets.add(ListTile(
            title: Text('스팟'),
            subtitle: Text('Location Index: ${spot[0]}, 위도: ${spot[1]}, 경도: ${spot[2]}'),
          ));
        }

        // 종료 호텔 정보
        List<dynamic> endHotelData = dayData['end_hotel'];
        dayPlanWidgets.add(ListTile(
          title: Text('종료 호텔'),
          subtitle: Text('Location Index: ${endHotelData[0]}, 위도: ${endHotelData[1]}, 경도: ${endHotelData[2]}'),
        ));

        return Card( // 이 Card는 각 일차를 구분하는 데 사용됩니다.
          child: Column(
            children: dayPlanWidgets,
          ),
        );
      },
    );
  }
}