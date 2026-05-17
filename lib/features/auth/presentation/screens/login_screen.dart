import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_button.dart';
import '../controllers/auth_controller.dart';
import 'privacy_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _animController;
  late final Animation<double> _fadeHero;
  late final Animation<Offset> _slideHero;
  late final Animation<double> _fadeForm;
  late final Animation<Offset> _slideForm;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeHero = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );
    _slideHero = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    ));

    _fadeForm = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
    _slideForm = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final success = await context.read<AuthController>().login(
          _emailController.text,
          _passwordController.text,
        );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Credenciales incorrectas. Intenta de nuevo.'),
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned(
              top: -80,
              left: -80,
              child: _glow(300, AppColors.primary.withValues(alpha: 0.13)),
            ),
            Positioned(
              top: size.height * 0.2,
              right: -60,
              child: _glow(200, AppColors.secondary.withValues(alpha: 0.07)),
            ),
            Positioned(
              bottom: -100,
              right: -60,
              child: _glow(260, AppColors.primary.withValues(alpha: 0.07)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        size.height - padding.top - padding.bottom,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.07),

                      // ── Hero ──────────────────────────────────────────
                      SlideTransition(
                        position: _slideHero,
                        child: FadeTransition(
                          opacity: _fadeHero,
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary
                                      .withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.28),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.22),
                                      blurRadius: 36,
                                      spreadRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.fitness_center_rounded,
                                  size: 50,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'POWER STACK',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textTitle,
                                  letterSpacing: 4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _dash(),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      'DOMINA TU ENTRENAMIENTO',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: AppColors.textBody,
                                        letterSpacing: 2.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  _dash(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.07),

                      // ── Form ──────────────────────────────────────────
                      SlideTransition(
                        position: _slideForm,
                        child: FadeTransition(
                          opacity: _fadeForm,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _label('CORREO ELECTRÓNICO'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                style: const TextStyle(
                                  color: AppColors.textTitle,
                                  fontSize: 15,
                                ),
                                decoration: _inputDeco(
                                  hint: 'ejemplo@correo.com',
                                  icon: Icons.alternate_email_rounded,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _label('CONTRASEÑA'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onSubmitted: (_) => _login(),
                                style: const TextStyle(
                                  color: AppColors.textTitle,
                                  fontSize: 15,
                                ),
                                decoration: _inputDeco(
                                  hint: '••••••••',
                                  icon: Icons.lock_outline_rounded,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 20,
                                      color: AppColors.textBody,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscurePassword =
                                          !_obscurePassword,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),
                              NeonButton(
                                label: 'INGRESAR',
                                onTap: _login,
                                isLoading: isLoading,
                                colors: const [
                                  AppColors.primary,
                                  Color(0xFF8BB52E),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Row(
                                children: const [
                                  Expanded(
                                    child: Divider(
                                        color: Color(0xFFDDDDDD)),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'o',
                                      style: TextStyle(
                                        color: AppColors.textBody,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                        color: Color(0xFFDDDDDD)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                  minimumSize:
                                      const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'CREAR CUENTA',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const PrivacyScreen(),
                                    ),
                                  ),
                                  child: const Text(
                                    'Política de Privacidad',
                                    style: TextStyle(
                                      color: AppColors.textBody,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textBody,
            letterSpacing: 1.5,
          ),
        ),
      );

  InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textBody.withValues(alpha: 0.5)),
        prefixIcon: Icon(icon, size: 20, color: AppColors.textBody),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFEEEEEE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

  Widget _glow(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 80, spreadRadius: 40),
          ],
        ),
      );

  Widget _dash() => Container(
        width: 28,
        height: 1,
        color: AppColors.textBody.withValues(alpha: 0.25),
      );
}
