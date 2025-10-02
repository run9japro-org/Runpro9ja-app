import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "https://runpro9ja-backend.onrender.com";


  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/api/auth/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> verifyOtp(String userId, String otp) async {
    final url = Uri.parse("$baseUrl/api/auth/verify-otp");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "code": otp}),
    );

    return jsonDecode(response.body);
  }
}
Future<Map<String, dynamic>> fetchProfile() async {
  final response = await http.get(
    Uri.parse("https://runpro9ja-backend.onrender.com/api/auth/me"),
  );
  return jsonDecode(response.body);
}

