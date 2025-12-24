import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/layout/responsive_container.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  final bool
  useResponsiveContainer; // New flag to optionally disable inner responsive wrapping

  const BaseScaffold({
    super.key,
    required this.body,
    this.title,
    this.showBackButton = true,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.useResponsiveContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              centerTitle: true,
              automaticallyImplyLeading: showBackButton,
              actions: actions,
            )
          : null,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        child: useResponsiveContainer ? ResponsiveContainer(child: body) : body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
