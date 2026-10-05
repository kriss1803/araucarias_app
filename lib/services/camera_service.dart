import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<CameraResult> takePhoto() async {
    final permission = await Permission.camera.status;

    if (permission.isPermanentlyDenied) {
      return CameraResult.permanentlyDenied();
    }

    if (permission.isRestricted) {
      return CameraResult.restricted();
    }

    if (!permission.isGranted) {
      final requestedPermission = await Permission.camera.request();

      if (requestedPermission.isPermanentlyDenied) {
        return CameraResult.permanentlyDenied();
      }

      if (requestedPermission.isRestricted) {
        return CameraResult.restricted();
      }

      if (!requestedPermission.isGranted) {
        return CameraResult.denied();
      }
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo == null) {
        return CameraResult.cancelled();
      }

      return CameraResult.success(File(photo.path));
    } catch (e) {
      return CameraResult.error(e.toString());
    }
  }
}

enum CameraStatus {
  success,
  denied,
  permanentlyDenied,
  restricted,
  cancelled,
  error,
}

class CameraResult {
  final CameraStatus status;
  final File? file;
  final String? message;

  const CameraResult({
    required this.status,
    this.file,
    this.message,
  });

  factory CameraResult.success(File file) {
    return CameraResult(
      status: CameraStatus.success,
      file: file,
    );
  }

  factory CameraResult.denied() {
    return const CameraResult(
      status: CameraStatus.denied,
    );
  }

  factory CameraResult.permanentlyDenied() {
    return const CameraResult(
      status: CameraStatus.permanentlyDenied,
    );
  }

  factory CameraResult.restricted() {
    return const CameraResult(
      status: CameraStatus.restricted,
    );
  }

  factory CameraResult.cancelled() {
    return const CameraResult(
      status: CameraStatus.cancelled,
    );
  }

  factory CameraResult.error(String message) {
    return CameraResult(
      status: CameraStatus.error,
      message: message,
    );
  }
}