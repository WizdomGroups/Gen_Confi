// FILE: ios/Runner/NativeCameraViewFactory.swift

import Flutter
import UIKit

class NativeCameraViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private weak var plugin: SmartCapturePlugin?

    init(messenger: FlutterBinaryMessenger, plugin: SmartCapturePlugin) {
        self.messenger = messenger
        self.plugin = plugin
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let view = NativeCameraView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger,
            plugin: plugin
        )
        // Register view with plugin so methods control it
        plugin?.activeCameraView = view
        return view
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
}
