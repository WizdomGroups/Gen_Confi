import 'package:flutter/material.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';

class GroomingProfilePlaceholder extends StatelessWidget {
  const GroomingProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      title: 'Grooming Profile',
      showBackButton: true,
      body: Center(child: Text('Coming next')),
    );
  }
}
