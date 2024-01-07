import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


// API의 URL. 실제 URL로 대체해야 합니다.
const String apiUrl = "http://172.10.7.33";

// 가입한 유저인지 True, False 반환해주는 함수
Future<dynamic> find_user(String access_token) async {
  final response = await http.get(Uri.parse('$apiUrl/find_user/?access_token=$access_token'));

  if (response.statusCode == 200) {
    // 요청이 성공적이면, 서버의 응답을 파싱합니다.
    return json.decode(response.body);
  } else {
    // 서버가 예상과 다른 응답을 보냈을 때 처리
    throw Exception('Failed to load data from API');
  }
}

Future<void> saveUserId(int userId) async {
  print(1);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  print("2");
  await prefs.setInt('user_id', userId);

  print("save User id with shared preferences");
}

Future<int?> getUserId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // 'user_id' 키에 해당하는 값을 불러옵니다. 값이 없으면 null을 반환합니다.
  return prefs.getInt('user_id');
}

// 최초 포스트 올리는 함수
void init_post(String city, String start_day, String end_day, int user_id) async {
  await http.get(Uri.parse('$apiUrl/init_post/?city=$city&start_day=$start_day&end_day=$end_day&user_id=$user_id'));
  // 여기서 응답을 기다리거나 처리할 필요가 없습니다.
}


// 도시, lat, lng 리턴 함수
Future<dynamic> find_city(String city) async {
  final response = await http.get(Uri.parse('$apiUrl/find_city/?city=$city'));

  if (response.statusCode == 200) {
    // 요청이 성공적이면, 서버의 응답을 파싱합니다.
    return json.decode(response.body);
  } else {
    // 서버가 예상과 다른 응답을 보냈을 때 처리
    throw Exception('Failed to load data from API');
  }
}

// 호텔 목록(lat, lng) 리턴 함수
Future<dynamic> find_hotel(double latitude, double longitude, String keyword) async {
  final response = await http.get(Uri.parse('$apiUrl/search_hotel/?latitude=$latitude&longitude=$longitude&keyword=$keyword'));

  if (response.statusCode == 200) {
    // 요청이 성공적이면, 서버의 응답을 파싱합니다.
    return json.decode(response.body);
  } else {
    // 서버가 예상과 다른 응답을 보냈을 때 처리
    throw Exception('Failed to load data from API');
  }
}

// 도시, lat, lng 리턴 함수
Future<dynamic> find_place(double latitude, double longitude, String keyword) async {
  final response = await http.get(Uri.parse('$apiUrl/search_place/?latitude=$latitude&longitude=$longitude&keyword=$keyword'));

  if (response.statusCode == 200) {
    // 요청이 성공적이면, 서버의 응답을 파싱합니다.
    return json.decode(response.body);
  } else {
    // 서버가 예상과 다른 응답을 보냈을 때 처리
    throw Exception('Failed to load data from API');
  }
}

Future<List<dynamic>> return_cities() async {
  final response = await http.get(Uri.parse('$apiUrl/return_cities'));

  if (response.statusCode == 200) {
    // 요청이 성공적이면, 서버의 응답을 파싱합니다.
    // UTF-8로 디코드한다고 가정합니다.
    var decodedResponse = utf8.decode(response.bodyBytes);
    return json.decode(decodedResponse);
  } else {
    // 서버가 예상과 다른 응답을 보냈을 때 처리
    throw Exception('Failed to load data from API');
  }
}

Future<int> return_user_id(String token) async {
  final getUserId = await http.get(Uri.parse('$apiUrl/get_user_id_by_token?access_token=$token'));
  int user_id = json.decode(getUserId.body);

  return user_id;
}

// 회원가입 메서드
void regist(String nickname, String token, String photo) async {
  // 새로운 유저 토큰값 업데이트 이후 고유 user_id 생성
  await http.get(Uri.parse('$apiUrl/update_new_user?access_token=$token'));

  // 생성된 고유 user_id 받아오기
  final getUserId = await http.get(Uri.parse('$apiUrl/get_user_id_by_token?access_token=$token'));
  int user_id = json.decode(getUserId.body);

  // 닉네임 업데이트
  await http.get(Uri.parse('$apiUrl/update_new_nickname/?user_id=$user_id&nickname=$nickname'));

  // 서버 사진 업로드
  String? file_url = await uploadFile(photo, user_id);

  await http.get(Uri.parse('$apiUrl/update_new_photo/?user_id=$user_id&photoUrl=$file_url'));

}

Future<String> getUserNickname(int? user_id) async {
  final getUserId = await http.get(Uri.parse('$apiUrl/get_user_nickname?user_id=$user_id'));
  String name = json.decode(getUserId.body);

  return name;
}

final String serverUrl = 'http://172.10.7.33';

// 파일 업로드
Future<String?> uploadFile(String filePath, int user_id) async {
  File file = File(filePath);
  var request = http.MultipartRequest('POST', Uri.parse('$serverUrl/profile_photo/'));
  String newFilename = '$user_id.jpg';
  request.files.add(await http.MultipartFile.fromPath(
      'file', // Form field for the file.
      file.path, // File path to upload.
      filename: newFilename // 파일 이름을 사용자 ID로 변경합니다.
  ));
  var response = await request.send();
  final resBody = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    // 서버가 JSON 형식으로 파일 경로를 보내주는 경우
    var responseData = json.decode(resBody);
    String? filePath = responseData['file_path']; // 'file_path'는 서버가 리턴하는 경로의 키입니다. 실제 키 이름에 맞게 변경해야 합니다.
    print(filePath);
    return filePath;
  } else {
    // 실패한 경우, 에러 메시지를 출력하고 null을 리턴합니다.
    print('Failed to upload file: $resBody');
    return null;
  }
}
//
// Future<void> uploadFile() async {
//   FilePickerResult? result = await FilePicker.platform.pickFiles();
//
//   if (result != null) {
//     File file = File(result.files.single.path ?? '');
//     var request = http.MultipartRequest('POST', Uri.parse('$serverUrl/profile_photo/'));
//     request.files.add(await http.MultipartFile.fromPath('file', file.path));
//     var res = await request.send();
//     print(res.reasonPhrase);
//   }
// }

// 파일 다운로드
Future<void> downloadProfilePhoto(String filename) async {
  try {
    // URL을 /download/{filename} 형태로 수정합니다.
    var response = await http.get(Uri.parse('$serverUrl/download/$filename'));
    Directory tempDir = await getApplicationDocumentsDirectory();
    String directoryPath = '${tempDir.path}/profile_photo';
    await Directory(directoryPath).create(recursive: true);  // 디렉토리 생성

    String filePath = '$directoryPath/$filename';
    File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);  // 비동기로 파일 쓰기

    print("File downloaded to $filePath");
  } catch (e) {
    print("Error downloading file: $e");
  }
}



void main() async {
  try {
    var data = await find_user('123123');
    print(data);
  } catch (e) {
    print(e);
  }
}