import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Ask AI Ustaz/Ustazah
  Future<Map<String, dynamic>> askUstaz(String question, {String language = 'ms'}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/ask-ustaz'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'question': question,
          'language': language,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get AI response');
      }
    } catch (e) {
      print('Error asking AI: $e');
      return {
        'answer': 'Maaf, terdapat masalah. Sila rujuk https://myhadith.islam.gov.my atau https://e-fatwa.gov.my',
        'error': true,
      };
    }
  }
  
  // Verify Hadith
  Future<Map<String, dynamic>> verifyHadith(String hadithText) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/verify-hadith'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'hadith_text': hadithText}),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Verification failed');
      }
    } catch (e) {
      print('Error verifying hadith: $e');
      rethrow;
    }
  }
  
  // Semantic Quran Search
  Future<List<dynamic>> semanticSearch(String query, {String language = 'ms'}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/quran-semantic-search'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'query': query,
          'language': language,
        }),
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['results'];
      } else {
        return [];
      }
    } catch (e) {
      print('Error in semantic search: $e');
      return [];
    }
  }
  
  // Tadabbur Suggestions (verses based on emotion/context)
  Future<List<dynamic>> getTadabburSuggestions(String emotion, {String context = ''}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/tadabbur'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'emotion': emotion,
          'context': context,
        }),
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['suggested_verses'];
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting tadabbur: $e');
      return [];
    }
  }
}
