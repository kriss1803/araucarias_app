import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/usuario.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000';

  Future<Map<String, dynamic>> login(
    String correo,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'correo': correo,
          'password': password,
        }),
      );

      print('STATUS: ${response.statusCode}');
      print('RESPUESTA: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'El servidor devolvió una respuesta vacía',
        };
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        return {
          'success': false,
          'message': 'La respuesta del servidor no tiene un formato válido',
        };
      }

      if (response.statusCode == 200) {
        if (data['usuario'] == null) {
          return {
            'success': false,
            'message': 'El servidor no devolvió los datos del usuario',
          };
        }

        if (data['token'] == null) {
          return {
            'success': false,
            'message': 'El servidor no devolvió el token',
          };
        }

        return {
          'success': true,
          'usuario': Usuario.fromJson(
            Map<String, dynamic>.from(data['usuario']),
          ),
          'token': data['token'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ??
            data['mensaje'] ??
            'Credenciales incorrectas',
      };
    } catch (e) {
      print('ERROR LOGIN: $e');

      return {
        'success': false,
        'message': 'No se pudo conectar con el servidor: $e',
      };
    }
  }
}