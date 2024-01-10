import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import '../../functional.dart';
import 'Plan.dart';


class AddSpot extends StatefulWidget {
  final int post_index;
  final double latitude;
  final double longitude;
  final String startDate;
  final String endDate;

  AddSpot({Key? key, required this.post_index, required this.latitude, required this.longitude, required this.startDate, required this.endDate}) : super(key: key);
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
  String? selectedSpotVicinity;
  double? selectedSpotRating;
  int? selectedSpotReview;
  DateTime? tempDate;
  List<List<dynamic>> spots = [];

  String _mapStyle = "";

  @override
  void initState() {
    super.initState();
    // JSON 파일에서 지도 스타일을 읽습니다.
    rootBundle.loadString('assets/map_styles.json').then((string) {
      _mapStyle = string;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("가고 싶은 곳이 있나요?", style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w800)), // 메인 제목 스타일
              SizedBox(height: 4),
              Text("가고 싶은 곳과 날짜를 선택해보세요!",
                  style: TextStyle(fontSize: 14)), // 부제목 스타일
            ],
          ),
          leading: IconButton(
            icon: ImageIcon(
              AssetImage("assets/icon_goBack.png"),
              // AssetImage를 사용하여 아이콘 이미지 지정
              size: 25.0, // 아이콘 크기 설정
              color: Colors.black, // 아이콘 색상 설정
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
            children: [
              Column(
              children: [
                Padding(
                  padding: EdgeInsets.zero,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 50.0, // TextField의 최대 높이 제한
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white, // 배경색 설정
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // 그림자 색상과 투명도
                          spreadRadius: 0, // 그림자의 확장 범위
                          blurRadius: 4, // 그림자의 흐림 정도
                          offset: Offset(0, 3), // 수직 방향 오프셋 (아래쪽으로 그림자)
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '여기서 검색',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none, // 테두리 없애기 (필요에 따라 설정)
                        ),
                        prefixIcon: ImageIcon(
                          AssetImage("assets/icon_addSearch.png"),
                          // AssetImage를 사용하여 아이콘 이미지 지정
                          size: 25.0, // 아이콘 크기 설정
                          color: Colors.green, // 아이콘 색상 설정
                        ),
                      ),
                      textInputAction: TextInputAction.go,
                      onSubmitted: (value) async {
                        _onSearchPressed();
                      },
                    ),
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
            ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: () async {

              await post_spots(spots, widget.post_index);
              print("spots");

              // [[2024-01-28, Guru Harkrishan Park, 28.70967469999999, 77.2018906], [2024-01-31, Parmanand Community Park, 28.7096815, 77.20752499999999]]

              // 여기에 팝업을 띄우는 로직을 넣습니다.
              showDialog<void>(
                context: context,
                barrierDismissible: false, // 사용자가 대화상자 바깥을 터치해도 닫히지 않도록 설정
                builder: (BuildContext context) {
                  print("here pushed");
                  // 2초 후에 대화상자를 닫습니다.
                  Future.delayed(Duration(seconds: 2), () {
                    Navigator.of(context).pop(); // 팝업을 닫습니다.
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => Plan(post_index: widget.post_index), // Plan 페이지로 이동
                    ));
                  });

                  // 팝업의 내용을 정의합니다.
                  return AlertDialog(
                    backgroundColor: Colors.white, // Set the background color to white
                    elevation: 5.0, // Set the elevation for shadow effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    content: Container(
                      width: double.maxFinite,
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ImageIcon(
                          AssetImage("assets/icon_loading.png"), // 여기에 아이콘 경로를 정확히 입력하세요.
                          size: 50, // 아이콘 크기 설정
                          // color: Colors.blue, // 아이콘 색상 설정 (필요한 경우)
                        ),
                        SizedBox(height: 16), // 아이콘과 제목 사이의 간격
                        Text('경로를 생성중입니다...', textAlign: TextAlign.center),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "설정한 출발지와 도착지로 최적의 동선을 편달중이에요.",
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                      ),
                    ),
                  );
                },
              );
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
      var modifiedResults = results.map((result) {
        if (result[4] == 0) {
          result[4] = 0.0; // result[4]가 0이라면 0.0으로 변환
        }
        return result; // 수정된 result 반환
      }).toList(); // 결과를 다시 리스트로 변환

