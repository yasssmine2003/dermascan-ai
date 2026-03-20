import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'auth_provider.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/social_btn.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      context: context,
    );
    if (ok && mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gradStart, AppColors.gradEnd],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Header
                      _buildHeader(),
                      const SizedBox(height: 36),
                      // Card principale
                      _buildFormCard(),
                      const SizedBox(height: 24),
                      // Divider
                      _buildDivider(),
                      const SizedBox(height: 20),
                      // Boutons sociaux
                      _buildSocialButtons(),
                      const SizedBox(height: 32),
                      // Lien inscription
                      _buildSignUpLink(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        GestureDetector(
          onTap: () => context.go('/onboarding'),
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 18,
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Logo petit
        Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.biotech_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'DermaScan AI',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ]),
        const SizedBox(height: 20),
        const Text(
          'Bon retour ! 👋',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Connectez-vous pour accéder à votre tableau de bord.',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Card du formulaire ──────────────────────────────────────
  Widget _buildFormCard() {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(children: [
          // Message d'erreur
          if (auth.errorMessage != null) ...[
            _ErrorBanner(message: auth.errorMessage!),
            const SizedBox(height: 16),
          ],
          // Email
          AuthTextField(
            label: 'Adresse email',
            hint: 'exemple@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: _emailCtrl,
            onChanged: (_) => auth.clearError(),
          ),
          const SizedBox(height: 18),
          // Mot de passe
          AuthTextField(
            label: 'Mot de passe',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            controller: _passCtrl,
            obscure: auth.obscurePassword,
            onChanged: (_) => auth.clearError(),
            suffix: IconButton(
              icon: Icon(
                auth.obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textHint,
                size: 20,
              ),
              onPressed: auth.togglePassword,
            ),
          ),
          const SizedBox(height: 12),
          // Mot de passe oublié
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: const Text(
                'Mot de passe oublié ?',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Bouton connexion
          _LoginButton(onTap: _onLogin, isLoading: auth.isLoading),
          const SizedBox(height: 16),
          // Biométrie
          _BiometricButton(auth: auth),
        ]),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(children: [
      const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'ou continuer avec',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textHint,
          ),
        ),
      ),
      const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
    ]);
  }

  Widget _buildSocialButtons() {
    return Row(children: [
      Expanded(
        child: SocialBtn(
          label: 'Google',
          icon: _GoogleIcon(),
          onTap: () {},
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: SocialBtn(
          label: 'Apple',
          icon: const Icon(Icons.apple, size: 22, color: Colors.black),
          onTap: () {},
        ),
      ),
    ]);
  }

  Widget _buildSignUpLink() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text(
        'Pas encore de compte ? ',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      GestureDetector(
        onTap: () => context.go('/register'),
        child: const Text(
          'S\'inscrire',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    ]);
  }
}

// ── Sous-widgets Login ────────────────────────────────────────
class _LoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;
  const _LoginButton({required this.onTap, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [AppColors.primaryLight, AppColors.primaryLight]
                : [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Se connecter',
                      style: AppFonts.labelBtn,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _BiometricButton extends StatelessWidget {
  final AuthProvider auth;
  const _BiometricButton({required this.auth});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: auth.toggleBiometric,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: auth.biometricEnabled
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.bgSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: auth.biometricEnabled
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fingerprint_rounded,
              color: auth.biometricEnabled
                  ? AppColors.primary
                  : AppColors.textHint,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              auth.biometricEnabled
                  ? 'Biométrie activée'
                  : 'Connexion biométrique',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: auth.biometricEnabled
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.riskHigh.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.riskHigh.withOpacity(0.25)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded,
            color: AppColors.riskHigh, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: AppColors.riskHigh,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ]),
    );
  }
}

// Icône Google dessinée avec CustomPaint
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(22, 22), painter: _GooglePainter());
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Cercle de fond
    canvas.drawCircle(c, r,
        Paint()..color = const Color(0xFFF5F5F5));

    // Lettre G stylisée
    final segments = [
      (const Color(0xFF4285F4), -90.0, 90.0),
      (const Color(0xFF34A853), 0.0, 90.0),
      (const Color(0xFFFBBC05), 90.0, 90.0),
      (const Color(0xFFEA4335), 180.0, 90.0),
    ];

    for (final seg in segments) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r * 0.72),
        _toRad(seg.$2),
        _toRad(seg.$3),
        false,
        Paint()
          ..color = seg.$1
          ..strokeWidth = 3.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt,
      );
    }

    // Barre horizontale du G
    canvas.drawLine(
      Offset(c.dx, c.dy),
      Offset(c.dx + r * 0.72, c.dy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );
  }

  double _toRad(double deg) => deg * 3.14159 / 180;

  @override
  bool shouldRepaint(_) => false;
}