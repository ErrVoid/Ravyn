import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote.dart';

class QuoteApiService {
  // ZenQuotes API - returns 50 quotes per call
  static const String _zenQuotesUrl = 'https://zenquotes.io/api/quotes';

  /// Fetch 50 quotes from ZenQuotes API
  Future<List<Quote>> fetchQuotes() async {
    try {
      final response = await http.get(Uri.parse(_zenQuotesUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Filter out the "Too many requests" placeholder
        return data
            .where((item) => item['q'] != 'Too many requests. Obtain an auth key for unlimited access.')
            .map((item) => Quote.fromZenQuotes(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch quotes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching quotes: $e');
    }
  }
}
