import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';

class ApiService {
  Future<Map<String, dynamic>> login(
    String correo,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${Environment.apiBaseUrl}/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'correo': correo,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['mensaje'] ?? 'Error en el inicio de sesión');
    }

    return data;
  }
}