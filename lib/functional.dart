import 'package:http/http.dart' as http;
import 'dart:convert';

// API의 URL. 실제 URL로 대체해야 합니다.
const String apiUrl = "http://172.10.7.33";

// 리턴값을 받아 리턴하는 함수
Future<dynamic> fetchApiData(String endpoint) async {
  final response = await http.get(Uri.parse('$apiUrl/$endpoint'));

  if (response.statusCode == 200) {
    // 요청이 성공적이면, 서버의 응답을 파싱합니다.
    return json.decode(response.body);
  } else {
    // 서버가 예상과 다른 응답을 보냈을 때 처리
    throw Exception('Failed to load data from API');
  }
}

// 리턴값 없이 API 호출만 하는 함수
void callApiWithoutReturn(String endpoint) async {
  await http.get(Uri.parse('$apiUrl/$endpoint'));
  // 여기서 응답을 기다리거나 처리할 필요가 없습니다.
}

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

void main() async {
  try {
    var cityInfo = await find_city("Paris");
    print(cityInfo.runtimeType);
  } catch (e) {
    print(e);
  }
}