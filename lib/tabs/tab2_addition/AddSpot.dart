import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../functional.dart';


class AddSpot extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String startDate;
  final String endDate;

  AddSpot({Key? key, required this.latitude, required this.longitude, required this.startDate, required this.endDate}) : super(key: key);
  @override
  _AddSpotState createState() => _AddSpotState();
}

class _AddSpotState extends State<AddSpot> {
  // Location location = Location(0, 0);
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = []; // 검색 결과를 저장하는 리스트
  Set<Marker> _markers = {}; // 지도에 표시할 마커들을 저장하는 집합
  String? selectedSpotName;
  double? selectedSpotLatitude;
  double? selectedSpotLongitude;
  DateTime? tempDate;
  List<List<dynamic>> spots = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('스팟 선택'),
          backgroundColor: Colors.green[700],
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: '검색',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _onSearchPressed,
                  ),
                ),
                textInputAction: TextInputAction.go,
                onSubmitted: (value) async {
                  _onSearchPressed();
                },
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.latitude, widget.longitude),
                      zoom: 11.0,
                    ),
                    markers: _markers,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: MapBottomSheet(
                      searchResults: _searchResults,
                      onSpotSelected: _onSpotSelected,
                      onAddDate: (BuildContext context) => _handleAddDate(),
                      selectedSpots: spots,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: () {
              // 완료 버튼을 눌렀을 때 실행할 로직
            },
            child: Text('완료'),
            style: ElevatedButton.styleFrom(
              primary: Colors.green[700],
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            ),
          ),
        ),
      ),
    );
  }




  void _onSearchPressed() async {
    print("hello");
    var keyword = _searchController.text;
    if (widget.latitude != null && widget.longitude != null) {
      var results = await find_place(widget.latitude, widget.longitude, keyword);
      // print("results type:${results.runtimeType}");
      setState(() {
        _searchResults = results;
        // print("result list: ${_searchResults}");
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onSpotSelected(String name, double latitude, double longitude) {
    final marker = Marker(
      markerId: MarkerId('${latitude}_$longitude'),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: 'name',
        snippet: '위도: $latitude, 경도: $longitude',
      ),
    );

    setState(() {
      selectedSpotName = name;
      selectedSpotLatitude = latitude;
      selectedSpotLongitude = longitude;
      _markers.clear(); // 기존 마커를 제거합니다.
      _markers.add(marker); // 지도에 마커 추가
      // 선택한 위치로 지도의 카메라 이동 (선택적)
    });

    // 선택한 위치로 지도의 카메라 이동 및 줌 인
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15.0, // 줌 레벨 설정
        ),
      ),
    );
  }

  Future<void> _showAddDateDialog(BuildContext context) async {
    DateTime? initialStartDate;
    DateTime? initialEndDate;

    if (widget.startDate != null) {
      initialStartDate = DateFormat('yyyy-MM-dd').parse(widget.startDate);
    }

    if (widget.endDate != null) {
      initialEndDate = DateFormat('yyyy-MM-dd').parse(widget.endDate);
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialStartDate ?? DateTime.now(), // 기본값으로 오늘 날짜 사용
      firstDate: initialStartDate ?? DateTime.now(), // 선택 가능한 가장 이른 날짜
      lastDate: initialEndDate ?? DateTime.now().add(Duration(days: 365)), // 선택 가능한 가장 늦은 날짜
    );

    if (picked != null) {
      setState(() {
        String dateStr = DateFormat('yyyy-MM-dd').format(picked);
        spots.add([dateStr, selectedSpotName, selectedSpotLatitude, selectedSpotLongitude]);
        print(spots);
        tempDate = picked; // 선택된 날짜를 tempDate에 저장
      });

      if (DateFormat('yyyy-MM-dd').format(picked) != widget.endDate) {
        // 선택된 날짜가 widget.endDate와 다르면 필요한 로직 추가
      } else {
        // 선택된 날짜가 widget.endDate와 같으면 새로운 페이지로 이동
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSpot(latitude: widget.latitude, longitude: widget.longitude, startDate: widget.startDate, endDate: widget.endDate))
        );
      }
    }
  }

  void _handleAddDate() {
    // 콜백 함수
    _showAddDateDialog(context);
  }
}

class MapBottomSheet extends StatefulWidget {
  final void Function(BuildContext) onAddDate;

  final List<dynamic> searchResults; // 검색 결과를 받는 생성자 매개변수
  final Function(String, double, double) onSpotSelected; // 핀 추가 로직을 위한 콜백 함수 추가
  final List<List<dynamic>> selectedSpots;
  const MapBottomSheet({
    super.key,
    required this.searchResults,
    required this.onSpotSelected,
    required this.onAddDate,
    required this.selectedSpots
  });


  @override
  State<MapBottomSheet> createState() => _MapBottomSheetState();
}

class _MapBottomSheetState extends State<MapBottomSheet> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.1, // 초기 크기 (화면의 10% 차지)
      minChildSize: 0.1, // 최소 크기
      maxChildSize: 0.8, // 최대 크기
      snapSizes: [0.1, 0.4, 0.8], // 스냅 크기들
      builder: (context, scrollController) {
        return Container(
          color: Colors.blue,
          child: ListView.builder(
            controller: scrollController,
            itemCount: widget.searchResults.length,
            itemBuilder: (context, index) {
              var spot = widget.searchResults[index];
              return Card(
                child: ListTile(
                  title: Text(spot[0]),
                  subtitle: Text('${spot[3]}\nRating: ${spot[4]}, Reviews: ${spot[5]}'),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      // 부모 위젯에서 전달된 콜백 함수 호출, 현재의 BuildContext 전달
                      widget.onAddDate(context);
                      // 여기서 onHotelSelected 호출
                      widget.onSpotSelected(spot[0], spot[1], spot[2]);
                    },
                  ),
                  onTap: () {
                    // 호텔 선택 시 콜백 호출
                    widget.onSpotSelected(spot[0], spot[1], spot[2]);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}