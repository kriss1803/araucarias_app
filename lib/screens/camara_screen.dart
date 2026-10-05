import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/camera_service.dart';

class CamaraScreen extends StatefulWidget {
  const CamaraScreen({super.key});

  @override
  State<CamaraScreen> createState() => _CamaraScreenState();
}

class _CamaraScreenState extends State<CamaraScreen> {
  final CameraService _cameraService = CameraService();

  File? _photo;
  bool _loading = false;

  Future<void> _takePhoto() async {
    setState(() {
      _loading = true;
    });

    final result = await _cameraService.takePhoto();

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    switch (result.status) {
      case CameraStatus.success:
        setState(() {
          _photo = result.file;
        });
        break;

      case CameraStatus.denied:
        _showMessage(
          'Se necesita el permiso de cámara para tomar fotografías.',
        );
        break;

      case CameraStatus.permanentlyDenied:
        _showSettingsDialog();
        break;

      case CameraStatus.restricted:
        _showMessage(
          'El acceso a la cámara está restringido en este dispositivo.',
        );
        break;

      case CameraStatus.cancelled:
        _showMessage('No se seleccionó ninguna fotografía.');
        break;

      case CameraStatus.error:
        _showMessage(
          result.message ?? 'Ocurrió un error al abrir la cámara.',
        );
        break;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permiso requerido'),
          content: const Text(
            'El permiso de cámara está bloqueado. '
            'Puedes habilitarlo desde la configuración de la aplicación.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text('Abrir configuración'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar novedad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Toma una fotografía para adjuntarla al reporte de una novedad.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: _photo == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 80,
                          ),
                          SizedBox(height: 12),
                          Text('Todavía no has tomado una fotografía.'),
                        ],
                      )
                    : Image.file(
                        _photo!,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loading ? null : _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: Text(
                _loading ? 'Abriendo cámara...' : 'Tomar fotografía',
              ),
            ),
          ],
        ),
      ),
    );
  }
}