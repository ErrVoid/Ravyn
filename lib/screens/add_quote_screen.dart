import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/quote_provider.dart';

class AddQuoteScreen extends StatefulWidget {
  const AddQuoteScreen({super.key});

  @override
  State<AddQuoteScreen> createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends State<AddQuoteScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _quoteController = TextEditingController();
  final _authorController = TextEditingController();
  String _selectedGenre = 'wisdom';
  bool _isSaving = false;

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  final List<String> _genres = [
    'wisdom',
    'motivation',
    'mindfulness',
    'love',
    'peace',
    'happiness',
    'strength',
    'inspiration',
    'stress-relief',
    'life',
    'success',
    'nature',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _quoteController.dispose();
    _authorController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _saveQuote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await context.read<QuoteProvider>().addMyQuote(
            _quoteController.text.trim(),
            _authorController.text.trim().isEmpty
                ? 'You'
                : _authorController.text.trim(),
            _selectedGenre,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quote added to the scroll ✨',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.deepPurple.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }

    if (mounted) setState(() => _isSaving = false);
  }

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
          'ADD YOUR WISDOM',
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Quote input
                    _buildLabel('QUOTE'),
                    const SizedBox(height: 8),
                    _buildGlassField(
                      controller: _quoteController,
                      hint: 'Write your thought...',
                      maxLines: 5,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Share your wisdom';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Author input
                    _buildLabel('AUTHOR'),
                    const SizedBox(height: 8),
                    _buildGlassField(
                      controller: _authorController,
                      hint: 'Who said it? (default: You)',
                      maxLines: 1,
                    ),

                    const SizedBox(height: 24),

                    // Genre selector
                    _buildLabel('GENRE'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _genres.map((genre) {
                        final isSelected = _selectedGenre == genre;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedGenre = genre),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isSelected
                                  ? Colors.deepPurple.withValues(alpha: 0.4)
                                  : Colors.white.withValues(alpha: 0.05),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.deepPurple.shade300
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Text(
                              genre,
                              style: GoogleFonts.inter(
                                color: isSelected
                                    ? Colors.deepPurple.shade200
                                    : Colors.white38,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 40),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveQuote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white70,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'DROP IT INTO THE SCROLL',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: Colors.white30,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 3,
      ),
    );
  }

  Widget _buildGlassField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.cormorantGaramond(
            color: Colors.white,
            fontSize: 20,
            height: 1.6,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cormorantGaramond(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 20,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.deepPurple.shade400),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            contentPadding: const EdgeInsets.all(18),
          ),
        ),
      ),
    );
  }
}
