import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'auth_provider.dart';
import 'widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
    // Réinitialise les champs auth à l'ouverture
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().reset();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.register(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      confirmPassword: _confirmCtrl.text,
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
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildFormCard(),
                      const SizedBox(height: 28),
                      _buildLoginLink(),
                      const SizedBox(height: 36),
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
        GestureDetector(
          onTap: () => context.go('/login'),
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 18),
          ),
        ),
        const SizedBox(height: 24),
        Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.biotech_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'DermaScan AI',
            style: TextStyle(
              fontFamily: 'Nunito', fontSize: 16,
              fontWeight: FontWeight.w700, color: AppColors.primary,
            ),
          ),
        ]),
        const SizedBox(height: 20),
        const Text(
          'Créer un compte 🩺',
          style: TextStyle(
            fontFamily: 'Nunito', fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary, height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Rejoignez DermaScan AI pour surveiller votre santé cutanée.',
          style: TextStyle(
            fontFamily: 'Nunito', fontSize: 15,
            color: AppColors.textSecondary, height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Card formulaire ────────────────────────────────────────
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
              blurRadius: 24, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(children: [
          if (auth.errorMessage != null) ...[
            _ErrorBanner(message: auth.errorMessage!),
            const SizedBox(height: 16),
          ],
          // Nom complet
          AuthTextField(
            label: 'Nom complet',
            hint: 'Jean Dupont',
            prefixIcon: Icons.person_outline_rounded,
            controller: _nameCtrl,
            keyboardType: TextInputType.name,
            onChanged: (_) => auth.clearError(),
          ),
          const SizedBox(height: 18),
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
            hint: '••••••••  (min. 8 caractères)',
            prefixIcon: Icons.lock_outline_rounded,
            controller: _passCtrl,
            obscure: auth.obscurePassword,
            onChanged: (_) => auth.clearError(),
            suffix: IconButton(
              icon: Icon(
                auth.obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textHint, size: 20,
              ),
              onPressed: auth.togglePassword,
            ),
          ),
          const SizedBox(height: 18),
          // Confirmer mot de passe
          AuthTextField(
            label: 'Confirmer le mot de passe',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            controller: _confirmCtrl,
            obscure: auth.obscureConfirm,
            onChanged: (_) => auth.clearError(),
            suffix: IconButton(
              icon: Icon(
                auth.obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textHint, size: 20,
              ),
              onPressed: auth.toggleConfirm,
            ),
          ),
          const SizedBox(height: 20),
          // Indicateur de force du mot de passe
          _PasswordStrength(password: _passCtrl.text),
          const SizedBox(height: 20),
          // Checkbox politique de confidentialité
          _PolicyCheckbox(auth: auth),
          const SizedBox(height: 24),
          // Bouton s'inscrire
          _RegisterButton(onTap: _onRegister, isLoading: auth.isLoading),
          const SizedBox(height: 16),
          // Sécurité data
          _SecurityBadge(),
        ]),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text(
        'Déjà un compte ? ',
        style: TextStyle(
          fontFamily: 'Nunito', fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      GestureDetector(
        onTap: () => context.go('/login'),
        child: const Text(
          'Se connecter',
          style: TextStyle(
            fontFamily: 'Nunito', fontSize: 14,
            fontWeight: FontWeight.w700, color: AppColors.primary,
          ),
        ),
      ),
    ]);
  }
}

// ── Indicateur force mot de passe ─────────────────────────────
class _PasswordStrength extends StatelessWidget {
  final String password;
  const _PasswordStrength({required this.password});

  int get _strength {
    if (password.isEmpty) return 0;
    int s = 0;
    if (password.length >= 8) s++;
    if (password.contains(RegExp(r'[A-Z]'))) s++;
    if (password.contains(RegExp(r'[0-9]'))) s++;
    if (password.contains(RegExp(r'[!@#\$&*~]'))) s++;
    return s;
  }

  Color get _color {
    switch (_strength) {
      case 1: return AppColors.riskHigh;
      case 2: return AppColors.riskMedium;
      case 3: return AppColors.riskLow;
      case 4: return AppColors.accent;
      default: return AppColors.border;
    }
  }

  String get _label {
    switch (_strength) {
      case 1: return 'Faible';
      case 2: return 'Moyen';
      case 3: return 'Fort';
      case 4: return 'Très fort';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: Row(children: List.generate(4, (i) {
              final filled = i < _strength;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  height: 4,
                  decoration: BoxDecoration(
                    color: filled ? _color : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            })),
          ),
          const SizedBox(width: 12),
          Text(
            _label,
            style: TextStyle(
              fontFamily: 'Nunito', fontSize: 12,
              fontWeight: FontWeight.w600, color: _color,
            ),
          ),
        ]),
      ],
    );
  }
}

// ── Checkbox politique ────────────────────────────────────────
class _PolicyCheckbox extends StatelessWidget {
  final AuthProvider auth;
  const _PolicyCheckbox({required this.auth});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: auth.togglePolicy,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: auth.acceptPolicy
                  ? AppColors.primary
                  : AppColors.bgWhite,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: auth.acceptPolicy
                    ? AppColors.primary
                    : AppColors.border,
                width: 1.5,
              ),
            ),
            child: auth.acceptPolicy
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Nunito', fontSize: 13,
                  color: AppColors.textSecondary, height: 1.5,
                ),
                children: [
                  TextSpan(text: 'J\'accepte la '),
                  TextSpan(
                    text: 'politique de confidentialité',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' et les '),
                  TextSpan(
                    text: 'conditions d\'utilisation',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' de DermaScan AI.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bouton inscription ────────────────────────────────────────
class _RegisterButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;
  const _RegisterButton({required this.onTap, required this.isLoading});

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
                : [AppColors.primary, AppColors.accent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.30),
              blurRadius: 16, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.2),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Créer mon compte', style: AppFonts.labelBtn),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Badge sécurité ────────────────────────────────────────────
class _SecurityBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined,
              color: AppColors.primary, size: 16),
          SizedBox(width: 8),
          Text(
            'Données chiffrées · Conformité RGPD',
            style: TextStyle(
              fontFamily: 'Nunito', fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bannière d'erreur ─────────────────────────────────────────
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
        border: Border.all(color: AppColors.riskHigh.withOpacity(0.25)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded,
            color: AppColors.riskHigh, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Nunito', fontSize: 13,
              color: AppColors.riskHigh, fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ]),
    );
  }
}