// FILE: ios/Runner/SmartCapturePlugin.swift

import Flutter
import UIKit

public class SmartCapturePlugin: NSObject, FlutterPlugin {
  private var methodChannel: FlutterMethodChannel?
  private var eventChannel: FlutterEventChannel?
  private var eventSink: FlutterEventSink?
    
  // Keep track of active view(s) logic. 
  // Since PlatformViewFactory creates views, we need a way to communicate.
  // We'll use a singleton or delegate pattern for simplicity in this specific app structure.
  // Or better, the Factory passes the messenger to the view, and the view handles its own logic/events.
  // BUT the methods (start/stop) come to the Plugin. 
  // Thus we need a reference to the active view.
  
  weak var activeCameraView: NativeCameraView?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: "genconfi/mediapipe_capture", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "genconfi/mediapipe_capture_events", binaryMessenger: registrar.messenger())
    
    let instance = SmartCapturePlugin()
    instance.methodChannel = methodChannel
    instance.eventChannel = eventChannel
    
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    eventChannel.setStreamHandler(instance)
    
    let factory = NativeCameraViewFactory(messenger: registrar.messenger(), plugin: instance)
    registrar.register(factory, withId: "genconfi/mediapipe_camera_view")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
        result(nil)
    case "start":
        activeCameraView?.startCamera()
        result(nil)
    case "stop":
        activeCameraView?.stopCamera()
        result(nil)
    case "capture":
        activeCameraView?.captureImage { path, meta in
            if let path = path {
                result(["imagePath": path, "meta": meta ?? [:]])
            } else {
                result(FlutterError(code: "CAPTURE_FAILED", message: "Failed to capture", details: nil))
            }
        }
    case "dispose":
        activeCameraView?.stopCamera()
        result(nil)
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}

extension SmartCapturePlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    func sendEvent(data: [String: Any]) {
        eventSink?(data)
    }
}
