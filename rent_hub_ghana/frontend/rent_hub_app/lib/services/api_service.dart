import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../main.dart';

class ApiService {
  ApiService({String? baseUrl, this.token})
    : baseUrl = baseUrl ?? _defaultBaseUrl;
  final String baseUrl;
  final String? token;

  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  static String get _defaultBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.246.240.158:5000/api';
    }
    return 'http://127.0.0.1:5000/api';
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Token $token',
  };

  Future<List<Property>> fetchListings({
    String search = '',
    String? propertyType,
    int? bedrooms,
    double? maxPrice,
  }) async {
    final parameters = <String, String>{
      if (search.isNotEmpty) 'search': search,
      if (bedrooms != null) 'bedrooms_gte': '$bedrooms',
      if (maxPrice != null) 'max_price': '$maxPrice',
    };
    if (propertyType != null) {
      parameters['property_type'] = propertyType;
    }
    final uri = Uri.parse(
      '$baseUrl/listings/',
    ).replace(queryParameters: parameters.isEmpty ? null : parameters);
    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) throw Exception('Unable to load listings');
    final body = jsonDecode(response.body);
    final results = body is Map ? body['results'] as List? : body as List;
    return (results ?? [])
        .map((json) => Property.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Property>> fetchMyListings() async {
    final response = await http
        .get(Uri.parse('$baseUrl/listings/?mine=1'), headers: _headers)
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw Exception('Unable to load your listings');
    }
    final body = jsonDecode(response.body);
    final results = body is Map ? body['results'] as List? : body as List;
    return (results ?? [])
        .map((json) => Property.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: _headers,
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Invalid username or password');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    late final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/auth/register/'),
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));
    } on Exception {
      throw Exception(
        'Could not reach Rent Hub. Make sure the backend is running.',
      );
    }
    if (response.statusCode != 201) {
      final body = jsonDecode(response.body);
      final message = body is Map ? body.values.first : null;
      throw Exception(message?.toString() ?? 'Unable to create account');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> requestSignupConfirmation(String email) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/signup-confirm/request/'),
          headers: _headers,
          body: jsonEncode({'email': email.trim()}),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final message = body is Map ? body.values.first : null;
      throw Exception(message?.toString() ?? 'Unable to send confirmation email');
    }
  }

  Future<void> verifySignupConfirmation({
    required String email,
    required String code,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/signup-confirm/verify/'),
          headers: _headers,
          body: jsonEncode({'email': email.trim(), 'code': code.trim()}),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final message = body is Map ? body.values.first : null;
      throw Exception(message?.toString() ?? 'Invalid signup confirmation code');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    final response = await http.get(
      Uri.parse('$baseUrl/favorites/'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Unable to load saved homes');
    }
    final body = jsonDecode(response.body);
    final values = body is Map ? body['results'] as List : body as List;
    return values.cast<Map<String, dynamic>>();
  }

  Future<void> saveFavorite(int listingId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites/'),
      headers: _headers,
      body: jsonEncode({'listing': listingId}),
    );
    if (response.statusCode != 201 && response.statusCode != 400) {
      throw Exception('Unable to save home');
    }
  }

  Future<void> removeFavorite(int favoriteId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/favorites/$favoriteId/'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Unable to remove saved home');
    }
  }

  Future<void> sendInquiry(int listingId, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inquiries/'),
      headers: _headers,
      body: jsonEncode({'listing': listingId, 'message': message}),
    );
    if (response.statusCode != 201) {
      throw Exception('Unable to send inquiry');
    }
  }

  Future<Property> createListing(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/listings/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Unable to publish property');
    }
    return Property.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Property> updateListing(int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/listings/$id/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Unable to update property');
    }
    return Property.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteListing(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/listings/$id/'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Unable to delete property');
    }
  }

  Future<List<Map<String, dynamic>>> fetchInquiries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/inquiries/'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Unable to load inquiries');
    }
    final body = jsonDecode(response.body);
    final values = body is Map ? body['results'] as List : body as List;
    return values.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Unable to load notifications');
    }
    final body = jsonDecode(response.body);
    final values = body is Map ? body['results'] as List : body as List;
    return values.cast<Map<String, dynamic>>();
  }

  Future<void> requestPasswordReset(String email) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/password-reset/request/'),
          headers: _headers,
          body: jsonEncode({'email': email.trim()}),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final message = body is Map ? body.values.first : null;
      throw Exception(message?.toString() ?? 'Unable to request a reset code');
    }
  }

  Future<void> verifyPasswordReset(String email, String code) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/password-reset/verify/'),
          headers: _headers,
          body: jsonEncode({'email': email.trim(), 'code': code.trim()}),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final message = body is Map ? body.values.first : null;
      throw Exception(message?.toString() ?? 'Invalid reset code');
    }
  }

  Future<String> fetchRecoveryQuestion({
    String email = '',
    required String username,
  }) async {
    final payload = <String, dynamic>{'username': username.trim()};
    if (email.trim().isNotEmpty) payload['email'] = email.trim();

    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/password-reset/question/'),
          headers: _headers,
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final message = body is Map ? body.values.first : null;
      throw Exception(message?.toString() ?? 'Unable to load your recovery question');
    }

    final body = jsonDecode(response.body);
    if (body is Map) {
      final question = body['question'] ?? body['recovery_question'];
      if (question is String && question.trim().isNotEmpty) {
        return question.trim();
      }
      throw Exception('No recovery question is set for this account.');
    }

    if (body is String && body.trim().isNotEmpty) {
      return body.trim();
    }

    throw Exception('No recovery question is set for this account.');
  }

  Future<void> verifyRecoveryAnswer({
    String email = '',
    String username = '',
    required String question,
    required String answer,
  }) async {
    final payload = <String, dynamic>{
      'question': question.trim(),
      'answer': answer.trim(),
    };
    if (username.trim().isNotEmpty) {
      payload['username'] = username.trim();
    }
    if (email.trim().isNotEmpty) {
      payload['email'] = email.trim();
    }

    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/password-reset/verify-recovery/'),
          headers: _headers,
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final message = body is Map ? body.values.first : null;
      throw Exception(message?.toString() ?? 'Incorrect recovery answer');
    }
  }

  Future<void> confirmPasswordReset({
    String email = '',
    String username = '',
    String code = '',
    required String password,
    bool verifiedRecovery = false,
  }) async {
    final payload = <String, dynamic>{
      'password': password,
      if (verifiedRecovery) 'verified_recovery': true,
    };
    if (email.trim().isNotEmpty) payload['email'] = email.trim();
    if (username.trim().isNotEmpty) payload['username'] = username.trim();
    if (code.trim().isNotEmpty) payload['code'] = code.trim();

    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/password-reset/confirm/'),
          headers: _headers,
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final message = body is Map ? body.values.first : null;
      throw Exception(message?.toString() ?? 'Unable to update password');
    }
  }

  Future<Map<String, dynamic>> updateCurrentUser(Map<String, dynamic> data) async {
    final response = await http
        .patch(
          Uri.parse('$baseUrl/auth/me/'),
          headers: _headers,
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final message = body is Map ? body.values.first : null;
      throw Exception(message?.toString() ?? 'Unable to update account');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
