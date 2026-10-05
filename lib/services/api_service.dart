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

  Future<Map<String, dynamic>> subirComprobante(
    int pagoId,
    String filePath,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${Environment.apiBaseUrl}/api/pagos/$pagoId/comprobante',
      ),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'comprobante',
        filePath,
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    print('STATUS SUBIR COMPROBANTE: ${response.statusCode}');
    print('RESPUESTA SUBIR COMPROBANTE: $responseBody');
    
    final data = jsonDecode(responseBody);

    if (response.statusCode != 201) {
      throw Exception(
        data['mensaje'] ?? 'Error al subir el comprobante',
      );
    }

    return data;
  }

  Future<Map<String, dynamic>> crearPago({
  required double monto,
  required String metodoPago,
  required int usuarioId,
  required int alicuotaId,
}) async {
  final response = await http.post(
    Uri.parse('${Environment.apiBaseUrl}/api/pagos'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'monto': monto,
      'metodoPago': metodoPago,
      'usuarioId': usuarioId,
      'alicuotaId': alicuotaId,
      'estado': 'PENDIENTE',
    }),
  );

  print('STATUS CREAR PAGO: ${response.statusCode}');
  print('RESPUESTA CREAR PAGO: ${response.body}');

  final data = jsonDecode(response.body);

  if (response.statusCode != 201) {
    throw Exception(
      data['mensaje'] ?? 'Error al crear el pago',
    );
  }

  return data;
}

Future<List<dynamic>> obtenerAlicuotas() async {
  final response = await http.get(
    Uri.parse('${Environment.apiBaseUrl}/api/alicuotas'),
  );

  print('STATUS OBTENER ALICUOTAS: ${response.statusCode}');
  print('RESPUESTA ALICUOTAS: ${response.body}');

  final data = jsonDecode(response.body);

  if (response.statusCode != 200) {
    throw Exception(
      data['mensaje'] ?? 'Error al obtener las alícuotas',
    );
  }

  return data;
}
}