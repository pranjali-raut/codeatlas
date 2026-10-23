import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'register.dart';
/// CodeAtlas login screen.
///
/// Usage:
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => const LoginPage()),
/// );
///
/// Connect authentication by passing [onLogin]. Validate the selected role
/// against the user's trusted role stored in your backend/Firestore rules;
/// do not grant permissions based only on the role selected in this UI.
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.onLogin,
    this.onForgotPassword,
  });

  final Future<void> Function(
    String username,
    String password,
    String role,
  )? onLogin;

  final VoidCallback? onForgotPassword;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'Developer';
  bool _obscurePassword = true;
  bool _isLoading = false;

  static const _background = Color(0xFFFCFAFF);
  static const _panel = Color(0xFFFFFFFF);
  static const _blue = Color(0xFFB8C0FF);
  static const _purple = Color(0xFFC8B6FF);
  static const _muted = Color(0xFF6D6883);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future <void> login() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    final uid = credential.user!.uid;

    // Read the trusted role from Firestore.
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!userDoc.exists) {
      await FirebaseAuth.instance.signOut();
      throw Exception('User profile not found. Contact your administrator.');
    }

    final storedRole = userDoc.data()!['role'] as String?;

    if (storedRole != _selectedRole) {
      await FirebaseAuth.instance.signOut();
      throw Exception('Please select your registered role.');
    }

    // AuthWrapper will navigate automatically after successful login.
  } on FirebaseAuthException catch (e) {
    String message;

    switch (e.code) {
      case 'invalid-email':
        message = 'Please enter a valid email address.';
        break;
      case 'user-not-found':
      case 'invalid-credential':
        message = 'Invalid email or password.';
        break;
      case 'wrong-password':
        message = 'Invalid email or password.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      case 'network-request-failed':
        message = 'Network error. Check your internet connection.';
        break;
      default:
        message = 'Login failed. Please try again.';
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    // The profile check or another non-authentication operation failed.
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          const Positioned(
            top: -110,
            right: -90,
            child: _GlowOrb(size: 300, color: _purple),
          ),
          const Positioned(
            bottom: -130,
            left: -100,
            child: _GlowOrb(size: 320, color: _blue),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 470),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBrand(),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          color: _panel.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFFE7C6FF).withValues(alpha: 0.65),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC8B6FF).withValues(alpha: 0.24),
                              blurRadius: 35,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Welcome back',
                                style: TextStyle(
                                  color: const Color(0xFF29243D),
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.7,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Sign in to continue your journey through the codebase.',
                                style: TextStyle(
                                  color: _muted,
                                  height: 1.5,
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(height: 27),
                              _fieldLabel('USERNAME'),
                              const SizedBox(height: 9),
                              TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.username],
                                style: const TextStyle(color: Color(0xFF172342)),
                                decoration: _inputDecoration(
                                  hint: 'Enter your username',
                                  icon: Icons.person_outline_rounded,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 19),
                              _fieldLabel('PASSWORD'),
                              const SizedBox(height: 9),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => login(),
                                style: const TextStyle(color: Color(0xFF172342)),
                                decoration: _inputDecoration(
                                  hint: 'Enter your password',
                                  icon: Icons.lock_outline_rounded,
                                  suffix: IconButton(
                                    tooltip: _obscurePassword
                                        ? 'Show password'
                                        : 'Hide password',
                                    onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword,
                                    ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: _muted,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 19),
                              _fieldLabel('SIGN IN AS'),
                              const SizedBox(height: 10),
                              _buildRoleSelector(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: widget.onForgotPassword ??
                                      () => ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Connect your password reset flow here.',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF9DB1FF),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildLoginButton(),
                                const SizedBox(height: 12),
                                _buildRegisterButton(),
                                const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Expanded(child: Divider(color: Color(0xFF2B3650))),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'CODE KNOWLEDGE, CONNECTED',
                                      style: TextStyle(
                                        color: Color(0xFF7382A4),
                                        fontSize: 9,
                                        letterSpacing: 1.4,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Color(0xFF2B3650))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Understand the code. Find your direction.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8290B0),
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFFFFD6FF), const Color(0xFFB8C0FF), const Color(0xFFBBD0FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: _blue.withValues(alpha: 0.25),
                blurRadius: 25,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_tree_rounded,
            color: const Color(0xFF4B416B),
            size: 34,
          ),
        ),
        const SizedBox(height: 15),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Code',
                style: TextStyle(color: Color(0xFF172342)),
              ),
              TextSpan(
                text: 'Atlas',
                style: TextStyle(color: Color(0xFF7562B8)),
              ),
            ],
          ),
          style: TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.1,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'YOUR CODEBASE, MAPPED.',
          style: TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.3,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFB8C3DE),
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.3,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF71809F), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF766C91), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF7F9FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF263452)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF263452)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _blue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF718B)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF718B), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Color(0xFFFF91A5), fontSize: 11),
    );
  }

  Widget _buildRoleSelector() {
    const roles = [
      _RoleOption(
        title: 'Admin',
        subtitle: 'Manage',
        icon: Icons.admin_panel_settings_outlined,
      ),
      _RoleOption(
        title: 'Team Leader',
        subtitle: 'Guide',
        icon: Icons.groups_2_outlined,
      ),
      _RoleOption(
        title: 'Developer',
        subtitle: 'Build',
        icon: Icons.code_rounded,
      ),
    ];

    return Row(
      children: [
        for (final role in roles)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: role.title == 'Developer' ? 0 : 8,
              ),
              child: _RoleTile(
                role: role,
                selected: _selectedRole == role.title,
                onTap: () => setState(() => _selectedRole = role.title),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [const Color(0xFFFFD6FF), const Color(0xFFB8C0FF), const Color(0xFFBBD0FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF4B416B)),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      color: const Color(0xFF29243D),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, color: const Color(0xFF29243D), size: 19),
                ],
              ),
      ),
    );
  }
Widget _buildRegisterButton() {
  return Center(
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Color(0xFF6D6883),
            fontSize: 12.5,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RegisterPage(),
              ),
            );
          },
          child: const Text(
            'Register',
            style: TextStyle(
              color: Color(0xFF7562B8),
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}

}

class _RoleOption {
  const _RoleOption({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final _RoleOption role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? const Color(0xFF9A8AE0)
        : const Color(0xFF263452);
    final foreground = selected
        ? const Color(0xFF40517A)
        : const Color(0xFF687694);

    return Semantics(
      button: true,
      selected: selected,
      label: '${role.title} role',
      child: Material(
        color: selected
            ? const Color(0xFFE8EDFF)
            : const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(role.icon, color: foreground, size: 22),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    role.title,
                    style: TextStyle(
                      color: const Color(0xFF243252),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  role.subtitle,
                  style: TextStyle(
                    color: foreground.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 7),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? 18 : 5,
                  height: 4,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF9EABFF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.13),
              blurRadius: 100,
              spreadRadius: 35,
            ),
          ],
        ),
      ),
    );
  }
}
