package com.example.gen_confi

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeCameraViewFactory(
    private val messenger: BinaryMessenger,
    private val eventChannel: EventChannel,
    private val onViewCreated: (NativeCameraView) -> Unit
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val view = NativeCameraView(context, messenger, eventChannel)
        onViewCreated(view)
        return view
    }
}
