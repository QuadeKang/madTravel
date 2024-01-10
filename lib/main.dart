import 'package:flutter/material.dart';
import 'tabs/tab1.dart';
import 'tabs/tab2.dart';
import 'tabs/tab3.dart';
import 'login.dart';
import 'colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale('ko', 'KR'), // 한국어로 설정
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        fontFamily: 'Pretendard',
      ),
    );
  }
}

class MyTabbedApp extends StatefulWidget {
  @override
  _MyTabbedAppState createState() => _MyTabbedAppState();
}

class _Tab1 extends StatefulWidget {
  @override
  Tab1State createState() => Tab1State();
}

class _Tab2 extends StatefulWidget {
  @override
  Tab2State createState() => Tab2State();
}

class _Tab3 extends StatefulWidget {
  @override
  Tab3State createState() => Tab3State();
}

class _MyTabbedAppState extends State<MyTabbedApp>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: TravelAppBar(),
      body: TabBarView(
        children: <Widget>[Tab1(), Tab2(), Tab3()],
        controller: controller,
      ),
      bottomNavigationBar: Material(
        color: Colors.white,
        child: TabBar(
          tabs: <Tab>[
            Tab(text: 'Browse'),
            Tab(text: 'Plan'),
            Tab(text: 'My Page'),
          ],
          controller: controller,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.gray,
          indicatorColor: AppColors.primaryBlue,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class TravelAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      title: Text('Travel',style: TextStyle(
        color: AppColors.primaryBlue,
        fontSize: 30,
        fontWeight: FontWeight.w700,
      ),),
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // AppBar의 기본 높이
}

class SubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget titleRow; // Row 위젯을 매개변수로 받음

  SubAppBar({required this.titleRow}); // 생성자를 통해 Row 위젯을 초기화

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      scrolledUnderElevation: 0.0,
      title: titleRow, // AppBar의 title로 Row 위젯 사용
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 20,
        color: Colors.black,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50.0); // AppBar의 높이
}
// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String labelText;
//   final TextInputType keyboardType; // 추가된 변수
//   final bool showError; // 오류 상태를 표시하는 변수 추가
//
//   const CustomTextField({
//     Key? key,
//     required this.controller,
//     required this.labelText,
//     this.keyboardType = TextInputType.text, // 기본값 설정
//     this.showError = false, // 기본값은 오류가 없음을 의미
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       cursorColor: AppColors.primaryBlue,
//       controller: controller,
//       keyboardType: keyboardType, // keyboardType을 TextField에 적용
//       decoration: InputDecoration(
//         labelText: labelText,
//         labelStyle: const TextStyle(
//           color: Colors.black87,
//         ),
//         border: const UnderlineInputBorder(),
//         enabledBorder: UnderlineInputBorder(
//           borderSide: BorderSide(color: showError ? Colors.red : Colors.black87),
//         ),
//         focusedBorder: UnderlineInputBorder(
//           borderSide: BorderSide(color: showError ? Colors.red : AppColors.primaryBlue, width: 2.0),
//         ),
//       ),
//       style: const TextStyle(
//         color: Colors.black,
//         fontFamily: 'Pretendard Variable',
//         fontSize: 16,
//         fontWeight: FontWeight.w400,
//         letterSpacing: -0.408,
//         height: 1.41667,
//       ),
//     );
//   }
// }
//
// // String formatPhoneNumber(String rawNumber) {
// //   // 전화번호가 11자리인 경우에 대한 예시입니다.
// //   if (rawNumber.length == 11) {
// //     return '${rawNumber.substring(0, 3)}-${rawNumber.substring(3, 7)}-${rawNumber.substring(7, 11)}';
// //   }
// //   // 전화번호 형식이 올바르지 않은 경우 원본 번호를 반환
// //   return rawNumber;
// // }