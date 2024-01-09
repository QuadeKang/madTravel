import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import '../../functional.dart';

class TabData {
  String title;
  List<LatLng> latlngList;
  List<String> locationTypes; // Add this list


  TabData({required this.title, required this.latlngList, required this.locationTypes});
}

class Plan_map extends StatefulWidget {
  Future<TravelData> travelData;

  Plan_map({Key? key, required this.travelData}) : super(key: key);
  @override
  _Plan_mapState createState() => _Plan_mapState();
}

class _Plan_mapState extends State<Plan_map> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<TabData> tabDataList; //클래스 멤버 변수로 선언

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: tabDataList.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('여행 경로'),
        backgroundColor: Colors.green[700],
        // AppBar 아래에 TabBar를 추가하는 것은 데이터 로딩 후에 해야 합니다.
      ),
      body: FutureBuilder<TravelData>(
        future: widget.travelData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('데이터를 불러오는데 실패했습니다.'));
          } else if (snapshot.hasData) {
            tabDataList = createTabDataList(snapshot.data!);
            _tabController = TabController(length: tabDataList.length, vsync: this);

            return Column(
              children: <Widget>[
                TabBar(
                  controller: _tabController,
                  tabs: tabDataList.map((tabData) => Tab(text: tabData.title)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: NeverScrollableScrollPhysics(), // 스와이프 비활성화
                    children: tabDataList.map((tabData) => MapTabView(latlngList: tabData.latlngList, locationTypes: tabData.locationTypes)).toList(),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('데이터가 없습니다.'));
          }
        },
      ),
    );
  }

  List<TabData> createTabDataList(TravelData travelData) {
    List<TabData> tabDataList = [];

    for (int i = 0; i < travelData.day.length; i++) {
      var dayData = travelData.day[i];
      String dateKey = dayData.keys.first;
      var dayDetails = dayData[dateKey];

      // start_hotel, spots, end_hotel의 모든 위치 데이터를 추출합니다.
      List<LatLng> latlngList = [];
      List<String> locationTypes = []; // Initialize the locationTypes list

      // start_hotel 추가
      var startHotel = dayDetails['start_hotel'];
      latlngList.add(LatLng(startHotel[1], startHotel[2]));
      locationTypes.add('hotel');

      // spots 추가
      for (var spot in dayDetails['spots']) {
        latlngList.add(LatLng(spot[1], spot[2]));
        locationTypes.add('spot'); // Add 'spot' for each spot
      }

      // end_hotel 추가
      var endHotel = dayDetails['end_hotel'];
      latlngList.add(LatLng(endHotel[1], endHotel[2]));
      locationTypes.add('hotel'); // Add 'hotel' for end_hotel

      // TabData 객체 생성
      tabDataList.add(TabData(title: '${i + 1}일차: $dateKey', latlngList: latlngList, locationTypes: locationTypes));
    }

    return tabDataList;
  }

}

class MapTabView extends StatelessWidget {
  final List<LatLng> latlngList;
  final List<String> locationTypes; // Add this to differentiate location types

  MapTabView({required this.latlngList, required this.locationTypes});

  Future<String> _loadMapStyle() async {
    return await rootBundle.loadString('assets/map_styles.json');
  }

  Future<BitmapDescriptor> _loadMarkerIcon(String assetPath) async {
    return await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(12, 12)), // Adjust size as needed
        assetPath // Path to your marker icon
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        _loadMapStyle(),
        _loadMarkerIcon('assets/marker_hotel.png'),
        _loadMarkerIcon('assets/marker_spot.png')
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          String mapStyle = snapshot.data![0] as String;
          BitmapDescriptor hotelIcon = snapshot.data![1] as BitmapDescriptor;
          BitmapDescriptor spotIcon = snapshot.data![2] as BitmapDescriptor;

          Set<Marker> _markers = List.generate(latlngList.length, (index) {
            return Marker(
              markerId: MarkerId('${latlngList[index].latitude}_${latlngList[index].longitude}'),
              position: latlngList[index],
              icon: locationTypes[index] == 'hotel' ? hotelIcon : spotIcon,
            );
          }).toSet();

          return GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              controller.setMapStyle(mapStyle);
            },
            initialCameraPosition: CameraPosition(
              target: latlngList.isNotEmpty ? latlngList[0] : LatLng(0, 0),
              zoom: 14.0,
            ),
            polylines: {
              Polyline(
                polylineId: PolylineId('route'),
                visible: true,
                points: latlngList,
                width: 4,
                color: Colors.blue,
              ),
            },
            markers: _markers,
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
  // @override
  // Widget build(BuildContext context) {
  //   Set<Marker> _markers = latlngList.map((latLng) {
  //     return Marker(
  //       markerId: MarkerId('${latLng.latitude}_${latLng.longitude}'),
  //       position: latLng,
  //     );
  //   }).toSet();
  //
  //   return FutureBuilder(
  //     future: _loadMapStyle(),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         String mapStyle = snapshot.data as String;
  //
  //         return GoogleMap(
  //           onMapCreated: (GoogleMapController controller) {
  //             controller.setMapStyle(mapStyle);
  //           },
  //           initialCameraPosition: CameraPosition(
  //             target: latlngList.isNotEmpty ? latlngList[0] : LatLng(0, 0),
  //             zoom: 14.0,
  //           ),
  //           polylines: {
  //             Polyline(
  //               polylineId: PolylineId('route'),
  //               visible: true,
  //               points: latlngList,
  //               width: 4,
  //               color: Colors.blue,
  //             ),
  //           },
  //           markers: _markers,
  //         );
  //       } else {
  //         return Center(child: CircularProgressIndicator());
  //       }
  //     },
  //   );
  // }
