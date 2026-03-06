import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quote.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── API Quotes Collection ───
  CollectionReference get _quotesCollection => _db.collection('quotes');

  // ─── User's Own Quotes Collection ───
  CollectionReference get _myQuotesCollection => _db.collection('my_quotes');

  // ─── Ravyn Drop Collection ───
  CollectionReference get _ravynDropCollection => _db.collection('ravyn_drop');

  // ═══════════════════════════════════════════════════
  //  API QUOTES
  // ═══════════════════════════════════════════════════

  /// Save a batch of API-fetched quotes to Firestore (skip duplicates)
  Future<int> saveApiQuotes(List<Quote> quotes) async {
    int savedCount = 0;
    final batch = _db.batch();

    for (final quote in quotes) {
      // Use a deterministic ID based on quote text to avoid duplicates
      final docId = quote.text.hashCode.toRadixString(16);
      final docRef = _quotesCollection.doc(docId);
      batch.set(docRef, quote.toMap(), SetOptions(merge: true));
      savedCount++;
    }

    await batch.commit();
    return savedCount;
  }

  /// Load quotes from Firestore (paginated)
  Future<List<Quote>> loadApiQuotes({int limit = 50, DocumentSnapshot? lastDoc}) async {
    Query query = _quotesCollection
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Quote.fromFirestore(doc)).toList();
  }

  /// Get count of stored API quotes
  Future<int> getApiQuoteCount() async {
    final snapshot = await _quotesCollection.count().get();
    return snapshot.count ?? 0;
  }

  // ═══════════════════════════════════════════════════
  //  USER'S OWN QUOTES
  // ═══════════════════════════════════════════════════

  /// Add a custom user quote
  Future<void> addMyQuote(Quote quote) async {
    await _myQuotesCollection.add(quote.toMap());
  }

  /// Load all user quotes
  Future<List<Quote>> loadMyQuotes() async {
    final snapshot = await _myQuotesCollection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Quote.fromFirestore(doc)).toList();
  }

  /// Delete a user quote
  Future<void> deleteMyQuote(String id) async {
    await _myQuotesCollection.doc(id).delete();
  }

  /// Update a user quote
  Future<void> updateMyQuote(String id, Quote quote) async {
    await _myQuotesCollection.doc(id).update(quote.toMap());
  }

  // ═══════════════════════════════════════════════════
  //  RAVYN DROP (Daily Quote)
  // ═══════════════════════════════════════════════════

  /// Save today's Ravyn Drop
  Future<void> saveRavynDrop(Quote quote) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    await _ravynDropCollection.doc(dateKey).set({
      'text': quote.text,
      'author': quote.author,
      'genre': quote.genre,
      'date': dateKey,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get today's Ravyn Drop
  Future<Quote?> getTodaysRavynDrop() async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final doc = await _ravynDropCollection.doc(dateKey).get();
    if (doc.exists) {
      return Quote.fromFirestore(doc);
    }
    return null;
  }
}
