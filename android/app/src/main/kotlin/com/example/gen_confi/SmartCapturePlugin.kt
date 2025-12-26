package com.example.gen_confi

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

class SmartCapturePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var nativeCameraView: NativeCameraView? = null // Holds reference to active view

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "genconfi/mediapipe_capture")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "genconfi/mediapipe_capture_events")
        
        // Register Platform View
        binding.platformViewRegistry.registerViewFactory(
            "genconfi/mediapipe_camera_view",
            NativeCameraViewFactory(binding.binaryMessenger, eventChannel, { view ->
                nativeCameraView = view
            })
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                // Initialization happens in the View creation mostly
                result.success(null)
            }
            "start" -> {
                nativeCameraView?.startCamera()
                result.success(null)
            }
            "stop" -> {
                nativeCameraView?.stopCamera()
                result.success(null)
            }
            "capture" -> {
                nativeCameraView?.captureImage { path, meta ->
                    if (path != null) {
                        result.success(mapOf("imagePath" to path, "meta" to meta))
                    } else {
                        result.error("CAPTURE_FAILED", "Failed to capture image", null)
                    }
                }
            }
            "dispose" -> {
                nativeCameraView?.stopCamera()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
