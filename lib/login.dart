import 'package:flutter/material.dart';
import 'package:travel_mad_camp/main.dart';
import 'tabs/tab2.dart';
import 'functional.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(LoginPage());
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 로고 - 동그란 원
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue, // 앱 로고 색상
                ),
                child: Icon(
                  Icons.android, // 여기에 앱 로고 아이콘을 지정해주세요
                  size: 60,
                  color: Colors.white, // 앱 로고 아이콘 색상
                ),
              ),
              SizedBox(height: 40), // 로고와 버튼 사이 간격 조절

              SizedBox(height: 20), // 버튼 간 간격 조절
              // 카카오로 시작하기 버튼
              InkWell(
                onTap: () {
                  _loginWithNaver(context);
                },
                child: SizedBox(
                  width: 300,
                  height: 60,
                  child: Ink(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            'http://172.10.7.33/public/images/naver_login.png'),
                        // Replace with your image URL
                        fit: BoxFit.fitWidth,
                      ), // Optional: if you want the image to have rounded corners
                    ),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      // Optional: if you want to add padding inside the button
                      alignment: Alignment.center,
                      // To align the child text or content of the button
                      child: Text(
                        "",
                        // Optional: if you want to have text over the image
                        style: TextStyle(
                          color: Colors.white,
                          // This color will be visible on top of your image
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),

              InkWell(
                onTap: () {
                  // _navigateToMainPage(context);
                  _loginWithKakao(context);
                },
                child: SizedBox(
                  width: 300,
                  height: 60,
                  child: Ink(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            'http://172.10.7.33/public/images/kakao_login.png'),
                        // Replace with your image URL
                        fit: BoxFit.fitWidth,
                      ), // Optional: if you want the image to have rounded corners
                    ),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      // Optional: if you want to add padding inside the button
                      alignment: Alignment.center,
                      // To align the child text or content of the button
                      child: Text(
                        "", // Optional: if you want to have text over the image
                        style: TextStyle(
                          color: Colors.white,
                          // This color will be visible on top of your image
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToMainPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyTabbedApp()),
    );
  }
}

void _loginWithNaver(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) =>
            NaverLoginWebView(() => _navigateToMainPage(context))),
  );
}

void _loginWithKakao(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) =>
            KakaoLoginWebView(() => _navigateToMainPage(context))),
  );
}

void _navigateToMainPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => MyTabbedApp()),
  );
}

class KakaoLoginWebView extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  KakaoLoginWebView(this.onLoginSuccess);

  @override
  _KakaoLoginWebViewState createState() => _KakaoLoginWebViewState();
}

class _KakaoLoginWebViewState extends State<KakaoLoginWebView> {
  late WebViewController _controller; // WebViewController 인스턴스를 선언합니다.
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kakao 로그인"),
      ),
      body: Visibility(
        visible: _isVisible,
        child: WebView(
          initialUrl: 'http://172.10.7.33/kakao_login',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller =
                webViewController; // WebView가 생성될 때 _controller를 초기화합니다.
          },
          onPageFinished: (String url) {
            if (url.startsWith('http://172.10.7.33/callback_kakao')) {
              _controller
                  .runJavascriptReturningResult('document.body.innerText')
                  .then((content) async {
                String? content = await _controller
                    .runJavascriptReturningResult('document.body.innerText');
                if (content != null) {
                  try {
                    String jsonString =
                        content.replaceAll(r'\"', '"').replaceAll(r'\\', r'\');
                    jsonString = jsonString.substring(
                        1, jsonString.length - 1); // 처음과 마지막의 추가 따옴표를 제거합니다.
                    // JSON으로 파싱합니다.
                    Map<String, dynamic> data = json.decode(jsonString);
                    // 'access_token'을 변수에 저장합니다.
                    String accessToken = data['access_token'];
                    String refreshToken = data['refresh_token'];

                    print(accessToken);
                    print(refreshToken);

                    if (accessToken != null) {
                      // 사용자 가입 여부 확인
                      var data = await find_user(accessToken);

                      print(accessToken);
                      print(data);
                      print(data.runtimeType);

                      if (data) {

                        await saveUserId(await return_user_id(accessToken));

                        // 가입된 유저이면 메인 페이지로 이동
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MyTabbedApp()), // Tab2는 메인 페이지 위젯입니다.
                        );
                      } else {
                        // 가입되지 않은 유저이면 다른 페이지로 이동
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegistrationPage(
                                  accessToken: accessToken,
                                  refresh:
                                      refreshToken)), // RegistrationPage는 등록 페이지 위젯입니다.
                        );
                      }
                    }
                    return NavigationDecision.prevent; // 리디렉션을 방지합니다.
                  } catch (e) {
                    // 에러 처리
                    print("Error parsing JSON or accessing token: $e");
                  }
                  return NavigationDecision.navigate; // 다른 URL은 정상적으로 이동합니다.
                }
              }).catchError((error) {});
            }
            setState(() {
            });
            // _isVisible = false;
          },
        ),
      ),
    );
  }
}

