import 'package:flutter/material.dart';
import '../functional.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class Tab3 extends StatefulWidget {
  @override
  Tab3State createState() => Tab3State();
}

class Tab3State extends State<Tab3> {
  int? user_id;
  String? nickName;
  String? imagePath;
  List<Map<String, dynamic>> contents = [{}];
  int my_travel = 0;
  int restTravel = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      // 여기에 비동기 작업을 넣습니다.
      await setting();
    });
  }

  Future<void> setting() async {

    // 아바타 사진 다운로드
    user_id = await getUserId();
    String filename = "$user_id.jpg";

    nickName = await getUserNickname(user_id);

    await downloadProfilePhoto(filename);

    Directory tempDir = await getApplicationDocumentsDirectory();
    String filePath = '${tempDir.path}/profile_photo/$filename';
    imagePath = filePath;


    contents = await fetchPostsByUser(user_id);
    my_travel = contents.length;
    restTravel = await countOngoingTravels(contents);
    setState(() {
    });
  }

  Future<int> countOngoingTravels(List<Map<String, dynamic>> travels) async {
    int ongoingTravels = 0;
    DateTime today = DateTime.now();

    for (var travel in travels) {
      List<String> dates = travel['date']?.split('~') ?? [];
      if (dates.length == 2) {
        DateTime endDate = DateFormat('yyyy-MM-dd').parse(dates[1]);
        if (endDate.isAfter(today)) {
          ongoingTravels++;
        }
      }
    }

    return ongoingTravels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          _buildProfileHeader(),
          _buildPostList(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        SizedBox(height: 20),
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : null,
        ),
        SizedBox(height: 8),
        Text(
          nickName ?? 'happy_travel',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('$my_travel\n내 여행' ?? '0',
                textAlign: TextAlign.center),
            Text('$restTravel\n남은 여행' ?? '0',
                textAlign: TextAlign.center),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPostList() {
    // 여행 게시물 목록을 나타내는 더미 데이터입니다.
    final List<Map<String, dynamic>> posts = contents ?? [{}];

    return Column(
      children: posts.map((post) => _buildPostItem(post)).toList(),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          // 여기에 상세 페이지로 이동하는 코드를 추가하세요.
          // 예시: Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(post: post)));
        },
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(post['city'] ?? ''),
              subtitle: Text(post['date'] ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                children: <Widget>[
                  Icon(Icons.favorite_border), // 좋아요 아이콘
                  SizedBox(width: 8),
                  Text(post['like_count'].toString() ?? '0'), // 좋아요 수, post 맵에 'likes' 키가 있다고 가정합니다.
                  SizedBox(width: 16),
                  Text(post['hash_tags'] ?? '0'), // 해시태그, post 맵에 'hashtag' 키가 있다고 가정합니다.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}