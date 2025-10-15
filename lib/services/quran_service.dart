import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';

class QuranService {
  static const String baseUrl = 'https://alquran-superapp-fmw4hych5-niagahubs-projects.vercel.app/api';
  
  // Get all surahs
  Future<List<Surah>> getSurahs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/quran/surahs'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Surah.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load surahs');
      }
    } catch (e) {
      print('Error fetching surahs: $e');
      rethrow;
    }
  }
  
  // Get specific surah with ayahs
  Future<Map<String, dynamic>> getSurah(int surahNumber, {String? translation}) async {
    try {
      String url = '$baseUrl/quran/surah/$surahNumber';
      if (translation != null) {
        url += '?translation=$translation';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return {
          'surah': Surah.fromJson(data['surah']),
          'ayahs': (data['ayahs'] as List).map((a) => Ayah.fromJson(a)).toList(),
        };
      } else {
        throw Exception('Failed to load surah');
      }
    } catch (e) {
      print('Error fetching surah: $e');
      rethrow;
    }
  }
  
  // Search ayahs
  Future<List<dynamic>> searchAyahs(String query, {String lang = 'en'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quran/search?q=${Uri.encodeComponent(query)}&lang=$lang')
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['results'];
      } else {
        throw Exception('Search failed');
      }
    } catch (e) {
      print('Error searching ayahs: $e');
      return [];
    }
  }
  
  // Get audio URL
  Future<String> getAudioUrl(int surah, int ayah, {String reciter = 'alafasy'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quran/audio/$surah/$ayah?reciter=$reciter')
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['audio_url'];
      } else {
        throw Exception('Failed to get audio URL');
      }
    } catch (e) {
      print('Error getting audio: $e');
      // Fallback to direct URL
      return 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${surah}_$ayah.mp3';
    }
  }
  
  // Get tafsir
  Future<Tafsir> getTafsir(int surah, int ayah, {String lang = 'en'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quran/tafsir/$surah/$ayah?lang=$lang')
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return Tafsir.fromJson(data['tafsir']);
      } else {
        throw Exception('Failed to get tafsir');
      }
    } catch (e) {
      print('Error getting tafsir: $e');
      rethrow;
    }
  }
}
