import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/quote_provider.dart';

class MyQuotesScreen extends StatelessWidget {
  const MyQuotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'YOUR QUOTES',
          style: GoogleFonts.cinzel(
            color: Colors.white70,
            fontSize: 16,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF0d0d1a)],
          ),
        ),
        child: Consumer<QuoteProvider>(
          builder: (context, provider, _) {
            final quotes = provider.myQuotes;

            if (quotes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: Colors.white.withValues(alpha: 0.1),
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No personal quotes yet.',
                      style: GoogleFonts.cormorantGaramond(
                        color: Colors.white30,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the pencil button to add yours.',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.2),
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
              itemCount: quotes.length,
              itemBuilder: (context, index) {
                final quote = quotes[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 30),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Dismissible(
                          key: Key(quote.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.red.shade900.withValues(alpha: 0.4),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white54,
                            ),
                          ),
                          onDismissed: (_) {
                            provider.deleteMyQuote(quote.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Quote removed',
                                  style: GoogleFonts.inter(color: Colors.white),
                                ),
                                backgroundColor: Colors.grey.shade900,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.white.withValues(alpha: 0.05),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Genre badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.deepPurple.withValues(alpha: 0.2),
                                  ),
                                  child: Text(
                                    quote.genre.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      color: Colors.deepPurple.shade300,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Quote text
                                Text(
                                  '"${quote.text}"',
                                  style: GoogleFonts.cormorantGaramond(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 20,
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Author
                                Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 0.5,
                                      color: Colors.white24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      quote.author,
                                      style: GoogleFonts.inter(
                                        color: Colors.white38,
                                        fontSize: 12,
                                        letterSpacing: 1,
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
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
