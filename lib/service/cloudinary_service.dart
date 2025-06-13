// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName =
      'dmedkjyfe'; // Replace with your Cloudinary cloud name
  final String apiKey =
      '331977879289672'; // Replace with your Cloudinary API key
  final String apiSecret =
      'KVf6_SSmHNz2C8zrzlMuo0Yb9Z8'; // Replace with your Cloudinary API secret

  Future<String> uploadImage(String filePath) async {
    // Ensure the file exists
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }

    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    var request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] =
          'ml_default' // Use your unsigned upload preset here
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        if (jsonResponse['secure_url'] != null) {
          return jsonResponse['secure_url']; // Return the uploaded image URL
        } else {
          throw Exception('Image upload failed with response: $jsonResponse');
        }
      } else {
        throw Exception("Failed to upload image: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error uploading image: $e");
      throw Exception("Error uploading image: $e");
    }
  }
}
