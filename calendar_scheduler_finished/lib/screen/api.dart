import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> detectText(String filePath) async {
  final apiUrl = 'https://vision.googleapis.com/v1/images:annotate?key=AIzaSyB9_lGEsKJk8MtYSBM4ZePLsvKGd05lbPI';
  final imageBytes = await File(filePath).readAsBytes();
  final base64Image = base64Encode(imageBytes);

  final requestPayload = jsonEncode({
    'requests': [
      {
        'image': {
          'content': base64Image,
        },
        'features': [
          {'type': 'TEXT_DETECTION'},
        ],
      },
    ],
  });

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: requestPayload,
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    final textAnnotations = responseData['responses'][0]['textAnnotations'];

    if (textAnnotations.isNotEmpty) {
      print('Detected text: ${textAnnotations[0]['description']}');
    } else {
      print('No text detected.');
    }
  } else {
    print('Error: ${response.statusCode} ${response.body}');
  }
}

void main() {
  detectText('path/to/your/image/file.jpg');
}
