import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ImagePickerPage extends StatefulWidget {
  @override
  _ImagePickerPageState createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _detectedText;

  // 이미지 선택 및 반환
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes(); // Uint8List 형식으로 읽기
      setState(() {
        _imageBytes = bytes;
      });

      // 이미지 선택 후 텍스트 분석
      await _detectText(bytes);
    }
  }

  // Google Cloud Vision API를 사용하여 텍스트 감지
  Future<void> _detectText(Uint8List imageBytes) async {
    final apiUrl = 'https://vision.googleapis.com/v1/images:annotate?key=AIzaSyB9_lGEsKJk8MtYSBM4ZePLsvKGd05lbPI'; // API 키를 수정하세요.
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
        setState(() {
          _detectedText = textAnnotations[0]['description'];
        });
      } else {
        setState(() {
          _detectedText = 'No text detected.';
        });
      }
    } else {
      setState(() {
        _detectedText = 'Error: ${response.statusCode} ${response.body}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("이미지 선택")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 이미지 미리보기
            _imageBytes != null
                ? Image.memory(
              _imageBytes!,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            )
                : Text("이미지가 선택되지 않았습니다."),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("이미지 선택"),
            ),
            SizedBox(height: 20),
            // 분석 결과 출력
            if (_detectedText != null) ...[
              Text("감지된 텍스트:"),
              SizedBox(height: 10),
              Text(_detectedText!),
            ],
          ],
        ),
      ),
    );
  }
}
