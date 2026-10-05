import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AlicuotasScreen extends StatefulWidget {
  const AlicuotasScreen({super.key});

  @override
  State<AlicuotasScreen> createState() => _AlicuotasScreenState();
}

class _AlicuotasScreenState extends State<AlicuotasScreen> {
  final ApiService _apiService = ApiService();

  List<dynamic> _alicuotas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarAlicuotas();
  }

  Future<void> _cargarAlicuotas() async {
    try {
      final alicuotas = await _apiService.obtenerAlicuotas();

      if (!mounted) {
        return;
      }

      setState(() {
        _alicuotas = alicuotas;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error.toString();
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis alícuotas'),
        centerTitle: true,
      ),
      body: _construirContenido(),
    );
  }

  Widget _construirContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No se pudieron cargar las alícuotas.\n\n$_error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_alicuotas.isEmpty) {
      return const Center(
        child: Text(
          'No hay alícuotas registradas.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alicuotas.length,
      itemBuilder: (context, index) {
        final alicuota = _alicuotas[index];

        final int id = alicuota['id'];
        final String periodo = alicuota['periodo'] ?? 'Sin período';
        final String monto = alicuota['monto'].toString();
        final String estado = alicuota['estado'] ?? 'PENDIENTE';

        final bool pagado = estado.toUpperCase() == 'PAGADO';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AlicuotaCard(
            id: id,
            periodo: periodo,
            monto: monto,
            estado: estado,
            pagado: pagado,
          ),
        );
      },
    );
  }
}

class _AlicuotaCard extends StatelessWidget {
  final int id;
  final String periodo;
  final String monto;
  final String estado;
  final bool pagado;

  const _AlicuotaCard({
    required this.id,
    required this.periodo,
    required this.monto,
    required this.estado,
    required this.pagado,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              pagado ? Icons.check_circle : Icons.pending,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    periodo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Alícuota ID: $id'),
                  const SizedBox(height: 4),
                  Text('Monto: \$$monto'),
                  const SizedBox(height: 4),
                  Text(
                    estado,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: pagado ? Colors.green : Colors.orange,
                    ),
                  ),
                  if (!pagado) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/registrar-pago',
                            arguments: {
                              'alicuotaId': id,
                              'periodo': periodo,
                              'monto': monto,
                            },
                          );
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Registrar pago'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}