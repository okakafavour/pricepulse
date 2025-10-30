// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'price_list_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await auth.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (success && auth.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Registration successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PriceListScreen()),
        );
      } else if (success) {
        // registration succeeded but backend didn't return token
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered — please login.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Registration failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
      appBar: AppBar(title: const Text('Register'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter your email' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (v) => v != null && v.length < 6 ? 'At least 6 chars' : null,
                    ),
                    const SizedBox(height: 30),
                    _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(
                      onPressed: () => _register(context),
                      child: const Text('Register'),
                    ),
                    const SizedBox(height: 15),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Already have an account? Login')),
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
