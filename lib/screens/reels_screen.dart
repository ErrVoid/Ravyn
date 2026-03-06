import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/quote_provider.dart';
import '../models/quote.dart';
import 'add_quote_screen.dart';
import 'ravyn_drop_screen.dart';
import 'my_quotes_screen.dart';
import 'info_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late PageController _pageController;
  bool _imagesPrecached = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuoteProvider>().initialLoad();
      _precacheImages();
    });
  }

  Future<void> _precacheImages() async {
    if (_imagesPrecached) return;
    final provider = context.read<QuoteProvider>();
    for (final bg in provider.allBgImages) {
      if (mounted) {
        precacheImage(AssetImage(bg), context);
      }
    }
    _imagesPrecached = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'RAVYN',
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.white70, size: 21),
            tooltip: 'Ravyn Drop',
            onPressed: () => Navigator.push(context, _fadeRoute(const RavynDropScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.library_books_rounded, color: Colors.white70, size: 21),
            tooltip: 'My Quotes',
            onPressed: () => Navigator.push(context, _fadeRoute(const MyQuotesScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 21),
            tooltip: 'About',
            onPressed: () => Navigator.push(context, _fadeRoute(const InfoScreen())),
          ),
        ],
      ),
      body: Consumer<QuoteProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return _buildLoadingScreen();
          if (provider.quotes.isEmpty) return _buildEmptyScreen();

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: provider.quotes.length,
            onPageChanged: (index) => provider.onPageChanged(index),
            itemBuilder: (context, index) {
              return _QuoteReel(
                quote: provider.quotes[index],
                bgImage: provider.getBgForIndex(index),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple.shade700,
        elevation: 4,
        onPressed: () => Navigator.push(context, _fadeRoute(const AddQuoteScreen())),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🪶', style: TextStyle(fontSize: 48)),
          SizedBox(height: 20),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white10,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.white24, size: 56),
          const SizedBox(height: 16),
          Text(
            'No wisdom found.\nTap + to add your own.',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(color: Colors.white38, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SINGLE QUOTE REEL CARD
// ═══════════════════════════════════════════════════════════════

class _QuoteReel extends StatefulWidget {
  final Quote quote;
  final String bgImage;

  const _QuoteReel({
    required this.quote,
    required this.bgImage,
  });

  @override
  State<_QuoteReel> createState() => _QuoteReelState();
}

class _QuoteReelState extends State<_QuoteReel>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fadeIn;
  late Animation<double> _quoteSlide;
  late Animation<double> _authorFade;
  bool _showShare = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _quoteSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _anim,
        curve: const Interval(0.05, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _authorFade = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.4, 0.85, curve: Curves.easeIn),
    );

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _shareQuote() {
    final q = widget.quote;
    SharePlus.instance.share(
      ShareParams(
        text: '"${q.text}"\n\n— ${q.author}\n\n🪶 Shared via Ravyn',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Background ──
        Image.asset(
          widget.bgImage,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
              ),
            ),
          ),
        ),

        // ── Dark gradient overlay ──
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.5),
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),

        // ── Quote content (long press to share) ──
        GestureDetector(
          onLongPress: () {
            setState(() => _showShare = true);
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) setState(() => _showShare = false);
            });
          },
          onTap: () {
            if (_showShare) setState(() => _showShare = false);
          },
          behavior: HitTestBehavior.translucent,
          child: AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Transform.translate(
                  offset: Offset(0, _quoteSlide.value),
                  child: Opacity(
                    opacity: _fadeIn.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '"',
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white.withValues(alpha: 0.25),
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            height: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.quote.text,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorantGaramond(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Opacity(
                          opacity: _authorFade.value,
                          child: Column(
                            children: [
                              Container(width: 36, height: 1, color: Colors.white24),
                              const SizedBox(height: 12),
                              Text(
                                '— ${widget.quote.author}',
                                style: GoogleFonts.inter(
                                  color: Colors.white60,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white12),
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                                child: Text(
                                  widget.quote.genre.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    color: Colors.white30,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        ),

        // ── Share button (appears on long press) (appears on long press) ──
        if (_showShare)
          Positioned(
            right: 16,
            bottom: 0,
            top: 0,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: GestureDetector(
                  onTap: _shareQuote,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.share_rounded, color: Colors.white70, size: 20),
                  ),
                ),
              ),
            ),
          ),

        // ── User quote badge ──
        if (widget.quote.isUserQuote)
          Positioned(
            top: 100,
            left: 20,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, child) {
                return Opacity(opacity: _authorFade.value, child: child);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.deepPurple.withValues(alpha: 0.25),
                  border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_rounded, color: Colors.deepPurple.shade200, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'YOUR QUOTE',
                      style: GoogleFonts.inter(
                        color: Colors.deepPurple.shade200,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
