import 'package:flutter/material.dart';
import 'package:app_locker360/data/datasources/hive_service.dart';
import 'package:google_fonts/google_fonts.dart';

/// شاشة الإعداد الأولي (Onboarding)
/// تظهر فقط عند تثبيت التطبيق لأول مرة
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to PIN setup
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PinSetupPage()),
      );
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentPage < 2)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: _skipToEnd,
                    child: Text(
                      'تخطي',
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 56),

            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _buildWelcomePage(),
                  _buildFeaturesPage(),
                  _buildSecurityPage(),
                ],
              ),
            ),

            // Page indicators
            _buildPageIndicators(),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildActionButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon with gradient background
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 70,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),

            // Welcome title
            Text(
              'مرحباً بك في',
              style: GoogleFonts.cairo(
                fontSize: 24,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ).createShader(bounds),
              child: Text(
                'App Locker 360',
                style: GoogleFonts.cairo(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              'حماية متقدمة لتطبيقاتك وملفاتك الشخصية\nمع أمان من الدرجة الأولى',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.white60,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesPage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              'مميزات قوية',
              style: GoogleFonts.cairo(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'كل ما تحتاجه لحماية خصوصيتك',
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.white60),
            ),
            const SizedBox(height: 48),

            // Features list
            _buildFeatureItem(
              icon: Icons.apps_rounded,
              title: 'قفل التطبيقات',
              description: 'حماية تطبيقاتك برمز سري أو بصمة',
              gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            const SizedBox(height: 24),
            _buildFeatureItem(
              icon: Icons.folder_rounded,
              title: 'خزنة الملفات',
              description: 'إخفاء وتشفير صورك وفيديوهاتك',
              gradient: const [Color(0xFFF093FB), Color(0xFFF5576C)],
            ),
            const SizedBox(height: 24),
            _buildFeatureItem(
              icon: Icons.camera_alt_rounded,
              title: 'كشف المتطفلين',
              description: 'التقاط صورة لمن يحاول فتح تطبيقاتك',
              gradient: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityPage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Security icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FACFE).withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),

            // Title
            Text(
              'أمان من الدرجة الأولى',
              style: GoogleFonts.cairo(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'نستخدم أحدث تقنيات التشفير لحماية بياناتك.\nخصوصيتك هي أولويتنا القصوى.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.white60,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),

            // Security features
            _buildSecurityBadge('تشفير AES-256'),
            const SizedBox(height: 12),
            _buildSecurityBadge('حماية بالبصمة'),
            const SizedBox(height: 12),
            _buildSecurityBadge('بدون إعلانات'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF4FACFE).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF4FACFE),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: _currentPage == index
                ? const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  )
                : null,
            color: _currentPage == index ? null : Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _currentPage < 2 ? 'التالي' : 'ابدأ الآن',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// صفحة إنشاء الرمز السري الرئيسي
class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _showError = false;

  void _onNumberPressed(String number) {
    setState(() {
      _showError = false;
      if (!_isConfirming) {
        if (_pin.length < 4) {
          _pin += number;
          if (_pin.length == 4) {
            // Move to confirmation
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() {
                _isConfirming = true;
              });
            });
          }
        }
      } else {
        if (_confirmPin.length < 4) {
          _confirmPin += number;
          if (_confirmPin.length == 4) {
            // Check if PINs match
            _validatePin();
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      _showError = false;
      if (!_isConfirming) {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      }
    });
  }

  void _validatePin() {
    if (_pin == _confirmPin) {
      // Save PIN and complete onboarding
      _savePinAndComplete();
    } else {
      // Show error and reset
      setState(() {
        _showError = true;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _confirmPin = '';
          _showError = false;
        });
      });
    }
  }

  Future<void> _savePinAndComplete() async {
    // Get current settings
    final settings = HiveService.getGlobalSettings();

    // Update with new PIN and mark onboarding as complete
    final updatedSettings = settings.copyWith(
      masterPin: _pin, // في التطبيق الحقيقي، استخدم hash
      hasCompletedOnboarding: true,
    );

    await HiveService.updateGlobalSettings(updatedSettings);

    // Navigate to home (replace with your home page)
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Title
              Text(
                _isConfirming ? 'تأكيد الرمز السري' : 'إنشاء رمز سري',
                style: GoogleFonts.cairo(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isConfirming
                    ? 'أدخل الرمز مرة أخرى للتأكيد'
                    : 'أدخل رمز سري مكون من 4 أرقام',
                style: GoogleFonts.cairo(fontSize: 16, color: Colors.white60),
              ),

              const SizedBox(height: 60),

              // PIN dots
              _buildPinDots(),

              if (_showError) ...[
                const SizedBox(height: 20),
                Text(
                  'الرمز غير متطابق، حاول مرة أخرى',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.redAccent,
                  ),
                ),
              ],

              const Spacer(),

              // Number pad
              _buildNumberPad(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    final currentPin = _isConfirming ? _confirmPin : _pin;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: index < currentPin.length
                ? const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  )
                : null,
            color: index < currentPin.length ? null : Colors.white24,
            border: Border.all(
              color: _showError
                  ? Colors.redAccent
                  : (index < currentPin.length
                        ? Colors.transparent
                        : Colors.white24),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        _buildNumberRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildNumberRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildNumberRow(['7', '8', '9']),
        const SizedBox(height: 16),
        _buildNumberRow(['', '0', 'delete']),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return const SizedBox(width: 80, height: 80);
        }
        if (number == 'delete') {
          return _buildNumberButton(
            child: const Icon(Icons.backspace_outlined, color: Colors.white),
            onPressed: _onDeletePressed,
          );
        }
        return _buildNumberButton(
          child: Text(
            number,
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          onPressed: () => _onNumberPressed(number),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton({
    required Widget child,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Center(child: child),
      ),
    );
  }
}

/// Placeholder home page - replace with your actual home page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Locker 360')),
      body: const Center(
        child: Text('Home Page - Replace with your actual home page'),
      ),
    );
  }
}
