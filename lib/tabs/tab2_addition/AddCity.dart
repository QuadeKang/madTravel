import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';


class AddCity extends StatelessWidget {
  Future<List<String>> readCitiesFile() async {
    try {
      // 파일 내용을 문자열로 읽기
      String contents = await rootBundle.loadString('assets/cities.txt');

      // 줄바꿈을 기준으로 문자열 분리하여 리스트 생성
      List<String> cities = contents.split('\n');

      debugPrint(cities[0]);

      return cities;
    } catch (e) {
      // 파일 읽기 실패 시 예외 처리
      print("An error occurred: $e");
      return [];
    }
  }

  // final String country;
  //
  // AddCity({required this.country});
  //
  // Future<List<String>> loadCities() async {
  //   // JSON 파일을 읽고 파싱합니다.
  //   String jsonString = await rootBundle.loadString('assets/countries.json');
  //   Map<String, dynamic> jsonMap = json.decode(jsonString);
  //   return List<String>.from(jsonMap[country]);
  // }

  @override
  Widget build(BuildContext context) {
    final String city;
    // 이 예시에서는 도시 목록을 하드코딩했습니다. 실제 앱에서는 선택한 국가에 따라 이 데이터를 서버에서 가져오거나 로컬 데이터베이스에서 로드할 수 있습니다.
    // final List<String> cities = ["Herat", "Kabul", "Kandahar"];

    return Scaffold(
      appBar: AppBar(
        title: Text('도시 선택'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: readCitiesFile(),
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
                    Navigator.pop(context, cities[index]); // 선택된 도시 이름을 반환
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: Text('도시 목록을 불러올 수 없습니다.'));
          }
        },
      ),
    );
  }
}