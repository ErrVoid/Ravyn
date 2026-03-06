import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/quote_provider.dart';

class RavynDropScreen extends StatefulWidget {
  const RavynDropScreen({super.key});

  @override
  State<RavynDropScreen> createState() => _RavynDropScreenState();
}

class _RavynDropScreenState extends State<RavynDropScreen>
    with TickerProviderStateMixin {
  late AnimationController _featherController;
  late AnimationController _contentController;
  late Animation<double> _featherDrop;
  late Animation<double> _featherFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    // Feather dropping animation
    _featherController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _featherDrop = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(
        parent: _featherController,
        curve: const Interval(0.0, 0.6, curve: Curves.bounceOut),
      ),
    );

    _featherFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _featherController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Content reveal animation
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _glowPulse = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start sequence
    _featherController.forward().then((_) {
      _contentController.forward();
    });

    // Generate drop if not exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuoteProvider>().generateRavynDrop();
    });
  }

  @override
  void dispose() {
    _featherController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a14),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white54, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [
              Color(0xFF1a1040),
              Color(0xFF0d0d1a),
              Color(0xFF050510),
            ],
          ),
        ),
        child: Consumer<QuoteProvider>(
          builder: (context, provider, _) {
            final drop = provider.ravynDrop;

            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Feather animation ──
                    AnimatedBuilder(
                      animation: _featherController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _featherDrop.value),
                          child: Opacity(
                            opacity: _featherFade.value,
                            child: child,
                          ),
                        );
                      },
                      child: const Text('🪶', style: TextStyle(fontSize: 56)),
                    ),

                    const SizedBox(height: 12),

                    // ── Title ──
                    AnimatedBuilder(
                      animation: _featherController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _featherFade,
                          child: child,
                        );
                      },
                      child: Text(
                        'RAVYN DROP',
                        style: GoogleFonts.cinzel(
                          color: Colors.white60,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    AnimatedBuilder(
                      animation: _featherController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _featherFade,
                          child: child,
                        );
                      },
                      child: Text(
                        'Today\'s wisdom',
                        style: GoogleFonts.cormorantGaramond(
                          color: Colors.white24,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // ── Quote Card ──
                    if (drop != null)
                      AnimatedBuilder(
                        animation: _contentController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _contentSlide,
                            child: FadeTransition(
                              opacity: _contentFade,
                              child: child,
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: AnimatedBuilder(
                              animation: _contentController,
                              builder: (context, child) {
                                return Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: Colors.white.withValues(alpha: 0.04),
                                    border: Border.all(
                                      color: Colors.deepPurple.withValues(
                                        alpha: _glowPulse.value * 0.3,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.deepPurple.withValues(
                                          alpha: _glowPulse.value * 0.15,
                                        ),
                                        blurRadius: 40,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: child,
                                );
                              },
                              child: Column(
                                children: [
                                  Text(
                                    '"',
                                    style: GoogleFonts.playfairDisplay(
                                      color: Colors.deepPurple.shade300.withValues(alpha: 0.5),
                                      fontSize: 60,
                                      height: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    drop.text,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cormorantGaramond(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w500,
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    width: 30,
                                    height: 1,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    '— ${drop.author}',
                                    style: GoogleFonts.inter(
                                      color: Colors.white54,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      AnimatedBuilder(
                        animation: _contentController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _contentFade,
                            child: child,
                          );
                        },
                        child: Column(
                          children: [
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.deepPurple,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'The raven is finding your drop...',
                              style: GoogleFonts.cormorantGaramond(
                                color: Colors.white30,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
