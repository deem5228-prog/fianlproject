import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/prediction_result.dart';

class ApiService {
  // ── API Base URL ─────────────────────────────────────────────────────────
  // Android Emulator: ใช้ 10.0.2.2 (alias ของ localhost บน host machine)
  // เครื่องจริง (Android/iOS): ต้องเปลี่ยนเป็น IP จริงของ PC ในวง LAN
  //   เช่น 'http://192.168.1.100:8000'
  //   หา IP ของ PC ด้วยคำสั่ง: ipconfig (Windows) หรือ ifconfig (Mac/Linux)
  static String baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:8000'   // Android Emulator
      : 'http://localhost:8000';  // iOS Simulator / เปลี่ยนเป็น LAN IP สำหรับเครื่องจริง

  static Future<PredictionResult> predictImage(File imageFile) async {
    final uri = Uri.parse('$baseUrl/predict-image');
    
    final request = http.MultipartRequest('POST', uri);
    
    final pathLower = imageFile.path.toLowerCase();
    final MediaType contentType;
    if (pathLower.endsWith('.png')) {
      contentType = MediaType('image', 'png');
    } else if (pathLower.endsWith('.webp')) {
      contentType = MediaType('image', 'webp');
    } else if (pathLower.endsWith('.bmp')) {
      contentType = MediaType('image', 'bmp');
    } else {
      contentType = MediaType('image', 'jpeg');
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: contentType,
      ),
    );

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PredictionResult.fromJson(data);
      } else {
        String message = 'Server error: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData.containsKey('detail')) {
            message = errorData['detail'].toString();
          }
        } catch (_) {}
        throw Exception(message);
      }
    } catch (e) {
      final errStr = e.toString();
      if (errStr.startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('Connection error: $e');
    }
  }
}
