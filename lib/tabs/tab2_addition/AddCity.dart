import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../functional.dart';

class AddCity extends StatefulWidget {

  @override
  _AddCityState createState() => _AddCityState();
}

class _AddCityState extends State<AddCity> {
  TextEditingController searchController = TextEditingController();
  Future<List<dynamic>>? citiesFuture;
  List<dynamic> allCities = [];
  List<dynamic> filteredCities = [];

  @override
  void initState() {
    super.initState();
    citiesFuture = readCitiesFile();
    citiesFuture!.then((cities) {
      allCities = cities;
      filteredCities = cities;
    });
  }

  void filterSearchResults(String query) {
    List<dynamic> dummySearchList = [];
    dummySearchList.addAll(allCities);
    if (query.isNotEmpty) {
      List<dynamic> dummyListData = [];
      dummySearchList.forEach((item) {
        String itemAsString = item.toString(); // dynamic 타입을 String으로 변환
        if (itemAsString.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(itemAsString);
        }
      });
      filteredCities = dummyListData; // 필터링된 도시 목록 업데이트
      // setState(() {
      //   filteredCities.clear();
      //   filteredCities.addAll(dummyListData);
      //   print(filteredCities);
      //
      // });
      // return;
    } else {
      filteredCities = allCities; // 쿼리가 비어있으면 전체 도시 목록 사용
    }
  }

  Future<List<dynamic>> readCitiesFile() async {
    try {
      var cities = await return_cities();
      return cities.map((item) => item.toString()).toList();
    } catch (e) {
      // 파일 읽기 실패 시 예외 처리
      print("An error occurred: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: Text('도시를 선택해주세요.', style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 5,
              bottom: 5,
              left:20,
              right: 20,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // 검색 바 배경색
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // 그림자 색상
                    spreadRadius: 2, // 그림자 확산 범위
                    blurRadius: 4, // 그림자 블러 정도
                    offset: Offset(0, -2), // 수평, 수직 방향 그림자 오프셋
                  ),
                ],
                borderRadius: BorderRadius.circular(30), // 둥근 모서리 설정
              ),
              child: TextField(
                onChanged: (value) {
                  print(value);
                  filterSearchResults(value);

                  setState(() {

                  });
                },
                controller: searchController,
                style: TextStyle(fontSize:20.0),
                decoration: InputDecoration(
                  // contentPadding: EdgeInsets.symmetric(vertical:7.0), // 세로 방향 패딩 조절
                  // labelText: "여기서 검색",
                  hintText: "여기서 검색",
                  prefixIcon: ImageIcon(
                    AssetImage("assets/icon_addSearch.png"),
                    // AssetImage를 사용하여 아이콘 이미지 지정
                    size: 25.0, // 아이콘 크기 설정
                    color: Colors.green, // 아이콘 색상 설정
                  ),
                  border: InputBorder.none, // 외곽선 제거
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: citiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        height:60, // 여기에서 원하는 높이로 설정
                        child: Card(
                          elevation: 1, // 카드 그림자 깊이
                          color: Colors.white, // Card의 배경색을 투명하게 설정
                          surfaceTintColor: Colors.transparent,
                          margin: EdgeInsets.fromLTRB(20,2,20,2), // 카드 주변 여백
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5), // 카드 모서리 둥글기
                          ),
                          child: SizedBox(
                            height: 60, // ListTile의 높이를 설정
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center, // 수직 방향 중앙 정렬
                              children: [
                                ListTile(
                                  title: Text(
                                    filteredCities[index].toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      // fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context, filteredCities[index]);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        // return ListTile(
                        //   title: Text(filteredCities[index].toString()),
                        //   onTap: () {
                        //     Navigator.pop(context, filteredCities[index]);
                        //   },
                        // );
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
          ),
        ],
      ),
    );
  }
}

// class AddCity extends StatelessWidget {
//
//
//   Future<List<dynamic>> readCitiesFile() async {
//     try {
//
//       var cities = await return_cities();
//       cities.map((item) => item.toString()).toList();
//
//       return cities;
//     } catch (e) {
//       // 파일 읽기 실패 시 예외 처리
//       print("An error occurred: $e");
//       return [];
//     }
//   }
//
//   // final String country;
//   //
//   // AddCity({required this.country});
//   //
//   // Future<List<String>> loadCities() async {
//   //   // JSON 파일을 읽고 파싱합니다.
//   //   String jsonString = await rootBundle.loadString('assets/countries.json');
//   //   Map<String, dynamic> jsonMap = json.decode(jsonString);
//   //   return List<String>.from(jsonMap[country]);
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     final String city;
//     // 이 예시에서는 도시 목록을 하드코딩했습니다. 실제 앱에서는 선택한 국가에 따라 이 데이터를 서버에서 가져오거나 로컬 데이터베이스에서 로드할 수 있습니다.
//     // final List<String> cities = ["Herat", "Kabul", "Kandahar"];
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('도시를 선택해주세요.', style: TextStyle(
//             fontSize: 13,
//             color: Colors.black,
//             fontWeight: FontWeight.w800)),
//         leading: IconButton(
//           icon: Icon(Icons.close),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: FutureBuilder<List<dynamic>>(
//         future: readCitiesFile(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasData) {
//             var cities = snapshot.data!;
//             return ListView.builder(
//               itemCount: cities.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(cities[index].toString()),
//                   onTap: () {
//                     Navigator.pop(context, cities[index]); // 선택된 도시 이름을 반환
//                   },
//                 );
//               },
//             );
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             return Center(child: Text('도시 목록을 불러올 수 없습니다.'));
//           }
//         },
//       ),
//     );
//   }
// }