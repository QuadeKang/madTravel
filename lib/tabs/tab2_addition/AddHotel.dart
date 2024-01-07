import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../functional.dart';
import 'dart:math';

class AddHotel extends StatefulWidget {
  final String city, startDate, endDate;
  const AddHotel({Key? key, required this.city, required this.startDate, required this.endDate}) : super(key: key);

  @override
  _AddHotelState createState() => _AddHotelState();
}

class Location {
  double latitude;
  double longitude;

  Location(this.latitude, this.longitude);
}

class Hotel {
  String name;
  double latitude;
  double longitude;
  String vicinity;
  double rating;
  int totalRatings;

  Hotel({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.vicinity,
    required this.rating,
    required this.totalRatings,
  });
}

class _AddHotelState extends State<AddHotel> {
  String? selectedHotelName;
  double? selectedHotelLatitude;
  double? selectedHotelLongitude;
  List<List<dynamic>> hotels = [];
  DateTime? tempStartDate;
  DateTime? tempEndDate;

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    return DateFormat('yyyy-MM-dd').parse(dateStr);
  }

  Location location = Location(0, 0);
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = []; // 검색 결과를 저장하는 리스트
  Set<Marker> _markers = {}; // 지도에 표시할 마커들을 저장하는 집합

  void _onHotelSelected(String name, double latitude, double longitude) {
    final marker = Marker(
      markerId: MarkerId('${latitude}_$longitude'),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: 'name',
        snippet: '위도: $latitude, 경도: $longitude',
      ),
    );

    setState(() {
      selectedHotelName = name;
      selectedHotelLatitude = latitude;
      selectedHotelLongitude = longitude;
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

  void _onSearchPressed() async {
    print("hello");
    var keyword = _searchController.text;
    if (location.latitude != null && location.longitude != null) {
      var results = await find_hotel(location.latitude, location.longitude, keyword);
      // print("results type:${results.runtimeType}");
      setState(() {
        _searchResults = results;
        // print("result list: ${_searchResults}");
      });
    }
  }
  @override
  void initState() {
    super.initState();
    print("Received city: ${widget.city}"); // 디버깅을 위한 출력
    tempStartDate = _parseDate(widget.startDate);
    tempEndDate = _parseDate(widget.endDate);
  }

  Future<LatLng> _getCityLocation(String city) async {
    var cityInfo = await find_city(city); // city의 위도, 경도 받아옴
    location.latitude=cityInfo[1];
    location.longitude=cityInfo[2];
    return LatLng(cityInfo[1], cityInfo[2]);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('호텔 선택'),
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
            Expanded(
              child: Stack(
                children: [
                  Column(
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
                            _onSearchPressed(); // 엔터 키를 눌렀을 때 검색 실행
                          },
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<LatLng>(
                          future: _getCityLocation(widget.city),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return GoogleMap(
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: CameraPosition(
                                  target: snapshot.data!,
                                  zoom: 11.0,
                                ),
                                markers: _markers, // 마커들을 지도에 표시
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  MapBottomSheet(
                    searchResults: _searchResults,
                    onHotelSelected: _onHotelSelected, // 콜백 함수 전달
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () => _showAddDateDialog(context),
                child: Text('숙소 추가'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDateDialog(BuildContext context) async {
    DateTime? initialEndDate;
    if (widget.endDate != null) {
      initialEndDate = DateFormat('yyyy-MM-dd').parse(widget.endDate);
    }
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      // initialDate: fixedStartDate!,
      firstDate: tempStartDate!,
      lastDate: initialEndDate!, //widget.endDate로 바꿔야 함
      initialDateRange: tempEndDate != null? DateTimeRange(start: tempStartDate!, end: tempEndDate!)
          : null, // 이전에 선택된 날짜가 있으면 사용, 없으면 null
    );

    if (picked != null) {
      setState(() {
        String startDateStr = DateFormat('yyyy-MM-dd').format(picked.start);
        String endDateStr = DateFormat('yyyy-MM-dd').format(picked.end);
        hotels.add([startDateStr, endDateStr, selectedHotelName, selectedHotelLatitude, selectedHotelLongitude]);
        print(hotels);
        tempStartDate = picked.end;
      });
      if (DateFormat('yyyy-MM-dd').format(picked.end) != widget.endDate) {
        // 끝 날짜가 widget.endDate와 다르면 firstDate 업데이트

      } else {
        // 끝 날짜가 widget.endDate와 같으면 새로운 페이지로 이동
        _navigateToNextPage(context);
      }
    }
  }

  void _navigateToNextPage(BuildContext context) {
    // 새로운 페이지로 이동하는 로직
  }

}

class MapBottomSheet extends StatefulWidget {
  final List<dynamic> searchResults; // 검색 결과를 받는 생성자 매개변수
  final Function(String, double, double) onHotelSelected; // 핀 추가 로직을 위한 콜백 함수 추가
  const MapBottomSheet({super.key, required this.searchResults, required this.onHotelSelected});


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
                  var hotel = widget.searchResults[index];
                  return Card(
                    child: ListTile(
                      title: Text(hotel[0]),
                      subtitle: Text('${hotel[3]}\nRating: ${hotel[4]}, Reviews: ${hotel[5]}'),
                      onTap: () {
                        widget.onHotelSelected(hotel[0], hotel[1], hotel[2]); // 호텔 선택 시 콜백 호출
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