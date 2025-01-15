import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageAnalysis {
  static Future<Map<String, String>> analyzeImage(Uint8List imageBytes) async {
    const String apiUrl = "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyB9_lGEsKJk8MtYSBM4ZePLsvKGd05lbPI";

    try {
      final request = http.MultipartRequest("POST", Uri.parse(apiUrl))
        ..files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: 'image.jpg'));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);

        return {
          "약품 이름": data["name"] ?? "정보 없음",
          "복용 방법": data["usage"] ?? "정보 없음",
          "성분": data["ingredients"] ?? "정보 없음",
          "효과": data["effects"] ?? "정보 없음",
          "부작용": data["side_effects"] ?? "정보 없음",
          "주의사항": data["precautions"] ?? "정보 없음",
        };
      } else {
        return {"오류": "분석 실패: 상태 코드 ${response.statusCode}"};
      }
    } catch (e) {
      return {"오류": "분석 중 오류 발생: $e"};
    }
  }
}
