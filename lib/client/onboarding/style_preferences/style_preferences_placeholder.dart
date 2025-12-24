import 'package:flutter/material.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';

class StylePreferencesPlaceholder extends StatelessWidget {
  const StylePreferencesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      title: 'Style Preferences',
      showBackButton: true,
      body: Center(child: Text('Coming next')),
    );
  }
}
