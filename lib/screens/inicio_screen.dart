import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final usuario = authProvider.usuario;

    // Protección básica de la pantalla
    if (!authProvider.isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: Text('Debe iniciar sesión para acceder'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Araucarias'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              authProvider.logout();

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home_work,
                size: 90,
              ),

              const SizedBox(height: 20),

              Text(
                'Bienvenido ${usuario?.nombre ?? ''}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                usuario?.correo ?? '',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Rol: ${usuario?.rol ?? ''}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Más adelante iremos a la pantalla de áreas
                  },
                  icon: const Icon(Icons.location_city),
                  label: const Text('Áreas comunes'),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Más adelante iremos a la pantalla de reservas
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Mis reservas'),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Más adelante iremos al perfil
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Mi perfil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}