import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'register_screen.dart'; // Pastikan file ini ada

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // Konstanta animasi
  static const double _maxDragDistance = 300.0;
  static const double _dragThreshold = 150.0;
  static const Duration _resetDuration = Duration(milliseconds: 300);
  static const Duration _arrowAnimDuration = Duration(milliseconds: 800);
  
  // Variabel state
  double _dragOffset = 0.0;
  bool _isNavigating = false;
  
  // Controllers dan animations
  late AnimationController _arrowAnimationController;
  late Animation<Offset> _arrowAnimation;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animasi arrow
    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: _arrowAnimDuration,
    )..repeat(reverse: true);

    _arrowAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.3), // Sedikit lebih besar range animasinya
    ).animate(CurvedAnimation(
      parent: _arrowAnimationController,
      curve: Curves.easeInOut,
    ));

    // Setup controller untuk reset posisi
    _resetController = AnimationController(
      vsync: this,
      duration: _resetDuration,
    );
    
    // Setup listener untuk animasi reset
    _resetController.addListener(_updateDragOffsetFromAnimation);
  }

  @override
  void dispose() {
    _resetController.removeListener(_updateDragOffsetFromAnimation);
    _arrowAnimationController.dispose();
    _resetController.dispose();
    super.dispose();
  }
  
  // Listener callback untuk animasi reset
  void _updateDragOffsetFromAnimation() {
    setState(() {
      _dragOffset = _resetAnimation.value;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isNavigating) return;
    
    setState(() {
      // Update drag offset dan clamp ke batasan
      _dragOffset += details.delta.dy;
      _dragOffset = _dragOffset.clamp(-_maxDragDistance, 0.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    // Jika sedang navigasi, jangan proses
    if (_isNavigating) return;
    
    // Cek apakah threshold terlampaui atau velocity cukup tinggi (swipe cepat)
    final bool shouldNavigate = 
        _dragOffset < -_dragThreshold || 
        details.primaryVelocity != null && details.primaryVelocity! < -1000.0; // Threshold velocity untuk swipe cepat
    
    if (shouldNavigate) {
      _navigateToRegisterScreen();
    } else {
      _resetPosition();
    }
  }
  
  // REFACTOR 1: Logika navigasi dipisahkan ke dalam method sendiri
  void _navigateToRegisterScreen() {
    setState(() {
      _isNavigating = true;
    });
    
    // Berikan feedback haptic untuk memberi tahu user
    HapticFeedback.mediumImpact();

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const RegisterScreen(),
        transitionsBuilder: (_, animation, __, child) {
          // Gunakan ease out bounce untuk efek lebih menarik
          final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutBack));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    ).then((_) {
      // Reset state saat kembali dari RegisterScreen
      setState(() {
        _isNavigating = false;
        _dragOffset = 0.0;
      });
    });
  }
  
  void _resetPosition() {
    // Buat animasi untuk kembali ke posisi awal dengan efek bounce
    _resetAnimation = Tween<double>(begin: _dragOffset, end: 0.0).animate(
      CurvedAnimation(
        parent: _resetController, 
        curve: Curves.easeOutBack, // Menggunakan curve dengan efek bounce
      ),
    );
    
    // Mulai animasi
    _resetController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Hitung progress dalam range 0.0 - 1.0 untuk animasi dan efek visual
    final swipeProgress = (-_dragOffset / _dragThreshold).clamp(0.0, 1.0);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1C2331),
      body: GestureDetector(
        // Hapus batasan area drag agar seluruh screen dapat di-drag
        behavior: HitTestBehavior.translucent, // Memastikan semua area dapat menerima gesture
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        child: Stack(
          fit: StackFit.expand, // Memastikan stack mengisi seluruh layar
          children: [
            // Content yang bergerak saat swipe
            Transform.translate(
              offset: Offset(0, _dragOffset),
              child: SafeArea(
                bottom: true, // Pastikan safe area di bagian bawah
                maintainBottomViewPadding: true, // Pertahankan padding untuk keyboard
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Gunakan layout builder untuk mendapatkan ukuran yang tersedia
                      return Column(
                        children: [
                          // Section untuk logo - Adaptive height
                          SizedBox(
                            height: constraints.maxHeight * 0.28,
                            child: Center(
                              child: Transform.scale(
                                scale: 1.0 - (swipeProgress * 0.1),
                                child: Image.asset(
                                  'assets/images/logo_itemin.png',
                                  height: constraints.maxHeight * 0.14,
                                  width: screenWidth * 0.5,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          
                          // Section untuk welcome text - Adaptive height
                          SizedBox(
                            height: constraints.maxHeight * 0.28,
                            child: Center(
                              child: Opacity(
                                opacity: 1.0 - swipeProgress,
                                child: const Text(
                                  'WELCOME',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Section untuk swipe indicator - Expanded untuk mengisi sisa ruang
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end, // Letakkan di bagian bawah section
                              children: [
                                // Arrow dengan animasi
                                SlideTransition(
                                  position: _arrowAnimation,
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 200),
                                    scale: swipeProgress > 0.9 ? 1.2 : 1.0, // Perbesar ikon saat progress penuh
                                    child: Icon(
                                      // Ganti ikon menjadi tanda centang saat siap release
                                      swipeProgress > 0.9 
                                        ? Icons.keyboard_double_arrow_up 
                                        : Icons.keyboard_arrow_up,
                                      color: swipeProgress > 0.9 
                                        ? Colors.blue // Ubah warna saat mendekati penuh
                                        : Colors.white,
                                      size: 36, // Ukuran ikon dikurangi sedikit
                                    ),
                                  ),
                                ),
                                
                                // Gunakan SizedBox dengan ukuran adaptif
                                SizedBox(height: constraints.maxHeight * 0.02),
                                
                                // Progress bar indikator
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 80, // Sedikit lebih lebar
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withAlpha(76), // 0.3 * 255 = 76.5
                                    borderRadius: BorderRadius.circular(3),
                                    // Tambahkan efek glow saat mendekati penuh
                                    boxShadow: swipeProgress > 0.9 
                                      ? [
                                          BoxShadow(
                                            color: Colors.blue.withAlpha(70),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          )
                                        ] 
                                      : null,
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: swipeProgress,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        // Ubah warna menjadi lebih terang saat mendekati penuh
                                        color: swipeProgress > 0.9 ? Colors.blue : Colors.white,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: constraints.maxHeight * 0.02),
                                
                                // Text petunjuk yang berubah berdasarkan progress
                                Text(
                                  // Jika progress mendekati penuh (> 0.9), tampilkan "Release to continue"
                                  swipeProgress > 0.9 ? 'Release to continue' : 'Swipe up to continue',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    // Ubah warna menjadi lebih terang saat mendekati penuh
                                    color: swipeProgress > 0.9 ? Colors.white : Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                
                                // Padding di bagian bawah untuk memberi ruang - lebih kecil dan adaptif
                                SizedBox(height: constraints.maxHeight * 0.03),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ),
            ),
            
            // Efek overlay yang muncul saat swipe
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withAlpha((swipeProgress * 51).toInt()), // 0.2 * 255 = 51
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}