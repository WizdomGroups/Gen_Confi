import 'dart:io';
import 'package:flutter/material.dart';

class SmartCapturePreviewScreen extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRetake;
  final Function(String) onConfirm;

  const SmartCapturePreviewScreen({
    Key? key,
    required this.imagePath,
    required this.onRetake,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(imagePath),
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: onRetake,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text("Retake", style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(backgroundColor: Colors.white24),
                ),
                ElevatedButton.icon(
                  onPressed: () => onConfirm(imagePath),
                  icon: const Icon(Icons.check),
                  label: const Text("Use Photo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
