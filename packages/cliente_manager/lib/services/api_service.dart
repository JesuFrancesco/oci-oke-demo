import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8080', // Android emulator localhost
    // defaultValue: 'http://localhost:8080', // Web or iOS simulator localhost
  );

  static const String loginEndpoint = '$baseUrl/login';
  static const String registroEndpoint = '$baseUrl/registro';
  static const String clientesEndpoint = '$baseUrl/clientes';

  static Future<Map<String, dynamic>?> registro({
    required String username,
    required String password,
    required String email,
    required String nombre,
    required String apellido,
    required String telefono,
    required String direccion,
    required String empresa,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(registroEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
          'nombre': '$nombre $apellido',
          'telefono': telefono,
          'empresa': empresa,
          'direccion': direccion,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        return {
          'success': true,
          'token': token,
          'message': data['message'] ?? 'Registro exitoso',
          'username': username,
        };
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['detail'] ?? 'Error en el registro',
        };
      } else {
        return {
          'success': false,
          'message': 'Error al registrar usuario (${response.statusCode})',
        };
      }
    } catch (e) {
      print('Error en registro: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Login
  static Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        // Guardar token en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        return token;
      } else {
        return null;
      }
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  // Obtener token guardado
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Limpiar token (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Obtener headers con autorización
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Obtener lista de clientes
  static Future<List<Cliente>?> getClientes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(clientesEndpoint),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Cliente.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await clearToken();
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Error obteniendo clientes: $e');
      return null;
    }
  }

  // Obtener un cliente específico
  static Future<Cliente?> getCliente(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$clientesEndpoint/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Cliente.fromJson(data);
      } else if (response.statusCode == 401) {
        await clearToken();
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Error obteniendo cliente: $e');
      return null;
    }
  }

  // Verificar si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }
}
