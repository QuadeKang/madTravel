import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddHotel extends StatefulWidget {
  final String city;
  const AddHotel({Key? key, required this.city}) : super(key: key);

  @override
  _AddHotelState createState() => _AddHotelState();
}

class _AddHotelState extends State<AddHotel> {
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  final LatLng _center = const LatLng(45.521563, -122.677433);

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
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: '검색',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      // 검색 로직 구현
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: const LatLng(45.521563, -122.677433),
                  zoom: 11.0,
                ),

              ),
            ),
          ],
        ),
        bottomSheet: DraggableScrollableSheet(
          initialChildSize: 0.1,  // 초기에 화면의 10%만 차지하도록 설정
          minChildSize: 0.1,
          maxChildSize: 0.8,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              color: Colors.blue[100],
              child: ListView.builder(
                controller: scrollController,
                itemCount: 25,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(title: Text('Item $index'));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}