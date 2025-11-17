import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'cliente_detail_screen.dart';
import 'login_screen.dart';

class ClientesListScreen extends StatefulWidget {
  const ClientesListScreen({Key? key}) : super(key: key);

  @override
  State<ClientesListScreen> createState() => _ClientesListScreenState();
}

class _ClientesListScreenState extends State<ClientesListScreen> {
  List<Cliente> _clientes = [];
  List<Cliente> _clientesFiltrados = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClientes() async {
    setState(() {
      _isLoading = true;
    });

    final clientes = await ApiService.getClientes();
    
    if (clientes != null) {
      setState(() {
        _clientes = clientes;
        _clientesFiltrados = clientes;
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

  void _filtrarClientes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _clientesFiltrados = _clientes;
      } else {
        _clientesFiltrados = _clientes
            .where((cliente) =>
                cliente.nombre.toLowerCase().contains(query.toLowerCase()) ||
                cliente.empresa.toLowerCase().contains(query.toLowerCase()) ||
                cliente.email.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _logout() async {
    await ApiService.clearToken();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _buildClienteCard(Cliente cliente) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: cliente.estado == 'activo' ? Colors.green : Colors.orange,
          child: Text(
            cliente.nombre.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          cliente.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              cliente.empresa,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              cliente.email,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cliente.estado == 'activo' ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                cliente.estado.toUpperCase(),
                style: TextStyle(
                  color: cliente.estado == 'activo' ? Colors.green.shade800 : Colors.orange.shade800,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () async {
          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClienteDetailScreen(clienteId: cliente.id),
            ),
          );
          if (shouldRefresh == true) {
            _loadClientes();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filtrarClientes,
              decoration: InputDecoration(
                hintText: 'Buscar clientes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _filtrarClientes('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          
          // Lista de clientes
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _clientesFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No hay clientes'
                                  : 'No se encontraron clientes',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadClientes,
                        child: ListView.builder(
                          itemCount: _clientesFiltrados.length,
                          itemBuilder: (context, index) {
                            return _buildClienteCard(_clientesFiltrados[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadClientes,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}