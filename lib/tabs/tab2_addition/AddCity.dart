import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'AddHotel.dart'; // AddHotel 페이지를 import 합니다.

class AddCity extends StatelessWidget {
  final String country;

  AddCity({required this.country});

  Future<List<String>> loadCities() async {
    // JSON 파일을 읽고 파싱합니다.
    String jsonString = await rootBundle.loadString('assets/countries.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    return List<String>.from(jsonMap[country]);
  }

  @override
  Widget build(BuildContext context) {
    final String city;
    // 이 예시에서는 도시 목록을 하드코딩했습니다. 실제 앱에서는 선택한 국가에 따라 이 데이터를 서버에서 가져오거나 로컬 데이터베이스에서 로드할 수 있습니다.
    // final List<String> cities = ["Herat", "Kabul", "Kandahar"];

    return Scaffold(
      appBar: AppBar(
        title: Text('$country의 도시 선택'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: loadCities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            var cities = snapshot.data!;
            return ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cities[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddHotel(city: cities[index]),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: Text('$country에 대한 도시 목록을 불러올 수 없습니다.'));
          }
        },
      ),
    );
  }
}
