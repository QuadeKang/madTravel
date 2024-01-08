import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../functional.dart';

class TabData {
  String title;
  List<LatLng> latlngList;

  TabData({required this.title, required this.latlngList});
}

class Plan_map extends StatefulWidget {
  final int post_index;

  Plan_map({Key? key, required this.post_index}) : super(key: key);
  @override
  _Plan_mapState createState() => _Plan_mapState();
}

class _Plan_mapState extends State<Plan_map> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TabData> tabDataList = [
    TabData(title: '경로 1', latlngList: [LatLng(37.7749, -122.4194), LatLng(39, -100)]),
    TabData(title: '경로 2', latlngList: [LatLng(37.7749, -122.4194), LatLng(39, -100)]),
    // 여기에 추가 탭 데이터...
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabDataList.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('여행 경로'),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabDataList.map((tabData) => Tab(text: tabData.title)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabDataList.map((tabData) => MapTabView(latlngList: tabData.latlngList)).toList(),
      ),
    );
  }
}

class MapTabView extends StatelessWidget {
  final List<LatLng> latlngList;

  MapTabView({required this.latlngList});

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
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
    );
  }
}