import 'package:flutter/material.dart';
import 'package:travel_mad_camp/functional.dart';
import 'dart:convert';

const String apiUrl = "http://172.10.7.33";

class Tab1 extends StatefulWidget {
  @override
  Tab1State createState() => Tab1State();
}

class Tab1State extends State<Tab1> {
  List<dynamic> posts = [];

  void initState() {
    Future.microtask(() async {
      // 여기에 비동기 작업을 넣습니다.
      await setting();
    });
  }


  Future<void> setting() async {
    posts = await fetchAllPosts();

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travelers',
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: '검색',
                  hintText: '검색',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: posts.length, // 여기서는 임의로 10개의 목록 아이템을 생성합니다.
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    String userImage = "$apiUrl/profile_photo/${post['user_index']}.jpg";
                    String postImage = "$apiUrl/post_photo/${post['post_index']}.jpg";
                    return PostCard(userName: post['user_name'] ?? '',
                      userImage: userImage,
                      postImage: postImage,
                      date: post['date'],
                      tags: post['hash_tags'] ?? '',
                      post_index: post['post_index'],
                      city: post['city'],);
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String userName;
  final String userImage;
  final String postImage;
  final String date;
  final String tags;
  final int post_index;
  final String city;

  PostCard({
    required this.userName,
    required this.userImage,
    required this.postImage,
    required this.date,
    required this.tags,
    required this.post_index,
    required this. city,
  });

  String getDuration(String dateRange) {
    final dates = dateRange.split('~');
    final startDate = DateTime.parse(dates[0]);
    final endDate = DateTime.parse(dates[1]);
    final duration = endDate.difference(startDate).inDays + 1; // +1 to include the end date
    return "${duration}일";
  }

  String encodeToUtf8(String input) {
    List<int> utf8Bytes = utf8.encode(input);
    String utf8String = utf8Bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return utf8String;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // 카드 내부 콘텐츠가 경계를 벗어나지 않게 함
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // 카드 모서리를 둥글게 함
      ),
      child: Column(
        children: <Widget>[
      Container(
      color: Colors.green, // Change this color to match your specific color
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Adjust the padding as needed
              child:Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.location_on, // This icon should match the one in your image
                    color: Colors.white,
                    size: 24, // Adjust the size as needed
                  ),
                  SizedBox(width: 10), // Spacing between the icon and the text
                  Text(
                    "${city}, ${getDuration(date)}", // Replace with the actual text you want
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16, // Adjust the font size as needed
                      fontWeight: FontWeight.bold, // Adjust the font weight as needed
                    ),
                  ),
                ],
              ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(userImage, scale: 1.0)

            ),
            title: Text(userName ?? ''), // 사용자 이름
            subtitle: Text(date), // 날짜
          ),
          Image.network(postImage ?? ''), // 메인 이미지
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              tags, // 해시태그
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.favorite_border),
                color: Colors.red,
                onPressed: () {
                  // 좋아요 버튼 클릭 시 수행할 동작
                },
              ),
              Text(
                '좋아요', // 좋아요 텍스트
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
