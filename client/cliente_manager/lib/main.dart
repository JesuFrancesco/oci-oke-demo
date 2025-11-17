import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/clientes_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final isAuth = await ApiService.isAuthenticated();
    if (isAuth) {
      return const ClientesListScreen();
    } else {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cliente Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text('Error al cargar la app')),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
