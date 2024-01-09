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
  String nickName = '';
  String imagePath = '';
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

    user_id = user_id ?? 0;
    nickName = (nickName.isEmpty) ? 'USER' : nickName;

    setState(() {});
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

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none, // Allows the avatar to overlap the stack's bounds
        alignment: Alignment.topCenter, // Center items within the stack horizontally
        children: [
          // This Container acts as the top background
          Container(
            height: screenHeight * 0.3, // 30% of the screen height
            color: Color(0xFF0D2E0D), // Your chosen color for the background
          ),
          // Positioned white arc background for the avatar and stats
          Positioned(
            top: screenHeight * 0.1, // Adjust as needed for your design
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: screenHeight * 0.1), // Adjust as needed
              height: screenHeight * 0.2, // Adjust the height as needed
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(100), // Adjust radius to match your design
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  Text(nickName),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 내여행, 남은 여행, 좋아요
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text("${my_travel}",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),),
                              Text("내 여행"),
                            ],
                          ),

                          SizedBox(width: 20,),

                          Column(
                            children: [
                              Text("${restTravel}",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),),
                              Text("남은 여행"),
                            ],
                          ),

                          SizedBox(width: 20,),

                          Column(
                            children: [
                              Text("${my_travel}",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),),
                              Text("좋아요"),
                            ],
                          ),
                        ],

                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          // Positioned profile avatar
          Positioned(
            top: screenHeight * 0.1 - 30, // Half the avatar's diameter to align it with the container edge
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('http://172.10.7.33/public/images/default_user.png'),
            ),
          ),
          // Positioned ListView.builder for posts
          Positioned(
            top: screenHeight * 0.7, // Adjust as needed to place the list below the avatar
            left: 0,
            right: 0,
            bottom: 0,
            child: ListView.builder(
              itemCount: contents.length,
              itemBuilder: (context, index) {
                return _buildPostItem(context, contents[index]);
              },
            ),
          ),
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
          backgroundImage:
              imagePath != null ? FileImage(File(imagePath!)) : null,
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
            Text('$my_travel\n내 여행' ?? '0', textAlign: TextAlign.center),
            Text('$restTravel\n남은 여행' ?? '0', textAlign: TextAlign.center),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPostItem(BuildContext context, Map<String, dynamic> post) {
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
                  Icon(Icons.favorite_border),
                  // 좋아요 아이콘
                  SizedBox(width: 8),
                  Text(post['like_count'].toString() ?? '0'),
                  // 좋아요 수, post 맵에 'likes' 키가 있다고 가정합니다.
                  SizedBox(width: 16),
                  Text(post['hash_tags'] ?? '0'),
                  // 해시태그, post 맵에 'hashtag' 키가 있다고 가정합니다.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
