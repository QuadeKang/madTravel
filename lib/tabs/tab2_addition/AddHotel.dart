import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../functional.dart';
import 'dart:math';

class AddHotel extends StatefulWidget {
  final String city;
  const AddHotel({Key? key, required this.city}) : super(key: key);

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
  Location location = Location(0, 0);
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = []; // 검색 결과를 저장하는 리스트

  void _onSearchPressed() async {
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
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  MapBottomSheet(searchResults: _searchResults),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  // "숙소 추가" 버튼 로직
                },
                child: Text('숙소 추가'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class MapBottomSheet extends StatefulWidget {
  final List<dynamic> searchResults; // 검색 결과를 받는 생성자 매개변수
  const MapBottomSheet({super.key, required this.searchResults});


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
                    ),
                  );
                },
              ),
            );
          },
        );
  }
}