import 'package:flutter/material.dart';
import 'tabs/tab2.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

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
              // Google로 시작하기 버튼
              ElevatedButton(
                onPressed: () {
                  // Google 로그인 로직 추가
                  _navigateToMainPage(context);
                },
                child: Text('Google로 시작하기'),
              ),
              SizedBox(height: 20), // 버튼 간 간격 조절
              // 카카오로 시작하기 버튼
              ElevatedButton(
                onPressed: () {
                  // 카카오 로그인 로직 추가
                  _navigateToMainPage(context);
                },
                child: Text('카카오로 시작하기'),
              ),
              SizedBox(height: 20), // 버튼 간 간격 조절
              // 네이버로 시작하기 버튼
              ElevatedButton(

                  onPressed: () => _loginWithNaver(context),

                child: Text('네이버로 시작하기'),
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
      MaterialPageRoute(builder: (context) => Tab2()),
    );
  }
}

void _loginWithNaver(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => NaverLoginWebView(() => _navigateToMainPage(context))),
  );
}

void _navigateToMainPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => Tab2()),
  );
}


class NaverLoginWebView extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  NaverLoginWebView(this.onLoginSuccess);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Naver 로그인"),
      ),
      body: WebView(
        initialUrl: 'http://172.10.7.33/naver_login',
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('http://172.10.7.33/callback_naver')) {
            // 콜백 URL을 처리하는 로직
            onLoginSuccess();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}