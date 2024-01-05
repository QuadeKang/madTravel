import 'package:flutter/material.dart';

class AddHotel extends StatelessWidget {
  final String city;

  AddHotel({required this.city});

  @override
  Widget build(BuildContext context) {
    // 호텔 목록 로직 구현 필요

    return Scaffold(
      appBar: AppBar(
        title: Text('$city의 호텔 선택'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // 호텔 목록이 표시되는 UI 구현
    );
  }
}
