import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_confi/app/app.dart';
import 'package:gen_confi/services/theme_store.dart';

void main() async {
  // Ensure binding is initialized for any future async initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted theme before app starts to prevent flickering
  await ThemeStore().loadTheme();

  runApp(const ProviderScope(child: GenConfiApp()));
}
