import 'package:flutter/material.dart';
import 'package:travel_mad_camp/functional.dart';
import 'dart:convert';
import 'tab2_addition/Plan.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

const String apiUrl = "http://172.10.7.33";
int? user_id;

class Tab1 extends StatefulWidget {
  @override
  Tab1State createState() => Tab1State();
}

class Tab1State extends State<Tab1> {
  List<dynamic> posts = [];
  bool isLoading = true;
  String? userName;

  void initState() {
    Future.microtask(() async {
      // 여기에 비동기 작업을 넣습니다.
      await setting();
    });
  }

  Future<void> setting() async {
    posts = await fetchAllPosts();

    // 아바타 사진 다운로드
    user_id = await getUserId();
    String filename = "$user_id.jpg";

    userName = await getUserNickname(user_id);

    await downloadProfilePhoto(filename);

    Directory tempDir = await getApplicationDocumentsDirectory();
    String filePath = '${tempDir.path}/profile_photo/$filename';

    isLoading = false;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travelers',
      home: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Travelers',
            style: TextStyle(
              color: Color(0xFF000000),
              // Hex color for black
              fontFamily: 'Inter',
              // Make sure 'Inter' font is added to your pubspec.yaml
              fontSize: 40.0,
              // Font size
              fontWeight: FontWeight.w700, // Font weight
              // Flutter automatically sets line height to a normal value for you.
              // If you want to set a specific line height, you can use height property in TextStyle.
            ),
          ), // Set the title of the AppBar
          backgroundColor: Colors.white,
          // You can set the background color of the AppBar
          // Add more AppBar properties if needed
        ),
        body: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                // Background color as white
                // borderRadius: BorderRadius.circular(3),
                // Border radius as 3 pixels
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "추천 여행",
                    style: TextStyle(
                      color: Color(0xFF000000),
                      // Hex color for black
                      fontFamily: 'Inter',
                      // Make sure 'Inter' font is added to your pubspec.yaml
                      fontSize: 20.0,
                      // Font size
                      fontWeight: FontWeight.w700, // Font weight
                      // Flutter automatically sets line height to a normal value for you.
                      // If you want to set a specific line height, you can use height property in TextStyle.
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                // Vertical padding 4, horizontal padding 10
                child: ListView.builder(
                  itemCount: posts.length, // The number of items in the list
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    String userImage =
                        "$apiUrl/public/profile/${post['user_index']}.jpg";
                    String postImage =
                        "$apiUrl/public/posting/${post['post_index']}.jpg";
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Plan(post_index: post['post_index'],)));
                      // 여기에 탭했을 때 실행할 동작을 작성하세요.
                      // 예: Navigator.push를 사용하여 상세 페이지로 이동
                    },
                      child: PostCard(
                        userName: (post['user_name']?.isEmpty ?? true
                            ? '방랑자'
                            : post['user_name']),
                        userImage: userImage,
                        postImage: postImage,
                        date: post['date'],
                        tags: post['hash_tags'] ?? '',
                        post_index: post['post_index'],
                        city: post['city'],
                        user_id: post['user_index'],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String userName;
  final String userImage;
  final String postImage;
  final String date;
  final String tags;
  final int post_index;
  final String city;
  final int user_id;

  PostCard({
    required this.userName,
    required this.userImage,
    required this.postImage,
    required this.date,
    required this.tags,
    required this.post_index,
    required this.city,
    required this.user_id,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late String _userImage;
  Icon likeIcon = Icon(Icons.favorite_border);
  late bool isLike;
  bool isLikeLoaded = true;

  String getDuration(String dateRange) {
    final dates = dateRange.split('~');
    final startDate = DateTime.parse(dates[0]);
    final endDate = DateTime.parse(dates[1]);
    final duration =
        endDate.difference(startDate).inDays + 1; // +1 to include the end date
    return "${duration}일";
  }

  String encodeToUtf8(String input) {
    List<int> utf8Bytes = utf8.encode(input);
    String utf8String =
        utf8Bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return utf8String;
  }

  @override
  void initState() {
    super.initState();
    _userImage = widget.userImage;
    Future.microtask(() async {
      // 여기에 비동기 작업을 넣습니다.
      await getLike();
    });
  }

  Future<void> getLike() async {
    isLike = await checkLike(widget.post_index, user_id!);

    setState(() {
      isLikeLoaded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLikeLoaded
        ? Center()
        : Container(
            decoration: BoxDecoration(
              color: Colors.white, // Background color as white
              borderRadius:
                  BorderRadius.circular(3), // Border radius as 3 pixels
              boxShadow: [
                BoxShadow(
                  color: Colors.grey
                      .withOpacity(0.25), // Shadow color with opacity
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(1, 1), // Shadow position
                ),
              ],
            ),
            child: Card(
              clipBehavior: Clip.antiAlias,
              // Ensure the content doesn't overflow the card's bounds
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3), // Card corner radius
              ),
              child: Column(
                children: <Widget>[
                  Container(
                      color: Color(0xFF07923C),
                      // Change this color to match your specific color
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      // Adjust the padding as needed
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF07923C), // Background color
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(1), // Top left radius
                            topRight: Radius.circular(1), // Top right radius
                            // Bottom left and right radius are 0
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(0.0),
                          // Padding inside the container
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 36,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "${widget.city}, ${getDuration(widget.date)}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  Container(
                    color: Colors.white, // Set the background color to white
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(_userImage),
                        onBackgroundImageError: (_, __) {
                          if (_userImage !=
                              'https://172.10.7.33/public/profile/${widget.user_id}.jpg') {
                            // If the main image fails to load, use an alternative image.
                            setState(() {
                              _userImage =
                                  'http://172.10.7.33/public/images/default_user.png';
                            });
                          }
                        },
                      ),
                      title: Text(
                        widget.userName, // 사용자 이름
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Bold font
                          fontSize: 16.0, // Set your desired font size
                          color: Colors.black, // Text color as black
                        ),
                      ), // 사용자 이름
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 1, // 1:1 aspect ratio
                    child: Image.network(
                      'http://172.10.7.33/public/images/${widget.city}.jpg',
                      fit: BoxFit.cover,
                      // This ensures the image covers the widget area without changing the aspect ratio.
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        // If there's an error loading the image, display a default image.
                        return Image.network(
                          'http://172.10.7.33/public/images/dafault_post_image.jpg',
                          // Provide the path to your local default image asset.
                          fit: BoxFit
                              .cover, // Use BoxFit.cover to cover the area.
                        );
                      },
                    ),
                  ),
                  Container(
                    color: Colors.white, // Set the background color to white
                    child: ButtonBar(
                      alignment: MainAxisAlignment.start,
                      children: [
                        LikeButton(
                          postIndex: widget.post_index,
                          userIndex: widget.user_id,
                          isLiked: isLike,
                        ),
                        Text(
                          widget.tags.isEmpty ? '#여행' : widget.tags,
                          // If tags are empty, display '#여행'
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }
}

class LikeButton extends StatefulWidget {
  final int postIndex;
  final int userIndex;
  final bool isLiked;

  LikeButton(
      {Key? key,
      required this.postIndex,
      required this.userIndex,
      required this.isLiked})
      : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late Icon likeIcon;

  @override
  void initState() {
    super.initState();
    // Set initial icon based on isLiked
    likeIcon =
        widget.isLiked ? Icon(Icons.favorite) : Icon(Icons.favorite_border);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: likeIcon,
      color: Colors.red,
      onPressed: () {
        setState(() {
          // Toggle the icon
          if (likeIcon.icon == Icons.favorite_border) {
            likeIcon = Icon(Icons.favorite);
            addLike(widget.postIndex, user_id!);
          } else {
            likeIcon = Icon(Icons.favorite_border);
            deleteLike(widget.postIndex, user_id!);
          }
        });

        // Perform additional actions based on the postIndex and like status
      },
    );
  }
}