class NaverLoginWebView extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  NaverLoginWebView(this.onLoginSuccess);

  @override
  _NaverLoginWebViewState createState() => _NaverLoginWebViewState();
}

class _NaverLoginWebViewState extends State<NaverLoginWebView> {
  late WebViewController _controller; // WebViewController 인스턴스를 선언합니다.
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Naver 로그인"),
      ),
      body: Visibility(
        visible: _isVisible,
        child: WebView(
          initialUrl: 'http://172.10.7.33/naver_login',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller =
                webViewController; // WebView가 생성될 때 _controller를 초기화합니다.
          },
          onPageFinished: (String url) {
            if (url.startsWith('http://172.10.7.33/callback_naver')) {
              _controller
                  .runJavascriptReturningResult('document.body.innerText')
                  .then((content) async {
                String? content = await _controller
                    .runJavascriptReturningResult('document.body.innerText');
                if (content != null) {
                  try {
                    String jsonString =
                        content.replaceAll(r'\"', '"').replaceAll(r'\\', r'\');
                    jsonString = jsonString.substring(
                        1, jsonString.length - 1); // 처음과 마지막의 추가 따옴표를 제거합니다.
                    // JSON으로 파싱합니다.
                    Map<String, dynamic> data = json.decode(jsonString);
                    // 'access_token'을 변수에 저장합니다.
                    String accessToken = data['access_token'];
                    String refreshToken = data['refresh_token'];

                    if (accessToken != null) {
                      // 사용자 가입 여부 확인
                      var data = await find_user(accessToken);

                      print(accessToken);
                      print(data);
                      print(data.runtimeType);

                      if (data) {
                        await saveUserId(await return_user_id(accessToken));

                        print("run");
                        // 가입된 유저이면 메인 페이지로 이동
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MyTabbedApp()), // Tab2는 메인 페이지 위젯입니다.
                        );
                      } else {
                        // 가입되지 않은 유저이면 다른 페이지로 이동
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegistrationPage(
                                  accessToken: accessToken,
                                  refresh:
                                      refreshToken)), // RegistrationPage는 등록 페이지 위젯입니다.
                        );
                      }
                    }
                    return NavigationDecision.prevent; // 리디렉션을 방지합니다.
                  } catch (e) {
                    // 에러 처리
                    print("Error parsing JSON or accessing token: $e");
                  }
                  return NavigationDecision.navigate; // 다른 URL은 정상적으로 이동합니다.
                }
              }).catchError((error) {});
            }
            setState(() {
              // _isVisible = false;
            });
          },
        ),
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  final String accessToken; // access_token을 위한 변수를 추가합니다.
  final String refresh;

  // 생성자에서 access_token을 받습니다.
  RegistrationPage({Key? key, required this.accessToken, required this.refresh})
      : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  final TextEditingController _nicknameController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    _imageFile = pickedFile;
    setState(() {});
  }

  void _registerAndNavigate() async {
    await regist(_nicknameController.text, widget.accessToken, widget.refresh,
        _imageFile!.path);

    await saveUserId(await return_user_id(widget.accessToken));

    // 회원가입 후 Main 페이지로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyTabbedApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50,),
                Container(
                  width: 200,
                  height: 200,
                  child: _imageFile == null
                      ? AspectRatio(
                          aspectRatio: 1 / 1, // 1:1 비율
                          child: Image.network(
                            'http://172.10.7.33/public/profile/select_profile.png',
                            fit: BoxFit.cover, // 이미지가 컨테이너를 채우도록 조절
                          ),
                        )
                      : AspectRatio(
                          aspectRatio: 1 / 1, // 1:1 비율
                          child: Image.file(
                            File(_imageFile!.path),
                            fit: BoxFit.cover, // 이미지가 컨테이너를 채우도록 조절
                          ),
                        ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: TextField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      labelText: '닉네임',
                      labelStyle: TextStyle(color: Colors.green),
                      // 레이블 스타일 변경
                      prefixIcon: Icon(Icons.person),
                      // 왼쪽에 아이콘 추가
                      enabledBorder: OutlineInputBorder(
                        // 활성화 상태의 테두리 스타일
                        borderSide: BorderSide(color: Colors.green, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        // 포커스 상태의 테두리 스타일
                        borderSide: BorderSide(color: Colors.green, width: 2.0),
                      ),
                      border: OutlineInputBorder(),
                      // 기본 테두리 스타일
                      fillColor: Colors.white,
                      // 배경색
                      filled: true, // 배경색 채우기 활성화
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(250, 30),
                    primary: Color(0xFF07923C), // background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3), // border radius
                    ),
                  ),
                  onPressed: _pickImage,
                  child: Text(
                    '프로필사진 선택하기',
                    style: TextStyle(
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(250, 30),
                    primary: Color(0xFF07923C), // background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3), // border radius
                    ),
                  ),
                  onPressed: _registerAndNavigate,
                  child: Text(
                    '가입하고 시작하기',
                    style: TextStyle(
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
