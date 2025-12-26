// FILE: lib/features/smart_capture/platform/mediapipe_capture_engine.dart

import 'package:flutter/services.dart';
import 'package:gen_confi/features/smart_capture/domain/quality_models.dart';

class MediaPipeCaptureEngine {
  static const MethodChannel _methodChannel = MethodChannel(
    'genconfi/mediapipe_capture',
  );
  static const EventChannel _eventChannel = EventChannel(
    'genconfi/mediapipe_capture_events',
  );

  Stream<QualityMeta>? _qualityStream;

  Future<void> initialize() async {
    try {
      await _methodChannel.invokeMethod('initialize');
    } on PlatformException catch (e) {
      print("Failed to initialize MediaPipe: ${e.message}");
    }
  }

  Future<void> start() async {
    try {
      await _methodChannel.invokeMethod('start');
    } on PlatformException catch (e) {
      print("Failed to start camera: ${e.message}");
    }
  }

  Future<void> stop() async {
    try {
      await _methodChannel.invokeMethod('stop');
    } on PlatformException catch (e) {
      print("Failed to stop camera: ${e.message}");
    }
  }

  Future<CaptureResult?> capture() async {
    try {
      final result = await _methodChannel.invokeMethod('capture');
      if (result != null && result is Map) {
        return CaptureResult.fromMap(result);
      }
    } on PlatformException catch (e) {
      print("Failed to capture image: ${e.message}");
    }
    return null;
  }

  Future<void> dispose() async {
    try {
      await _methodChannel.invokeMethod('dispose');
    } on PlatformException catch (e) {
      print("Failed to dispose MediaPipe: ${e.message}");
    }
  }

  Stream<QualityMeta> get qualityStream {
    _qualityStream ??= _eventChannel.receiveBroadcastStream().map(
      (event) => QualityMeta.fromMap(event as Map),
    );
    return _qualityStream!;
  }
}
