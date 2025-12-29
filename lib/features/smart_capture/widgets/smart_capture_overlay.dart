import 'package:flutter/material.dart';

class SmartCaptureOverlay extends StatelessWidget {
  final String instruction;
  final bool isReady;

  const SmartCaptureOverlay({
    Key? key,
    required this.instruction,
    this.isReady = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _OverlayPainter(isReady: isReady),
        ),
        Positioned(
          bottom: 120, // Adjust based on screen height
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              instruction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final bool isReady;

  _OverlayPainter({required this.isReady});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height / 2 - 40);
    
    // 1. Tech Color Palette
    final primaryColor = isReady ? Colors.greenAccent : Colors.cyanAccent;
    final secondaryColor = Colors.cyan.withOpacity(0.3);
    final gridColor = Colors.cyan.withOpacity(0.1);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 2. Draw Grid Background
    paint.color = gridColor;
    double gridSize = 40.0;
    
    // Vertical Lines
    for (double x = 0; x < width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), paint);
    }
    // Horizontal Lines
    for (double y = 0; y < height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(width, y), paint);
    }

    // 3. Central Face Frame (Hexagon or Polygon Style)
    // We'll use a path for a "Tech Shield" shape around the face
    final faceWidth = width * 0.7;
    final faceHeight = faceWidth * 1.3;
    final faceRect = Rect.fromCenter(center: center, width: faceWidth, height: faceHeight);

    // Dim the background OUTSIDE the face rect slightly
    final bgPaint = Paint()..color = Colors.black45; // slightly darker for better text contrast
    final bgPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addOval(faceRect); // Punch hole
    // Actually for tech look, let's just darken everything slightly but keep grid visible?
    // Or just vignette. Let's stick to the hole punch but rectangular/techy?
    // The reference has a clear view. Let's just draw the tech elements ON TOP.
    // We won't darken the outside to keep the "grid" feel alive.
    
    // 4. Corner Brackets (Viewfinder)
    paint.color = primaryColor;
    paint.strokeWidth = 3.0;
    double cornerLen = 30.0;
    double cornerGap = 10.0; // gap from rect

    // Top Left
    canvas.drawLine(faceRect.topLeft + Offset(-cornerGap, cornerLen), faceRect.topLeft + Offset(-cornerGap, -cornerGap), paint); // vert
    canvas.drawLine(faceRect.topLeft + Offset(-cornerGap, -cornerGap), faceRect.topLeft + Offset(cornerLen, -cornerGap), paint); // horz

    // Top Right
    canvas.drawLine(faceRect.topRight + Offset(cornerGap, cornerLen), faceRect.topRight + Offset(cornerGap, -cornerGap), paint);
    canvas.drawLine(faceRect.topRight + Offset(cornerGap, -cornerGap), faceRect.topRight + Offset(-cornerLen, -cornerGap), paint);

    // Bottom Left
    canvas.drawLine(faceRect.bottomLeft + Offset(-cornerGap, -cornerLen), faceRect.bottomLeft + Offset(-cornerGap, cornerGap), paint);
    canvas.drawLine(faceRect.bottomLeft + Offset(-cornerGap, cornerGap), faceRect.bottomLeft + Offset(cornerLen, cornerGap), paint);

    // Bottom Right
    canvas.drawLine(faceRect.bottomRight + Offset(cornerGap, -cornerLen), faceRect.bottomRight + Offset(cornerGap, cornerGap), paint);
    canvas.drawLine(faceRect.bottomRight + Offset(cornerGap, cornerGap), faceRect.bottomRight + Offset(-cornerLen, cornerGap), paint);

    // 5. Simulated Face Mesh Nodes (Static for now, but looks cool)
    // Draw a few key points inside the oval to look like scanning
    final meshPaint = Paint()
      ..color = primaryColor.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    // Central Node
    canvas.drawCircle(center, 4.0, meshPaint);
    
    // Connecting Lines
    paint.color = primaryColor.withOpacity(0.3);
    paint.strokeWidth = 1.0;
    
    // Diamond pattern dots
    List<Offset> dots = [
      center + Offset(0, -faceHeight * 0.3), // Forehead
      center + Offset(-faceWidth * 0.3, -faceHeight * 0.1), // Left Cheek
      center + Offset(faceWidth * 0.3, -faceHeight * 0.1), // Right Cheek
      center + Offset(0, faceHeight * 0.35), // Chin
      center + Offset(-faceWidth * 0.2, faceHeight * 0.2), // Jaw L
      center + Offset(faceWidth * 0.2, faceHeight * 0.2), // Jaw R
    ];

    for (var dot in dots) {
      canvas.drawCircle(dot, 3.0, meshPaint);
      canvas.drawLine(center, dot, paint);
    }
    // Connect outer dots ring
    for (int i = 0; i < dots.length; i++) {
      canvas.drawLine(dots[i], dots[(i + 1) % dots.length], paint);
    }

    // 6. Side Decoration (Waveform/Circles)
    // Left Side Data Circle
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = secondaryColor;
    
    canvas.drawCircle(Offset(width * 0.15, center.dy), 25, circlePaint);
    canvas.drawCircle(Offset(width * 0.15, center.dy), 15, circlePaint..strokeWidth=1);
    
    // Right Side Waveform lines
    final linePaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 2.0;
      
    double rightX = width * 0.85;
    for(int i=0; i<3; i++) {
        canvas.drawLine(Offset(rightX - 10, center.dy - 10 + (i*10)), Offset(rightX + 10, center.dy - 10 + (i*10)), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return oldDelegate.isReady != isReady;
  }
}
