class Cliente {
  final int id;
  final String nombre;
  final String email;
  final String telefono;
  final String empresa;
  final String direccion;
  final String estado;

  Cliente({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.empresa,
    required this.direccion,
    required this.estado,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      telefono: json['telefono'],
      empresa: json['empresa'],
      direccion: json['direccion'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'empresa': empresa,
      'direccion': direccion,
      'estado': estado,
    };
  }
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class TokenResponse {
  final String accessToken;
  final String tokenType;

  TokenResponse({required this.accessToken, required this.tokenType});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }
}