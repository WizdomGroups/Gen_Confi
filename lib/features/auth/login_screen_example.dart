// Example: How to update your login screen to use Riverpod
// This is a reference - update your actual login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_confi/core/providers/auth_provider.dart';
import 'package:gen_confi/app/routes/app_routes.dart';

class LoginScreenExample extends ConsumerStatefulWidget {
  const LoginScreenExample({super.key});

  @override
  ConsumerState<LoginScreenExample> createState() => _LoginScreenExampleState();
}

class _LoginScreenExampleState extends ConsumerState<LoginScreenExample> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigate based on user role
      final user = ref.read(currentUserProvider);
      if (user != null) {
        switch (user.role) {
          case 'client':
            Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
            break;
          case 'expert':
            Navigator.pushReplacementNamed(context, AppRoutes.expertHome);
            break;
          case 'admin':
            Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
            break;
          default:
            Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
        }
      }
    } else {
      // Show error
      final error = ref.read(authErrorProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 24),
                if (authState.isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _handleLogin,
                    child: Text('Login'),
                  ),
                if (authState.error != null)
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      authState.error!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

