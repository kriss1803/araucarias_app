import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class RegistrarPagoScreen extends StatefulWidget {
  const RegistrarPagoScreen({super.key});

  @override
  State<RegistrarPagoScreen> createState() => _RegistrarPagoScreenState();
}

class _RegistrarPagoScreenState extends State<RegistrarPagoScreen> {
  String? _metodoPago;
  String? _comprobante;
  String? _comprobantePath;
  bool _registrando = false;

  int? _alicuotaId;
String? _periodo;
double? _monto;

  final ApiService _apiService = ApiService();

  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  final arguments = ModalRoute.of(context)?.settings.arguments;

  if (arguments is Map<String, dynamic>) {
    _alicuotaId = arguments['alicuotaId'] as int?;
    _periodo = arguments['periodo'] as String?;

    final monto = arguments['monto'];

    if (monto is String) {
      _monto = double.tryParse(monto);
    } else if (monto is num) {
      _monto = monto.toDouble();
    }
  }
}

  Future<void> _seleccionarComprobante() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null) {
      return;
    }

    final archivo = result.single;

    if (archivo.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener el archivo seleccionado.'),
        ),
      );
      return;
    }

    setState(() {
      _comprobante = archivo.name;
      _comprobantePath = archivo.path;
    });
  }

  Future<void> _registrarPago() async {
    if (_metodoPago == null || _comprobantePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona el método de pago y el comprobante.',
          ),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final usuario = authProvider.usuario;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el usuario.'),
        ),
      );
      return;
    }

    setState(() {
      _registrando = true;
    });

    try {
      // 1. Crear el pago.
      if (_alicuotaId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                content: Text('No se encontró la alícuota seleccionada.'),
                ),
            );
            return;
            }

            final pago = await _apiService.crearPago(
            monto: _monto ?? 0,
            metodoPago: _metodoPago!,
            usuarioId: usuario.id,
            alicuotaId: _alicuotaId!,
            );

      // 2. Obtener el ID del pago recién creado.
      final pagoId = pago['id'];

      // 3. Subir el comprobante usando ese ID.
      await _apiService.subirComprobante(
        pagoId,
        _comprobantePath!,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pago registrado y comprobante subido correctamente.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo registrar el pago: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _registrando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar pago'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registrar pago de alícuota',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Alícuota seleccionada',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Marzo 2026'),
                    SizedBox(height: 4),
                    Text(
                      'Monto: \$40.00',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Método de pago',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: _metodoPago,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Selecciona un método',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Transferencia',
                  child: Text('Transferencia'),
                ),
                DropdownMenuItem(
                  value: 'Depósito',
                  child: Text('Depósito'),
                ),
              ],
              onChanged: _registrando
                  ? null
                  : (value) {
                      setState(() {
                        _metodoPago = value;
                      });
                    },
            ),

            const SizedBox(height: 24),

            const Text(
              'Comprobante de pago',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _registrando
                    ? null
                    : _seleccionarComprobante,
                icon: const Icon(Icons.upload_file),
                label: const Text('Seleccionar comprobante'),
              ),
            ),

            if (_comprobante != null) ...[
              const SizedBox(height: 12),
              Text(
                _comprobante!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _registrando ? null : _registrarPago,
                icon: _registrando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  _registrando
                      ? 'Registrando...'
                      : 'Registrar pago',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}