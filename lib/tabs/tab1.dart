import 'package:flutter/material.dart';

class Tab1 extends StatefulWidget {
  @override
  Tab1State createState() => Tab1State();
}

class Tab1State extends State<Tab1> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travelers',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Travelers'),
        ),
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
                itemCount: 10, // 여기서는 임의로 10개의 목록 아이템을 생성합니다.
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      children: <Widget>[
                        Image.network('여기에 이미지 URL을 넣습니다'),
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text('이지연, 3월'),
                          subtitle: Text('#도쿄'),
                          trailing: Icon(Icons.favorite_border),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}