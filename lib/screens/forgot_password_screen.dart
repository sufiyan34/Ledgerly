import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _isSubmitted
                ? _buildSuccessView(textTheme)
                : _buildFormView(textTheme),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(TextTheme textTheme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon Card
          Center(
            child: GlassCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: const Icon(
                Icons.lock_reset,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Reset Password',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Enter the email address associated with your account, and we'll send you a link to reset your password.",
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 36),

          // Form
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                const SizedBox(height: 24),
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
                    child: const Text(
                      'SEND RESET LINK',
                      style: TextStyle(
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
        ],
      ),
    );
  }

  Widget _buildSuccessView(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Icon
        Center(
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(24),
            hasGlow: true,
            child: const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppTheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Check Your Inbox',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "We've sent a password reset link to:\n${_emailController.text.trim()}",
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(height: 1.4),
        ),
        const SizedBox(height: 48),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: GlassCard(
            borderRadius: 14,
            bgOpacity: 0.8,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'BACK TO LOGIN',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
