import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_button.dart';
import '../controllers/auth_controller.dart';
import 'privacy_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final success = await context.read<AuthController>().login(
      _emailController.text,
      _passwordController.text,
    );
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al iniciar sesión'),
            backgroundColor: AppColors.error.withValues(alpha: 0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Subtle glow
            Positioned(
              top: -150,
              right: -100,
              child: _buildBlurCircle(
                400,
                AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'POWER STACK',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textTitle,
                          letterSpacing: 2,
                        ),
                      ),
                      const Text(
                        'DOMINA TU ENTRENAMIENTO',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        style: const TextStyle(color: AppColors.textTitle),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'ejemplo@correo.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _login(),
                        style: const TextStyle(color: AppColors.textTitle),
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 32),
                      NeonButton(
                        label: 'ENTRAR',
                        onTap: _login,
                        isLoading: isLoading,
                        colors: const [AppColors.primary, Color(0xFF8BB52E)],
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'CREAR CUENTA',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyScreen(),
                          ),
                        ),
                        child: const Text(
                          'Política de Privacidad',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
      ),
    );
  }
}
