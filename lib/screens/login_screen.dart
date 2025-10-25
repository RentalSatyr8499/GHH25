import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/password_field.dart';
import '../utils/fade_route.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.login(_usernameController.text.trim(), _passwordController.text);

    if (success) {
      // Navigate to dashboard (always) using a fade transition
      if (!mounted) return;
      Navigator.of(context).push(fadeRoute(const DashboardScreen()));
    } else {
      final err = provider.error ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);

    return Scaffold(
      key: const Key('login_app_bar'),
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    PasswordField(
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your password';
                        if (value.length < 4) return 'Password must be at least 4 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Builder(builder: (btnContext) {
                        void Function()? onPressed;
                        if (provider.loading) {
                          onPressed = null;
                        } else {
                          onPressed = () => _onLoginPressed(context);
                        }

                        Widget childWidget;
                        if (provider.loading) {
                          childWidget = const CircularProgressIndicator(color: Colors.white);
                        } else {
                          childWidget = const Text('Login');
                        }

                        return ElevatedButton(
                          key: const Key('login_button'),
                          onPressed: onPressed,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: childWidget,
                          ),
                        );
                      }),
                    ),
                    if (provider.error != null) ...[
                      const SizedBox(height: 12),
                      Text(provider.error!, style: const TextStyle(color: Colors.red)),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
