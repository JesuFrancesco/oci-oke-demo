import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ClienteDetailScreen extends StatefulWidget {
  final int clienteId;

  const ClienteDetailScreen({Key? key, required this.clienteId}) : super(key: key);

  @override
  State<ClienteDetailScreen> createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen> {
  Cliente? _cliente;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCliente();
  }

  Future<void> _loadCliente() async {
    setState(() {
      _isLoading = true;
    });

    final cliente = await ApiService.getCliente(widget.clienteId);

    if (cliente != null) {
      setState(() {
        _cliente = cliente;
        _isLoading = false;
      });
    } else {
      // Token expirado o error, redirigir al login
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado al portapapeles'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, {VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: Colors.blue.shade800),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value.isNotEmpty ? value : 'No disponible',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        trailing: onTap != null
            ? Icon(Icons.copy, color: Colors.grey.shade400)
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatusCard() {
    if (_cliente == null) return const SizedBox.shrink();

    final isActivo = _cliente!.estado.toLowerCase() == 'activo';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isActivo ? Colors.green.shade100 : Colors.orange.shade100,
              child: Icon(
                isActivo ? Icons.check_circle : Icons.pause_circle,
                color: isActivo ? Colors.green.shade800 : Colors.orange.shade800,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado del Cliente',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActivo ? Colors.green.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _cliente!.estado.toUpperCase(),
                      style: TextStyle(
                        color: isActivo ? Colors.green.shade800 : Colors.orange.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_cliente?.nombre ?? 'Detalle Cliente'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_cliente != null)
            IconButton(
              onPressed: _loadCliente,
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _cliente == null
              ? const Center(
                  child: Text('Cliente no encontrado'),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Avatar y nombre principal
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue,
                              child: Text(
                                _cliente!.nombre.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _cliente!.nombre,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _cliente!.empresa,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Estado del cliente
                      _buildStatusCard(),

                      // Información adicional
                      _buildInfoCard(
                        'Correo',
                        _cliente!.email,
                        Icons.email,
                        onTap: () => _copyToClipboard(_cliente!.email, 'Correo'),
                      ),
                      _buildInfoCard(
                        'Teléfono',
                        _cliente!.telefono,
                        Icons.phone,
                        onTap: () => _copyToClipboard(_cliente!.telefono, 'Teléfono'),
                      ),
                      _buildInfoCard(
                        'Dirección',
                        _cliente!.direccion,
                        Icons.location_on,
                        onTap: () => _copyToClipboard(_cliente!.direccion, 'Dirección'),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}
