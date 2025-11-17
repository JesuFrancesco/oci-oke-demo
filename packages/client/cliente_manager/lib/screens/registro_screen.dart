import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'clientes_list_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({Key? key}) : super(key: key);

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _empresaController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _empresaController.dispose();
    super.dispose();
  }

  Future<void> _registro() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Concatenamos nombre + apellido para enviar solo el campo "nombre" al backend
    final nombreCompleto = '${_nombreController.text.trim()} ${_apellidoController.text.trim()}'.trim();

    final result = await ApiService.registro(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      email: _emailController.text.trim(),
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      direccion: _direccionController.text.trim(),
      empresa: _empresaController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result != null && result['success'] == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Registro exitoso'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ClientesListScreen()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?['message'] ?? 'Error al registrar usuario'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue.shade800),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.person_add, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 24),

                Text(
                  'Crear Cuenta',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                ),
                const SizedBox(height: 8),
                Text('Completa los datos para registrarte', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 24),

                // Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: _inputDecoration('Nombre', Icons.badge_outlined),
                  validator: (v) => v == null || v.isEmpty ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 16),

                // Apellido
                TextFormField(
                  controller: _apellidoController,
                  decoration: _inputDecoration('Apellido', Icons.person_outline),
                  validator: (v) => v == null || v.isEmpty ? 'Ingresa tu apellido' : null,
                ),
                const SizedBox(height: 16),

                // Empresa
                TextFormField(
                  controller: _empresaController,
                  decoration: _inputDecoration('Empresa', Icons.business_outlined),
                  validator: (v) => v == null || v.isEmpty ? 'Ingresa el nombre de tu empresa' : null,
                ),
                const SizedBox(height: 16),


                // Teléfono
                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Teléfono', Icons.phone),
                  validator: (v) => v == null || v.isEmpty ? 'Ingresa tu teléfono' : null,
                ),
                const SizedBox(height: 16),

                // Dirección
                TextFormField(
                  controller: _direccionController,
                  decoration: _inputDecoration('Dirección', Icons.home_outlined),
                  validator: (v) => v == null || v.isEmpty ? 'Ingresa tu dirección' : null,
                ),
                const SizedBox(height: 16),

                // Usuario
                TextFormField(
                  controller: _usernameController,
                  decoration: _inputDecoration('Usuario', Icons.account_circle_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa un usuario';
                    if (v.length < 3) return 'Debe tener al menos 3 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Email', Icons.email_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu email';
                    if (!v.contains('@')) return 'Ingresa un email válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration('Contraseña', Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                    if (v.length < 6) return 'Debe tener al menos 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirmar contraseña
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: _inputDecoration('Confirmar Contraseña', Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Confirma tu contraseña' : null,
                ),
                const SizedBox(height: 24),

                // Botón
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registro,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Registrarse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),

                // Link Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿Ya tienes cuenta? ', style: TextStyle(color: Colors.grey.shade600)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Inicia sesión', style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
