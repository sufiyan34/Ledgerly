import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      title: 'Financial Clarity Redefined',
      description:
          'Track all your daily expenses and income in a secure, unified environment. Experience modern budgeting.',
      icon: Icons.account_balance_wallet,
    ),
    OnboardingSlideData(
      title: 'Smart Spending Limits',
      description:
          'Create custom monthly budgets for specific categories. Get visual alerts when you are close to your boundaries.',
      icon: Icons.speed,
    ),
    OnboardingSlideData(
      title: 'Cloud-Sync & Security',
      description:
          'Rest easy with automatic cloud sync and secure local biometric encryption options protecting your financial records.',
      icon: Icons.cloud_done,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() async {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.completeOnboarding();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () async {
                    final appState = Provider.of<AppState>(
                      context,
                      listen: false,
                    );
                    await appState.completeOnboarding();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/auth');
                    }
                  },
                  child: Text(
                    'SKIP',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glassmorphic Icon Container
                        GlassCard(
                          borderRadius: 36,
                          bgOpacity: 0.4,
                          borderOpacity: 0.1,
                          padding: const EdgeInsets.all(32),
                          child: Icon(
                            slide.icon,
                            size: 64,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                              color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Page Indicators & Next Button
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primary
                              : AppTheme.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // CTA button
                  GestureDetector(
                    onTap: _onNext,
                    child: GlassCard(
                      borderRadius: 16.0,
                      bgOpacity: 0.8,
                      borderOpacity: 0.2,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          _currentPage == _slides.length - 1
                              ? 'GET STARTED'
                              : 'CONTINUE',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingSlideData {
  final String title;
  final String description;
  final IconData icon;

  OnboardingSlideData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
