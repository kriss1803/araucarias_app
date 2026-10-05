import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() =>
      _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  bool _loading = false;

  Future<void> _requestPermissions() async {
    setState(() {
      _loading = true;
    });

    final granted =
        await NotificationService.instance.requestPermissions();

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted
              ? 'Permiso de notificaciones concedido.'
              : 'Permiso de notificaciones no concedido.',
        ),
      ),
    );
  }

  Future<void> _showTestNotification() async {
    await NotificationService.instance.showTestNotification();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificación de prueba enviada.'),
      ),
    );
  }

  Future<void> _scheduleTestReminder() async {
    final reminderDate = DateTime.now().add(
      const Duration(seconds: 20),
    );

    await NotificationService.instance.scheduleReservationReminder(
      id: 200,
      reservationName: 'Reserva de prueba',
      reservationDate: reminderDate,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Recordatorio programado para aproximadamente 20 segundos.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Prueba de recordatorios de reservas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loading ? null : _requestPermissions,
              icon: const Icon(Icons.notifications_active),
              label: const Text('Solicitar permiso'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showTestNotification,
              icon: const Icon(Icons.notifications),
              label: const Text('Mostrar notificación'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _scheduleTestReminder,
              icon: const Icon(Icons.schedule),
              label: const Text('Programar recordatorio de prueba'),
            ),
          ],
        ),
      ),
    );
  }
}