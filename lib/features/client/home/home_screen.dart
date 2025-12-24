import 'package:flutter/material.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gen Confi Client Home')),
      body: const Center(child: Text('Welcome to Gen Confi!')),
    );
  }
}
