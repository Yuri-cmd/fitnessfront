import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';
import 'package:fit_tracker_app/core/widgets/neon_button.dart';
import 'package:fit_tracker_app/core/widgets/app_icon_badge.dart';
import 'package:fit_tracker_app/features/auth/presentation/controllers/auth_controller.dart';
import 'privacy_screen.dart';
import 'register_screen.dart';
import 'support_screen.dart';
import 'package:fit_tracker_app/core/services/version_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _didTriggerBiometric = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) VersionService.checkAndPrompt(context);
      _tryAutoLaunchBiometric();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _tryAutoLaunchBiometric() {
    if (!mounted || _didTriggerBiometric) return;
    final auth = Get.find<AuthController>();
    if (auth.isBiometricEnabled.value && auth.isBiometricAvailable.value) {
      _didTriggerBiometric = true;
      _loginWithBiometrics();
    }
  }

  Future<void> _loginWithBiometrics() async {
    final success = await Get.find<AuthController>().loginWithBiometrics();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            'No se pudo verificar la identidad. Ingresa con tu contraseña.'),
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = Get.find<AuthController>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Credenciales incorrectas. Intenta de nuevo.'),
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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

                      // ── Hero ──────────────────────────────────────
                      SlideTransition(
                        position: _slideHero,
                        child: FadeTransition(
                          opacity: _fadeHero,
                          child: Column(
                            children: [
                              const AppIconBadge(
                                icon: Icons.fitness_center_rounded,
                                size: 96,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'POWER STACK',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 4,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  _dash(isDark),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      'DOMINA TU ENTRENAMIENTO',
                                      style: TextStyle(
                                        fontSize: 9,
                                        letterSpacing: 2.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  _dash(isDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.07),

                      // ── Form ──────────────────────────────────────
                      SlideTransition(
                        position: _slideForm,
                        child: FadeTransition(
                          opacity: _fadeForm,
                          child: Form(
                            key: _formKey,
                            child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              _label('CORREO ELECTRÓNICO'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType:
                                    TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.email
                                ],
                                decoration: _inputDeco(
                                  hint: 'ejemplo@correo.com',
                                  icon: Icons.alternate_email_rounded,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Ingresa tu correo';
                                  }
                                  if (!v.contains('@') || !v.contains('.')) {
                                    return 'Correo inválido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _label('CONTRASEÑA'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.password
                                ],
                                onFieldSubmitted: (_) => _login(),
                                decoration: _inputDeco(
                                  hint: '••••••••',
                                  icon: Icons.lock_outline_rounded,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons
                                              .visibility_off_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() =>
                                        _obscurePassword =
                                            !_obscurePassword),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Ingresa tu contraseña';
                                  }
                                  if (v.length < 6) {
                                    return 'Mínimo 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.secondary,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 4),
                                    minimumSize: const Size(0, 36),
                                  ),
                                  child: const Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Obx(() => NeonButton(
                                    label: 'INGRESAR',
                                    onTap: _login,
                                    isLoading: auth.isLoading.value,
                                    colors: const [
                                      AppColors.primary,
                                      Color(0xFF8BB52E),
                                    ],
                                  )),
                              Obx(() {
                                final show = auth.isBiometricAvailable
                                        .value &&
                                    auth.isBiometricEnabled.value;
                                if (!show) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: OutlinedButton.icon(
                                    onPressed: auth.isLoading.value
                                        ? null
                                        : _loginWithBiometrics,
                                    icon: const Icon(
                                        Icons.fingerprint_rounded,
                                        size: 22),
                                    label: const Text(
                                      'INGRESAR CON BIOMÉTRICO',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5),
                                      minimumSize:
                                          const Size(double.infinity, 55),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  Expanded(
                                      child: Divider(
                                          color: Theme.of(context)
                                              .dividerColor)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text('o',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            fontSize: 13)),
                                  ),
                                  Expanded(
                                      child: Divider(
                                          color: Theme.of(context)
                                              .dividerColor)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () => Get.to(
                                    () => const RegisterScreen()),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5),
                                  minimumSize:
                                      const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () => Get.to(
                                        () => const PrivacyScreen()),
                                    child: const Text('Privacidad',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  Text('·',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                                  TextButton(
                                    onPressed: () => Get.to(
                                        () => const SupportScreen()),
                                    child: const Text('Soporte',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
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
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
      );

  InputDecoration _inputDeco(
          {required String hint, required IconData icon, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

  Widget _glow(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 40)],
        ),
      );

  Widget _dash(bool isDark) => Container(
        width: 28,
        height: 1,
        color: isDark
            ? Colors.white24
            : AppColors.textBody.withValues(alpha: 0.25),
      );
}
