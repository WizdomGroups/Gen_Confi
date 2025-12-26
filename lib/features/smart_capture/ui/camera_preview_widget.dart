// FILE: lib/features/smart_capture/ui/camera_preview_widget.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraPreviewWidget extends StatelessWidget {
  final VoidCallback? onViewCreated;

  const CameraPreviewWidget({super.key, this.onViewCreated});

  @override
  Widget build(BuildContext context) {
    // For this implementation, we use a Platform View (AndroidView/UiKitView)
    // registered by the native plugin as "genconfi/mediapipe_camera_view".

    // NOTE: This will only render once the Native side is implemented.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'genconfi/mediapipe_camera_view',
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (_) => onViewCreated?.call(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'genconfi/mediapipe_camera_view',
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (_) => onViewCreated?.call(),
      );
    }

    return const Center(child: Text("Platform not supported"));
  }
}
