import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final String baseUrl = "https://runpro9ja-backend.onrender.com";

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');
      print('🔐 Token retrieved: ${token != null ? '${token.substring(0, 20)}...' : 'NULL'}');
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  // Get user profile from /api/customers/me
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found. Please login again.'
        };
      }

      final url = '$baseUrl/api/customers/me';
      print('🌐 Making API call to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        print('✅ API call successful');
        print('🔑 Response keys: ${userData.keys.toList()}');

        return {
          'success': true,
          'data': userData
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication failed. Please login again.',
          'statusCode': response.statusCode
        };
      } else {
        final errorBody = response.body.isNotEmpty ? json.decode(response.body) : {};
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to load profile: ${response.statusCode}',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      print('❌ Profile fetch error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  // Update user profile via /api/customers/me
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found'
        };
      }

      final url = '$baseUrl/api/customers/me';
      print('🔄 Updating profile at: $url');
      print('📝 Data: $profileData');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(profileData),
      );

      print('📊 Update response status: ${response.statusCode}');
      print('📊 Update response body: ${response.body}');

      if (response.statusCode == 200) {
        final updatedData = json.decode(response.body);
        return {
          'success': true,
          'data': updatedData,
          'message': 'Profile updated successfully'
        };
      } else {
        final errorBody = response.body.isNotEmpty ? json.decode(response.body) : {};
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to update profile: ${response.statusCode}',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      print('❌ Profile update error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  // Upload profile image via /api/customers/upload-profile
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found'
        };
      }

      final url = '$baseUrl/api/customers/upload-profile';
      print('📤 Uploading profile image to: $url');
      print('📁 Image path: ${imageFile.path}');
      print('📁 Image size: ${await imageFile.length()} bytes');

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add image file
      request.files.add(await http.MultipartFile.fromPath(
        'profileImage',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'), // Adjust based on actual image type
      ));

      print('🚀 Sending upload request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📊 Upload response status: ${response.statusCode}');
      print('📊 Upload response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Profile image uploaded successfully'
        };
      } else {
        final errorBody = response.body.isNotEmpty ? json.decode(response.body) : {};
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to upload image: ${response.statusCode}',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      print('❌ Profile image upload error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  // Remove profile image via /api/customers/remove-profile-image
  Future<Map<String, dynamic>> removeProfileImage() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found'
        };
      }

      final url = '$baseUrl/api/customers/remove-profile-image';
      print('🗑️ Removing profile image at: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📊 Remove image response status: ${response.statusCode}');
      print('📊 Remove image response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Profile image removed successfully'
        };
      } else {
        final errorBody = response.body.isNotEmpty ? json.decode(response.body) : {};
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to remove image: ${response.statusCode}',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      print('❌ Remove profile image error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  // Get profile image URL - helper method to construct the image URL
  String getProfileImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) {
      return '';
    }
    return '$baseUrl/api/customers/profile-image/$imageId';
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwtToken');
      await prefs.remove('userData');
      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }
}