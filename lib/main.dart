import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/camara_screen.dart';
import 'screens/alicuotas_screen.dart';
import 'screens/registrar_pago_screen.dart';

import 'screens/notificaciones_screen.dart';

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
        '/camara': (context) => const CamaraScreen(),
        '/notificaciones': (context) => const NotificacionesScreen(),
        '/alicuotas': (context) => const AlicuotasScreen(),
        '/registrar-pago': (context) => const RegistrarPagoScreen(),
      },
    );
  }
}