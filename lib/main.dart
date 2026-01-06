import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_confi/app/app.dart';

void main() {
  // Ensure binding is initialized for any future async initialization
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: GenConfiApp(),
    ),
  );
}
