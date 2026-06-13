import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title
          Text(
            'Profile & Settings',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),

          // User Visual Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Profile Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2),
                      width: 1.5,
                    ),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCDEZhxa1Xo04jzw_qGZ7JP4GkZf9iZOdNqE0O4yfEHbqpcGEeNLPBDAETJAdxu2fcMly9SbaNn89twYIp_psWM7Q0Zow5ONtEXVV1drN3Hp8XOCmwnEolQ7pAKcBlHcZ5VgNHW2Wgy0cl__ieNkSwFXW21u9eZI5oSEKoC_dl14dqPoiuZD8svseBOQthhdRUDEj0HnIzYYZ2UssszLafokMScqHZIcSyr952l69xzhXaVHhs5_EI305YEcbpQnac_0h0QxYCVsPk',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.profile.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appState.profile.email,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit Icon
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  onPressed: () {
                    _showEditProfileDialog(context, appState);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Options Header
          Text(
            'App Preferences',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Preferences List
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildToggleItem(
                  icon: Icons.sync,
                  label: 'Automatic Cloud Sync',
                  value: appState.isSynced,
                  onChanged: (val) async {
                    await appState.toggleSync(val);
                  },
                ),
                const Divider(color: AppTheme.outlineVariant, height: 1),
                _buildToggleItem(
                  icon: Icons.fingerprint,
                  label: 'Biometric Lock',
                  value: appState.isSecurityEnabled,
                  onChanged: (val) async {
                    await appState.toggleSecurity(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Tools Header
          Text(
            'Financial Tools',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Tools List
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildNavigationItem(
                  context: context,
                  icon: Icons.speed_outlined,
                  label: 'Budgeting & Limits',
                  routeName: '/budgeting-limits',
                ),
                const Divider(color: AppTheme.outlineVariant, height: 1),
                _buildNavigationItem(
                  context: context,
                  icon: Icons.category_outlined,
                  label: 'Manage Categories',
                  routeName: '/manage-categories',
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Danger zone
          Text(
            'Account Actions',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildActionItem(
                  icon: Icons.delete_forever_outlined,
                  label: 'Reset Ledger Data',
                  textColor: AppTheme.error,
                  onTap: () {
                    _showClearDataConfirm(context, appState);
                  },
                ),
                const Divider(color: AppTheme.outlineVariant, height: 1),
                _buildActionItem(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  textColor: AppTheme.onSurface,
                  onTap: () async {
                    await appState.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/auth',
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withOpacity(0.3),
            inactiveThumbColor: AppTheme.onSurfaceVariant.withOpacity(0.8),
            inactiveTrackColor: AppTheme.surfaceContainerHigh,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String routeName,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.outline,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: textColor.withOpacity(0.8), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.outline.withOpacity(0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController(text: state.profile.name);
    final emailCtrl = TextEditingController(text: state.profile.email);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: AppTheme.surfaceDim,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppTheme.primary.withOpacity(0.12)),
            ),
            title: const Text('Edit Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppTheme.outline,
                    ),
                    labelText: 'Full Name',
                    labelStyle: const TextStyle(color: AppTheme.outline),
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.mail_outline,
                      color: AppTheme.outline,
                    ),
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(color: AppTheme.outline),
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: AppTheme.onSurfaceVariant),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await state.updateProfile(
                    nameCtrl.text.trim(),
                    emailCtrl.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearDataConfirm(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: AppTheme.surfaceDim,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppTheme.primary.withOpacity(0.12)),
            ),
            title: const Text('Reset App Ledger?'),
            content: const Text(
              'This action will permanently delete all your custom categories, logged transactions, and restore default state. Do you wish to proceed?',
              style: TextStyle(color: AppTheme.onSurfaceVariant),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: AppTheme.onSurfaceVariant),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await state.clearAllData();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ledger data reset successful.'),
                        backgroundColor: AppTheme.surfaceContainerHigh,
                      ),
                    );
                  }
                },
                child: const Text(
                  'RESET',
                  style: TextStyle(
                    color: AppTheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
