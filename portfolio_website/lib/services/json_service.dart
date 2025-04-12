import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';

class JsonService {
  static Future<Map<String, dynamic>> loadJson(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      return jsonDecode(jsonString);
    } catch (e) {
      log('Error loading JSON from $path: $e');
      return {};
    }
  }
}