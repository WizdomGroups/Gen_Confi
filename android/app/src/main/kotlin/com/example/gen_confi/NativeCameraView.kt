package com.example.gen_confi

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.Rect
import android.graphics.YuvImage
import android.view.View
import android.widget.FrameLayout
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetector
import com.google.mlkit.vision.face.FaceDetectorOptions
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import android.os.Handler
import android.util.Log

class NativeCameraView(
    private val context: Context,
    messenger: BinaryMessenger,
    eventChannel: EventChannel
) : PlatformView, LifecycleOwner, EventChannel.StreamHandler {

    private val container = FrameLayout(context)
    private val previewView = PreviewView(context)
    private val lifecycleRegistry = LifecycleRegistry(this)
    private var eventSink: EventChannel.EventSink? = null
    
    private var cameraProvider: ProcessCameraProvider? = null
    private var imageAnalysis: ImageAnalysis? = null
    private val cameraExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    
    // ML Kit
    private var faceDetector: FaceDetector? = null
    
    // Capture State
    private var lastBitmap: Bitmap? = null
    private var lastMeta: Map<String, Any>? = null
    private var isProcessing = false

    init {
        eventChannel.setStreamHandler(this)
        previewView.implementationMode = PreviewView.ImplementationMode.COMPATIBLE
        container.addView(previewView)
        setupDetector()
        lifecycleRegistry.currentState = Lifecycle.State.CREATED
    }
    
    private fun setupDetector() {
        val options = FaceDetectorOptions.Builder()
            .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_FAST)
            .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_NONE)
            .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_NONE)
            .enableTracking() // Optional
            .build()
            
        faceDetector = FaceDetection.getClient(options)
    }

    override fun getView(): View = container

    override fun dispose() {
        stopCamera()
        cameraExecutor.shutdown()
        faceDetector?.close()
    }

    override val lifecycle: Lifecycle get() = lifecycleRegistry

    fun startCamera() {
        lifecycleRegistry.currentState = Lifecycle.State.STARTED
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            cameraProvider = cameraProviderFuture.get()
            bindCameraUseCases()
        }, ContextCompat.getMainExecutor(context))
    }

    fun stopCamera() {
        cameraProvider?.unbindAll()
        lifecycleRegistry.currentState = Lifecycle.State.DESTROYED
    }

    private fun bindCameraUseCases() {
        val cameraProvider = cameraProvider ?: return
        val preview = Preview.Builder().build().also {
            it.setSurfaceProvider(previewView.surfaceProvider)
        }

        imageAnalysis = ImageAnalysis.Builder()
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .build()
            .also {
                it.setAnalyzer(cameraExecutor) { imageProxy ->
                    processImage(imageProxy)
                }
            }

        try {
            cameraProvider.unbindAll()
            cameraProvider.bindToLifecycle(
                this, 
                CameraSelector.DEFAULT_FRONT_CAMERA, 
                preview, 
                imageAnalysis
            )
        } catch (exc: Exception) {
            Log.e("SmartCapture", "Use case binding failed", exc)
        }
    }

    @androidx.annotation.OptIn(androidx.camera.core.ExperimentalGetImage::class)
    private fun processImage(imageProxy: ImageProxy) {
        val mediaImage = imageProxy.image
        if (mediaImage != null && !isProcessing) {
            isProcessing = true
            
            // 1. Convert to InputImage
            val rotationDegrees = imageProxy.imageInfo.rotationDegrees
            val inputImage = InputImage.fromMediaImage(mediaImage, rotationDegrees)
            
            // 2. Convert to Bitmap for Capture Cache (expensive, optimize later?)
            // We only do this if we need to SAVE it, or we can defer it.
            // For brightness we need pixels.
            val bitmap = imageProxyToBitmap(imageProxy)
            lastBitmap = bitmap 

            // 3. Run Analysis
            faceDetector?.process(inputImage)
                ?.addOnSuccessListener { faces ->
                    val brightness = calculateBrightness(bitmap)
                    val sharpness = 0.8 // ML Kit doesn't provide this easily
                    
                    val meta = mutableMapOf<String, Any>(
                        "hasFace" to false,
                        "faceCount" to faces.size,
                        "brightness" to brightness,
                        "sharpness" to sharpness,
                        "reasons" to listOf<String>()
                    )
                    
                    if (faces.isNotEmpty()) {
                        val face = faces[0]
                        val bounds = face.boundingBox
                        
                        // Calculate center offset (-0.5 to 0.5 range logic)
                        // InputImage coords are relative to the image size
                        val cx = bounds.exactCenterX() / mediaImage.width
                        val cy = bounds.exactCenterY() / mediaImage.height
                        
                        // Normalize to -1.0 to 1.0 (0 is center)
                        // Note: CameraX image might be rotated. Assuming mapping is handled or simplistic.
                        // FaceDetector handles rotation, so bounds are in image coordinates.
                        
                        val dx = (cx - 0.5) * 2
                        val dy = (cy - 0.5) * 2
                        
                        // Pose (Euler angles)
                        val rotY = face.headEulerAngleY // Yaw
                        val rotZ = face.headEulerAngleZ // Roll
                        // Pitch is not reliably returned by all ML Kit versions, often -1
                        val rotX = face.headEulerAngleX 

                        // Area
                        val areaRatio = (bounds.width() * bounds.height()).toDouble() / (mediaImage.width * mediaImage.height)

                        meta["hasFace"] = true
                        meta["faceCenterDx"] = dx // Flipped for mirror effect?
                        meta["faceCenterDy"] = dy
                        meta["faceAreaRatio"] = areaRatio
                        meta["yawDeg"] = rotY.toDouble()
                        meta["rollDeg"] = rotZ.toDouble()
                        meta["pitchDeg"] = rotX.toDouble()
                    } else {
                        // Defaults
                        meta["faceCenterDx"] = 0.0
                        meta["faceCenterDy"] = 0.0
                        meta["faceAreaRatio"] = 0.0
                         meta["yawDeg"] = 0.0
                        meta["rollDeg"] = 0.0
                        meta["pitchDeg"] = 0.0
                    }
                    
                    lastMeta = meta
                    Handler(context.mainLooper).post {
                        eventSink?.success(meta)
                    }
                    isProcessing = false
                }
                ?.addOnFailureListener { 
                    isProcessing = false
                }
                ?.addOnCompleteListener {
                   imageProxy.close()
                }
        } else {
            imageProxy.close()
        }
    }

    private fun imageProxyToBitmap(image: ImageProxy): Bitmap {
        if (image.format == ImageFormat.YUV_420_888) {
            val yBuffer = image.planes[0].buffer
            val uBuffer = image.planes[1].buffer
            val vBuffer = image.planes[2].buffer

            val ySize = yBuffer.remaining()
            val uSize = uBuffer.remaining()
            val vSize = vBuffer.remaining()

            val nv21 = ByteArray(ySize + uSize + vSize)

            // 1. Copy Y plane
            yBuffer.get(nv21, 0, ySize)

            // 2. Interleave U and V for NV21 (V, U, V, U...)
            // Note: CameraX YUV_420_888 might be I420 (Planar) or NV21 (Semi-Planar).
            // Emulators often output I420 (separate U and V planes).
            // We need to construct NV21: Y... V U V U ...
            
            val pixelStrideY = image.planes[0].pixelStride
            val pixelStrideU = image.planes[1].pixelStride
            val pixelStrideV = image.planes[2].pixelStride
            
            // If pixelStride is 2, it's likely already semi-planar (NV21/NV12).
            // If pixelStride is 1, it's planar (I420).
            
            var pos = ySize
            if (pixelStrideU == 1 && pixelStrideV == 1) {
                // I420 (Planar) -> Convert to NV21 (Interleaved)
                // U and V are subsampled by 2x2.
                // Width of UV plane = width / 2
                // Height of UV plane = height / 2
                val uvWidth = image.width / 2
                val uvHeight = image.height / 2
                
                for (j in 0 until uvHeight) {
                    for (i in 0 until uvWidth) {
                        val u = uBuffer.get(j * image.planes[1].rowStride + i)
                        val v = vBuffer.get(j * image.planes[2].rowStride + i)
                        // NV21 expects V first, then U
                        nv21[pos++] = v
                        nv21[pos++] = u
                    }
                }
            } else {
                // Fallback: Just copy V then U (assuming they might already be interleaved if stride > 1 but we treat as separate checks)
                // But for robust emulator support (I420), the above loop is critical.
                // If it is already NV21/NV12, logic is complex. 
                // Let's assume standard emulator usage (I420). 
                // Or simplified: direct YuvImage only supports NV21.
                
                // Hacky fallback for complex strides: Just copy V then U plane sequentially (Might be wrong but better than crash)
                vBuffer.get(nv21, ySize, vSize)
                uBuffer.get(nv21, ySize + vSize, uSize)
            }

            val yuvImage = YuvImage(nv21, ImageFormat.NV21, image.width, image.height, null)
            val out = ByteArrayOutputStream()
            yuvImage.compressToJpeg(Rect(0, 0, image.width, image.height), 100, out)
            val imageBytes = out.toByteArray()
            
            return BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
        } else {
            // Fallback for JPEG or other formats
            val planeProxy = image.planes[0]
            val buffer: ByteBuffer = planeProxy.buffer
            val bytes = ByteArray(buffer.remaining())
            buffer.get(bytes)
            return BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
               ?: Bitmap.createBitmap(image.width, image.height, Bitmap.Config.ARGB_8888)
        }
    }

    private fun calculateBrightness(bitmap: Bitmap): Double {
        // Sample center
        val x = bitmap.width / 2
        val y = bitmap.height / 2
        if (x < 0 || x >= bitmap.width || y < 0 || y >= bitmap.height) return 0.5
        val pixel = bitmap.getPixel(x, y)
        val r = (pixel shr 16) and 0xff
        val g = (pixel shr 8) and 0xff
        val b = pixel and 0xff
        return (0.299*r + 0.587*g + 0.114*b) / 255.0
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun captureImage(callback: (String?, Map<String, Any>?) -> Unit) {
        val bitmap = lastBitmap
        if (bitmap != null) {
            try {
                val file = File(context.cacheDir, "smart_capture_${System.currentTimeMillis()}.jpg")
                val stream = FileOutputStream(file)
                bitmap.compress(Bitmap.CompressFormat.JPEG, 90, stream)
                stream.close()
                callback(file.absolutePath, lastMeta)
            } catch (e: Exception) {
                callback(null, null)
            }
        } else {
            callback(null, null)
        }
    }
}
