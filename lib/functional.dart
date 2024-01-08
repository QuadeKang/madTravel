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
    return jsonDecode(utf8.decode(response.bodyBytes));
  } else {
    // 서버가 예상과 다른 응답을 보냈을 때 처리
    throw Exception('Failed to load data from API');
  }
}

Future<void> saveUserId(int userId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('user_id', userId);

  print("save User id with shared preferences");
}

// 게시글에 좋아요 추가
Future<void> likePost(int user_index, int post_index) async {
  await http.get(Uri.parse('$apiUrl/update_like/$post_index?user_index=$user_index'));
}

Future<int?> getUserId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // 'user_id' 키에 해당하는 값을 불러옵니다. 값이 없으면 null을 반환합니다.
  return prefs.getInt('user_id');
}

// 최초 포스트 올리는 함수
Future<dynamic> init_post(String city, String start_day, String end_day, int user_id) async {
  final response = await http.get(Uri.parse('$apiUrl/init_post/?city=$city&start_day=$start_day&end_day=$end_day&user_id=$user_id'));

  if (response.statusCode == 200) {
    // 요청이 성공적이면, 서버의 응답을 파싱합니다.
    return jsonDecode(utf8.decode(response.bodyBytes));
  } else {
    // 서버가 예상과 다른 응답을 보냈을 때 처리
    throw Exception('Failed to load data from API');
  }

  // 여기서 응답을 기다리거나 처리할 필요가 없습니다.
}

// 호텔 업데이트 함수
Future<void> post_hotel(int post_index, String hotel_name, String start_day, String end_day, double lat, double lng) async {
  await http.get(Uri.parse('$apiUrl/update_hotel/?post_index=$post_index&hotel_name=$hotel_name&start_day=$start_day&end_day=$end_day&lat=$lat&lng=$lng'));
}

Future<void> post_hotels(List<List<dynamic>> hotels, int post_index) async {

  String hotel_name;
  String start_day;
  String end_day;
  double lat;
  double lng;

  for(int i=0; i<hotels.length; i++) {
    start_day = hotels[i][0];
    end_day = hotels[i][1];
    hotel_name = hotels[i][2];
    lat = hotels[i][3];
    lng = hotels[i][4];

    await post_hotel(post_index, hotel_name, start_day, end_day, lat, lng);
  }

}

// 모든 포스트를 가져오는 비동기 함수
Future<List<dynamic>> fetchAllPosts() async {
  final url = Uri.parse('$apiUrl/all_post');
  try {
    // HTTP GET 요청을 보냅니다.
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // 서버로부터 정상적인 응답을 받으면 JSON을 파싱하여 반환합니다.
      // JSON의 최상위 구조가 리스트라고 가정합니다.
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      // 서버로부터 비정상 응답을 받으면 에러 메시지를 반환합니다.
      throw Exception('Failed to load posts');
    }
  } catch (e) {
    // 예외가 발생하면 에러 메시지를 반환합니다.
    throw Exception('An error occurred: $e');
  }
}

Future<Map<String, dynamic>> getSpotDetail(int location_index) async {
  final url = Uri.parse('$apiUrl/get_spot_detail?location_index=$location_index');
  try {
    // HTTP GET 요청을 보냅니다.
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // 서버로부터 정상적인 응답을 받으면 JSON을 파싱하여 반환합니다.
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      // 서버로부터 비정상 응답을 받으면 에러 메시지를 반환합니다.
      return {'message': 'Failed to load spot detail'};
    }
  } catch (e) {
    // 예외가 발생하면 에러 메시지를 반환합니다.
    return {'message': 'An error occurred'};
  }
}

// [[2024-01-28, Guru Harkrishan Park, 28.70967469999999, 77.2018906], [2024-01-31, Parmanand Community Park, 28.7096815, 77.20752499999999]]
Future<void> post_spot(int post_index, String spot_name, String day, double lat, double lng, String vicinity, double stars, int reviews) async {
  await http.get(Uri.parse('$apiUrl/update_spot?post_index=$post_index&day=$day&location_name=$spot_name&lat=$lat&lng=$lng&stars=$stars&reviews=$reviews&vicinity=$vicinity'));
}



Future<void> post_spots(List<List<dynamic>> spots, int post_index) async {

  String day;
  String spot_name;
  double lat;
  double lng;
  String vicinity;
  double stars;
  int reviews;

  for(int i=0; i<spots.length; i++) {
    day = spots[i][0];
    spot_name = spots[i][1];
    lat = spots[i][2];
    lng = spots[i][3];
    vicinity = spots[i][4];
    stars = spots[i][5];
    reviews = spots[i][6];


    await post_spot(post_index, spot_name, day, lat, lng, vicinity, stars, reviews);
  }

}





// 데이터 형식을 정의하는 클래스
class TravelData {
  final int postIndex;
  final List<dynamic> day;

  TravelData({required this.postIndex, required this.day});

  factory TravelData.fromJson(Map<String, dynamic> json) {
    return TravelData(
      postIndex: json['post_index'],
      day: json['day'],
    );
  }
}

// 서버에서 데이터를 가져와 Future<TravelData>로 반환하는 함수
Future<TravelData> fetchTravelData(int postIndex) async {
  final response = await http.get(Uri.parse('http://172.10.7.33:80/return_path?post_index=$postIndex'));

  if (response.statusCode == 200) {
    // 서버로부터 받은 JSON 데이터를 사용하여 TravelData 객체를 생성합니다.
    return TravelData.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  } else {
    // 서버로부터 응답을 받지 못한 경우 예외를 발생시킵니다.
    throw Exception('Failed to load travel data');
  }
}

// 도시, lat, lng 리턴 함수
Future<dynamic> find_city(String city) async {
  final response = await http.get(Uri.parse('$apiUrl/find_city/?city=$city'));

  if (response.statusCode == 200) {
    // 요청이 성공적이면, 서버의 응답을 파싱합니다.
    return jsonDecode(utf8.decode(response.bodyBytes));
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
    return jsonDecode(utf8.decode(response.bodyBytes));
  } else {
    // 서버가 예상과 다른 응답을 보냈을 때 처리
    throw Exception('Failed to load data from API');
  }
}

Future<dynamic> get_hotel_name(int hotel_index) async {
  final response = await http.get(Uri.parse('$apiUrl/get_hotel_name/?hotel_index=$hotel_index'));

  if (response.statusCode == 200) {
    // 요청이 성공적이면, 서버의 응답을 파싱합니다.
    return jsonDecode(utf8.decode(response.bodyBytes));
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
    return jsonDecode(utf8.decode(response.bodyBytes));
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
    return jsonDecode(utf8.decode(response.bodyBytes));
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
Future<void> regist(String nickname, String token, String refresh, String photo) async {
  // 새로운 유저 토큰값 업데이트 이후 고유 user_id 생성
  await http.get(Uri.parse('$apiUrl/update_new_user?access_token=$token&refresh_token=$refresh'));

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

// 프로필 사진 업로드
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


// 프로필 사진 다운로드
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

// 게시글 리스트 받아와서 보여주기
Future<List<Map<String, dynamic>>> fetchPostsByUser(int? userId) async {
  final response = await http.get(
    Uri.parse('http://172.10.7.33/posts/$userId'), // FastAPI 서버 URL
  );

  var decodedResponse = utf8.decode(response.bodyBytes);

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(decodedResponse);
    return List<Map<String, dynamic>>.from(data);
  } else {
    throw Exception('Failed to load posts');
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