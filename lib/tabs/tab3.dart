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
  List<Map<String, dynamic>> likedContents = [{}];
  int my_travel = 0;
  int restTravel = 0;
  int _selectedIndex = 0;
  double screenHeight = 0.0;

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
    // user_id = await getUserId();
    user_id = 4;
    String filename = "$user_id.jpg";

    // nickName = await getUserNickname(user_id);

    // await downloadProfilePhoto(filename);
    //
    // Directory tempDir = await getApplicationDocumentsDirectory();
    // String filePath = '${tempDir.path}/profile_photo/$filename';
    // imagePath = filePath;

    contents = await fetchPostsByUser(user_id);
    likedContents = await fetchLikedPost(user_id);

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
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        // Allows the avatar to overlap the stack's bounds
        alignment: Alignment.topCenter,
        // Center items within the stack horizontally
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
              padding: EdgeInsets.only(top: screenHeight * 0.1),
              // Adjust as needed
              height: screenHeight * 0.3,
              // Adjust the height as needed
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(
                      100), // Adjust radius to match your design
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    nickName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 내여행, 남은 여행, 좋아요
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                "${my_travel}",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("내 여행"),
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            children: [
                              Text(
                                "${restTravel}",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("남은 여행"),
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            children: [
                              Text(
                                "${likedContents.length}",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
            top: screenHeight * 0.1 - 30,
            // Half the avatar's diameter to align it with the container edge
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'http://172.10.7.33/public/images/default_user.png'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
    );
  }

  Widget _buildCustomBottomNavigationBar() {
    return Container(
      color: Colors.white, // Set the background color to white
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildTabItem(icon: Icons.menu, index: 0),
              _buildTabItem(icon: Icons.favorite, index: 1),
            ],
          ),
          Container(
            height: screenHeight * 0.47,
            child: _selectedIndex == 0 ? _buildListView1() : _buildListView2(),
          ),
        ],
      ),
    );
  }


  Widget _buildTabItem({required IconData icon, required int index}) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        color: Colors.white, // Set background color to white
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 15,),
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey,
            ),
            SizedBox(height: 4), // Space between icon and underline
            Container(
              height: 2, // Thickness of the underline
              width: 200, // Width of the underline
              color: isSelected
                  ? Colors.black
                  : Colors.transparent, // Underline color or transparent
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildListView1() {
    // ListView for the first tab
    return ListView.builder(
      itemCount: contents.length, // Replace with your data length
      itemBuilder: (context, index) {
        return _buildPostItem(context, contents[index]); // Your item builder
      },
    );
  }

  Widget _buildListView2() {
    // ListView for the second tab
    return ListView.builder(
      itemCount: likedContents.length, // Replace with your data length
      itemBuilder: (context, index) {
        return _buildLikedItem(context, likedContents[index]); // Your item builder
      },
    );
  }
}

Widget _buildPostItem(BuildContext context, Map<String, dynamic> post) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(3.0), // border-radius: 3px
    ),
    color: Colors.white.withOpacity(1.0),
    // background: #FFF
    surfaceTintColor: Colors.transparent,
    elevation: 2.0,
    // box-shadow
    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    child: InkWell(
      onTap: () {
        // 여기에 상세 페이지로 이동하는 코드를 추가하세요.
        // 예시: Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(post: post)));
      },
      child: Row(
        children: [
          SizedBox(
            width: 10,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            // Set border-radius to 5px
            child: Image.network(
              'http://172.10.7.33/public/images/${post['city']}.jpg',
              width: 100, // Set your desired width
              height: 100, // Set your desired height
              fit: BoxFit.cover, // Adjust the fit
            ),
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 8,
                ),
                ListTile(
                  title: Text(
                    post['city'] ?? '',
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    post['date'] ?? '',
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Row(
                    children: <Widget>[
                      Text(post['hash_tags'] ?? '#여행'),
                      // 해시태그, post 맵에 'hashtag' 키가 있다고 가정합니다.
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}

Widget _buildLikedItem(BuildContext context, Map<String, dynamic> post) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(3.0), // border-radius: 3px
    ),
    color: Colors.white.withOpacity(1.0),
    // background: #FFF
    surfaceTintColor: Colors.transparent,
    elevation: 2.0,
    // box-shadow
    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    child: InkWell(
      onTap: () {
        // 여기에 상세 페이지로 이동하는 코드를 추가하세요.
        // 예시: Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(post: post)));
      },
      child: Row(
        children: [
          SizedBox(
            width: 10,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            // Set border-radius to 5px
            child: Image.network(
              'http://172.10.7.33/public/images/${post['city']}.jpg',
              width: 100, // Set your desired width
              height: 100, // Set your desired height
              fit: BoxFit.cover, // Adjust the fit
            ),
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 8,
                ),
                ListTile(
                  title: Text(
                    post['city'] ?? '',
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    post['date'] ?? '',
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Row(
                    children: <Widget>[
                      Text(post['hash_tags'] ?? '#여행'),
                      // 해시태그, post 맵에 'hashtag' 키가 있다고 가정합니다.
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
