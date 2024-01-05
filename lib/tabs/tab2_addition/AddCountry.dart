import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'AddCity.dart'; // AddCity 페이지를 import 합니다.

class AddCountry extends StatelessWidget {
  Future<Map<String, dynamic>> loadCountries() async {
    // JSON 파일을 읽고 파싱합니다.
    String jsonString = await rootBundle.loadString('assets/countries.json');
    return json.decode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    final String country; // 국가 이름을 저장할 변수
    // 이 예시에서는 국가 목록을 하드코딩했습니다. 실제 앱에서는 이 데이터를 서버에서 가져오거나 로컬 데이터베이스에서 로드할 수 있습니다.
    // final List<String> countries = ["Afghanistan", "South Korea", "United States"];

    return Scaffold(
      appBar: AppBar(
        title: Text('국가 선택'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadCountries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            var countries = snapshot.data!.keys.toList();
            return ListView.builder(
              itemCount: countries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(countries[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCity(country: countries[index]),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: Text('국가 목록을 불러올 수 없습니다.'));
          }
        },
      ),
    );
  }
}
