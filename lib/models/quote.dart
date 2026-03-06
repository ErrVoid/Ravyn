import 'package:cloud_firestore/cloud_firestore.dart';

class Quote {
  final String id;
  final String text;
  final String author;
  final String genre;
  final bool isUserQuote;
  final DateTime? createdAt;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    this.genre = 'general',
    this.isUserQuote = false,
    this.createdAt,
  });

  factory Quote.fromZenQuotes(Map<String, dynamic> json) {
    return Quote(
      id: '',
      text: json['q'] ?? '',
      author: json['a'] ?? 'Unknown',
      genre: 'wisdom',
      isUserQuote: false,
      createdAt: DateTime.now(),
    );
  }

  factory Quote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Quote(
      id: doc.id,
      text: data['text'] ?? '',
      author: data['author'] ?? 'Unknown',
      genre: data['genre'] ?? 'general',
      isUserQuote: data['isUserQuote'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'author': author,
      'genre': genre,
      'isUserQuote': isUserQuote,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          author == other.author;

  @override
  int get hashCode => text.hashCode ^ author.hashCode;
}
