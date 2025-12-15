import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<void> recognizeSneaker() async {
  const String apiUrl = 'https://your-api-endpoint.com/recognize';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer YOUR_TOKEN', // if needed
      },
      body: jsonEncode({"source": "scan_button"}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('API success: $data');
    } else {
      debugPrint('API error: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Request failed: $e');
  }
}
