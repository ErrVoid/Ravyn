import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white54, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🪶', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'RAVYN',
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Wisdom in every scroll',
                style: GoogleFonts.cormorantGaramond(
                  color: Colors.white30,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 32),

              Container(
                width: 40,
                height: 1,
                color: Colors.white12,
              ),
              const SizedBox(height: 32),

              _infoRow('Version', '0.0.004a'),
              const SizedBox(height: 16),
              _infoRow('Developer', '@tanish.xii'),
              const SizedBox(height: 16),
              _infoRow('Platform', 'GitHub'),

              const SizedBox(height: 40),

              Text(
                'Built with love & late nights.',
                style: GoogleFonts.cormorantGaramond(
                  color: Colors.white.withValues(alpha: 0.2),
                  fontSize: 14,
                  letterSpacing: 1,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            color: Colors.white24,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
