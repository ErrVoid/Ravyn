import 'dart:math';
import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/quote_api_service.dart';
import '../services/firestore_service.dart';

class QuoteProvider extends ChangeNotifier {
  final QuoteApiService _apiService = QuoteApiService();
  final FirestoreService _firestoreService = FirestoreService();
  final Random _random = Random();

  List<Quote> _quotes = [];
  List<Quote> _myQuotes = [];
  Quote? _ravynDrop;
  bool _isLoading = false;
  bool _isFetchingMore = false;
  String? _error;
  int _currentIndex = 0;

  final List<String> _bgImages = [
    'bgs/bg (1).jpg',
    ...List.generate(21, (i) => 'bgs/bg (${i + 14}).jpg'),
  ];
  late List<String> _shuffledBgs;

  QuoteProvider() {
    _shuffledBgs = List.from(_bgImages)..shuffle(_random);
  }

  // ─── Getters ───
  List<String> get allBgImages => _bgImages;
  List<Quote> get quotes => _quotes;
  List<Quote> get myQuotes => _myQuotes;
  Quote? get ravynDrop => _ravynDrop;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentIndex => _currentIndex;

  /// Get background for index (cycles through shuffled list)
  String getBgForIndex(int index) {
    return _shuffledBgs[index % _shuffledBgs.length];
  }

  /// Reshuffle backgrounds
  void reshuffleBgs() {
    _shuffledBgs = List.from(_bgImages)..shuffle(_random);
  }

  // ═══════════════════════════════════════════════════
  //  INITIAL LOAD
  // ═══════════════════════════════════════════════════

  Future<void> initialLoad() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try Firestore first
      final storedQuotes = await _firestoreService.loadApiQuotes(limit: 50);

      if (storedQuotes.length >= 20) {
        _quotes = storedQuotes..shuffle(_random);
      } else {
        // Fetch from API and save
        await _fetchAndSaveQuotes();
      }

      // Load user quotes
      _myQuotes = await _firestoreService.loadMyQuotes();

      // Load Ravyn Drop
      _ravynDrop = await _firestoreService.getTodaysRavynDrop();
    } catch (e) {
      _error = e.toString();
      // Generate fallback quotes if everything fails
      _quotes = _fallbackQuotes();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════
  //  FETCH & SAVE FROM API
  // ═══════════════════════════════════════════════════

  Future<void> _fetchAndSaveQuotes() async {
    final apiQuotes = await _apiService.fetchQuotes();
    if (apiQuotes.isNotEmpty) {
      await _firestoreService.saveApiQuotes(apiQuotes);
      _quotes.addAll(apiQuotes);
      _quotes = _quotes.toSet().toList()..shuffle(_random);
    }
  }

  // ═══════════════════════════════════════════════════
  //  PREFETCH WHEN RUNNING LOW
  // ═══════════════════════════════════════════════════

  Future<void> onPageChanged(int index) async {
    _currentIndex = index;
    notifyListeners();

    // When user is 10 quotes away from end, fetch more
    if (index >= _quotes.length - 10 && !_isFetchingMore) {
      _isFetchingMore = true;
      try {
        await _fetchAndSaveQuotes();
        reshuffleBgs();
      } catch (_) {
        // Silently fail — we still have quotes to show
      }
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════
  //  USER QUOTES (my_quotes collection)
  // ═══════════════════════════════════════════════════

  Future<void> addMyQuote(String text, String author, String genre) async {
    final quote = Quote(
      id: '',
      text: text,
      author: author,
      genre: genre,
      isUserQuote: true,
      createdAt: DateTime.now(),
    );
    await _firestoreService.addMyQuote(quote);
    _myQuotes = await _firestoreService.loadMyQuotes();

    // Also add to the main reel feed
    _quotes.insert(_random.nextInt(_quotes.length.clamp(1, 999999)), quote);
    notifyListeners();
  }

  Future<void> deleteMyQuote(String id) async {
    await _firestoreService.deleteMyQuote(id);
    _myQuotes.removeWhere((q) => q.id == id);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════
  //  RAVYN DROP
  // ═══════════════════════════════════════════════════

  Future<void> generateRavynDrop() async {
    if (_ravynDrop != null) return; // Already have one for today

    try {
      final quotes = await _apiService.fetchQuotes();
      if (quotes.isNotEmpty) {
        final drop = quotes[_random.nextInt(quotes.length)];
        await _firestoreService.saveRavynDrop(drop);
        _ravynDrop = drop;
        notifyListeners();
      }
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════
  //  FALLBACK
  // ═══════════════════════════════════════════════════

  List<Quote> _fallbackQuotes() {
    return [
      Quote(id: 'f1', text: 'The only way to do great work is to love what you do.', author: 'Steve Jobs', genre: 'motivation'),
      Quote(id: 'f2', text: 'In the middle of difficulty lies opportunity.', author: 'Albert Einstein', genre: 'wisdom'),
      Quote(id: 'f3', text: 'What you think, you become. What you feel, you attract.', author: 'Buddha', genre: 'mindfulness'),
      Quote(id: 'f4', text: 'The mind is everything. What you think you become.', author: 'Buddha', genre: 'mindfulness'),
      Quote(id: 'f5', text: 'Happiness is not something ready made. It comes from your own actions.', author: 'Dalai Lama', genre: 'happiness'),
      Quote(id: 'f6', text: 'You must be the change you wish to see in the world.', author: 'Mahatma Gandhi', genre: 'inspiration'),
      Quote(id: 'f7', text: 'The best time to plant a tree was 20 years ago. The second best time is now.', author: 'Chinese Proverb', genre: 'wisdom'),
      Quote(id: 'f8', text: 'Peace comes from within. Do not seek it without.', author: 'Buddha', genre: 'peace'),
      Quote(id: 'f9', text: 'Breathe. Let go. And remind yourself that this very moment is the only one you know you have for sure.', author: 'Oprah Winfrey', genre: 'mindfulness'),
      Quote(id: 'f10', text: 'Almost everything will work again if you unplug it for a few minutes, including you.', author: 'Anne Lamott', genre: 'stress-relief'),
    ];
  }
}