      results = modifiedResults;
      setState(() {
        _searchResults = results;
        print("result list: ${_searchResults}");
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
  }

  void _onSpotSelected(String name, double latitude, double longitude, String vicinity, double rating, int reviews) {
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
      selectedSpotVicinity = vicinity;
      selectedSpotRating = rating;
      selectedSpotReview = reviews;
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

        print(dateStr);
        print(selectedSpotName);
        print(selectedSpotLatitude);
        print(selectedSpotLongitude);
        print(selectedSpotVicinity);
        print(selectedSpotRating);
        print(selectedSpotReview);

        spots.add([dateStr, selectedSpotName ?? '', selectedSpotLatitude ?? 0.0, selectedSpotLongitude ?? 0.0, selectedSpotVicinity ?? '', selectedSpotRating ?? 0.0, selectedSpotReview ?? 0]);
        print(spots);
        tempDate = picked; // 선택된 날짜를 tempDate에 저장
      });
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
  final Function(String, double, double, String, double, int) onSpotSelected; // 핀 추가 로직을 위한 콜백 함수 추가
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
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.1, // 초기 크기 (화면의 10% 차지)
      minChildSize: 0.1, // 최소 크기
      maxChildSize: 0.8, // 최대 크기
      snapSizes: [0.1, 0.4, 0.8], // 스냅 크기들
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white, // 하얀색 배경
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ), // 상단 모서리 둥글게
          ),
          child: ListView.builder(
            controller: scrollController,
            itemCount: widget.searchResults.length,
            itemBuilder: (context, index) {
              var spot = widget.searchResults[index];
              print(spot);
              print(spot[0].runtimeType);
              print(spot[1].runtimeType);
              print(spot[2].runtimeType);
              print(spot[3].runtimeType);
              print(spot[4].runtimeType);
              print(spot[5].runtimeType);

              return Container(
                color: Colors.white, // 각 ListTile의 배경색

                margin: index == 0 ? EdgeInsets.only(top: 8.0) : EdgeInsets.all(0), // 첫 번째 ListTile과 BottomSheet 사이의 공간 조절
                child: Card(
                elevation: 2, // 카드에 그림자 추가
                margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // 카드 주변 여백
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min, // Row 크기를 최소화
                      children: [
                        ImageIcon(
                          AssetImage("assets/icon_spot.png"), // 호텔 아이콘 추가
                          size: 24.0, // 아이콘 크기
                        ),
                        SizedBox(width: 10), // 아이콘과 제목 사이 간격
                      ],
                    ),
                    title: Text(spot[0], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(text: '\n${spot[3]}', style: TextStyle(fontSize: 13)),
                          // TextSpan(text: '\nRating: ${spot[4]}, Reviews: ${spot[5]}', style: TextStyle(fontSize: 15)),
                          TextSpan(text: '\n${spot[4]} ', style: TextStyle(fontSize: 13)), //Rating
                          ...generateStarSpans(getStarCounts(spot[4] ?? 0.0)['full']!, getStarCounts(spot[4] ?? 0.0)['half']!, getStarCounts(spot[4] ?? 0.0)['empty']!),
                          TextSpan(text: ' (${spot[5]})', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    trailing: Row(
                        mainAxisSize: MainAxisSize.min, // Row의 크기를 최소한으로 설정
                        children: [
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              // 부모 위젯에서 전달된 콜백 함수 호출, 현재의 BuildContext 전달
                              widget.onAddDate(context);
                              // 여기서 onHotelSelected 호출
                              widget.onSpotSelected(spot[0], spot[1], spot[2], spot[3], spot[4], spot[5]);
                            },
                          ),
                        ],
                    ),
                    onTap: () {
                      // 호텔 선택 시 콜백 호출
                      widget.onSpotSelected(spot[0], spot[1].toDouble(), spot[2].toDouble(), spot[3], spot[4].toDouble(), spot[5]);
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  int calculateFullStars(double rating) {
    return rating ~/ 1; // Use integer division to calculate the number of full stars
  }

  int calculateHalfStars(double rating) {
    int fullStars = calculateFullStars(rating);
    return (rating - fullStars >= 0.5) ? 1 : 0; // Add a half star if there's a remainder of 0.5 or more
  }

  int calculateEmptyStars(double rating) {
    int fullStars = calculateFullStars(rating);
    int halfStars = calculateHalfStars(rating);
    return 5 - fullStars - halfStars; // Subtract the number of full and half stars from the total of 5 stars
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
}