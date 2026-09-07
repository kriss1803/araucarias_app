import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/inicio_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const AraucariasApp(),
    ),
  );
}

class AraucariasApp extends StatelessWidget {
  const AraucariasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Araucarias',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/inicio': (context) => const InicioScreen(),
      },
    );
  }
}