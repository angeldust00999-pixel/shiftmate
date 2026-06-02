import 'package:flutter/material.dart';

import '../../core/preferences/pref_helper.dart';
import '../../widgets/custom/report_widgets.dart';
import '../dashboard/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;
  bool showPassword = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final username = usernameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username tidak boleh kosong')),
      );
      return;
    }

    await PrefHelper.saveLoginSession(username);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DashboardPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ReportColors.navyDeep,
                ReportColors.navy,
                Color(0xFF1A3A6A),
              ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          const _LoginHero(),
                          const SizedBox(height: 34),
                          Expanded(
                            child: _LoginFormCard(
                              usernameController: usernameController,
                              passwordController: passwordController,
                              rememberMe: rememberMe,
                              showPassword: showPassword,
                              onRememberChanged: () {
                                setState(() => rememberMe = !rememberMe);
                              },
                              onTogglePassword: () {
                                setState(() => showPassword = !showPassword);
                              },
                              onLogin: login,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ReportColors.brown.withOpacity(0.07),
                boxShadow: [
                  BoxShadow(
                    color: ReportColors.brown.withOpacity(0.16),
                    blurRadius: 42,
                    spreadRadius: 12,
                  ),
                ],
              ),
            ),
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.25, -0.3),
                  colors: [
                    ReportColors.brownLight,
                    ReportColors.brown,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ReportColors.brown.withOpacity(0.35),
                    blurRadius: 50,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_cafe_outlined,
                color: ReportColors.cream,
                size: 50,
              ),
            ),
            Positioned(
              top: -28,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _SteamLine(height: 30, delay: 0),
                  SizedBox(width: 18),
                  _SteamLine(height: 36, delay: 1),
                  SizedBox(width: 18),
                  _SteamLine(height: 30, delay: 2),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text(
          'ShiftMate Café',
          style: TextStyle(
            color: ReportColors.cream,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Manage your café, your way',
          style: TextStyle(
            color: ReportColors.muted,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _SteamLine extends StatelessWidget {
  final double height;

  const _SteamLine({required this.height, int delay = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            ReportColors.cream.withOpacity(0.35),
            ReportColors.cream.withOpacity(0.02),
          ],
        ),
      ),
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool showPassword;
  final VoidCallback onRememberChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  const _LoginFormCard({
    required this.usernameController,
    required this.passwordController,
    required this.rememberMe,
    required this.showPassword,
    required this.onRememberChanged,
    required this.onTogglePassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back',
            style: TextStyle(
              color: ReportColors.cream,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sign in to your account',
            style: TextStyle(
              color: ReportColors.muted,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 34),
          _LoginInputField(
            label: 'USERNAME',
            controller: usernameController,
            hintText: 'Enter your username',
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 22),
          _LoginInputField(
            label: 'PASSWORD',
            controller: passwordController,
            hintText: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscureText: !showPassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onLogin(),
            suffix: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: ReportColors.muted,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              GestureDetector(
                onTap: onRememberChanged,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 46,
                  height: 27,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: rememberMe
                        ? ReportColors.green
                        : Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    alignment: rememberMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 21,
                      height: 21,
                      decoration: BoxDecoration(
                        color: ReportColors.cream,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.28),
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Remember me',
                style: TextStyle(
                  color: ReportColors.muted,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Silakan hubungi admin untuk reset password'),
                    ),
                  );
                },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: ReportColors.brownLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: onLogin,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: ReportColors.brownLight,
                foregroundColor: ReportColors.cream,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hubungi admin café Anda')),
                );
              },
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: ReportColors.muted,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(text: 'Need help? Contact your '),
                    TextSpan(
                      text: 'Admin',
                      style: TextStyle(
                        color: ReportColors.brownLight,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _LoginInputField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ReportColors.muted,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          cursorColor: ReportColors.brownLight,
          style: const TextStyle(
            color: ReportColors.cream,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: ReportColors.muted.withOpacity(0.56),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            prefixIcon: Icon(
              icon,
              color: ReportColors.muted,
              size: 24,
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white.withOpacity(0.055),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.11)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.11), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: ReportColors.brownLight, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
