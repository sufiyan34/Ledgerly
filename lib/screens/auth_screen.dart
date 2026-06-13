import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppState>(context, listen: false);

    if (_isLogin) {
      await appState.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      await appState.signup(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(16),
                      bgOpacity: 0.5,
                      child: const Text(
                        'L',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App Name
                  Text(
                    'Ledgerly',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? 'Welcome back to Frozen Light'
                        : 'Start your financial journey',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 36),

                  // Auth Fields
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name Field (Only Sign Up)
                        if (!_isLogin) ...[
                          Text(
                            'FULL NAME',
                            style: textTheme.labelMedium?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: AppTheme.onSurface),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: AppTheme.outline,
                              ),
                              hintText: 'John Doe',
                              hintStyle: const TextStyle(
                                color: AppTheme.onSurfaceVariant,
                              ),
                              filled: true,
                              fillColor: AppTheme.surfaceContainer,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Email Field
                        Text(
                          'EMAIL ADDRESS',
                          style: textTheme.labelMedium?.copyWith(fontSize: 10),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppTheme.onSurface),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.mail_outline,
                              color: AppTheme.outline,
                            ),
                            hintText: 'alex.rivera@ledgerly.com',
                            hintStyle: const TextStyle(
                              color: AppTheme.onSurfaceVariant,
                            ),
                            filled: true,
                            fillColor: AppTheme.surfaceContainer,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(val.trim())) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        Text(
                          'PASSWORD',
                          style: textTheme.labelMedium?.copyWith(fontSize: 10),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: AppTheme.onSurface),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppTheme.outline,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppTheme.outline,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            hintText: '••••••••',
                            hintStyle: const TextStyle(
                              color: AppTheme.onSurfaceVariant,
                            ),
                            filled: true,
                            fillColor: AppTheme.surfaceContainer,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        // Forgot Password Link (Only Login)
                        if (_isLogin) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/forgot-password',
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                        ],

                        const SizedBox(height: 16),
                        // Submit Button
                        GestureDetector(
                          onTap: _submit,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            child: Text(
                              _isLogin ? 'SIGN IN' : 'SIGN UP',
                              style: const TextStyle(
                                color: AppTheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Toggle Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: const TextStyle(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _formKey.currentState?.reset();
                          });
                        },
                        child: Text(
                          _isLogin ? 'Sign Up' : 'Sign In',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
