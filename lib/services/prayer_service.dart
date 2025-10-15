import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_times.dart';

class PrayerService {
  static const String baseUrl = 'https://alquran-superapp-2blcgadtq-niagahubs-projects.vercel.app/api';
  
  // Get prayer times for Malaysia (e-Solat JAKIM)
  Future<PrayerTimes> getPrayerTimesMalaysia(String zone, {DateTime? date}) async {
    try {
      String dateStr = date != null 
          ? date.toIso8601String().split('T')[0] 
          : DateTime.now().toIso8601String().split('T')[0];
      
      final response = await http.get(
        Uri.parse('$baseUrl/prayer/times/malaysia?zone=$zone&date=$dateStr')
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return PrayerTimes.fromJson(data);
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
      rethrow;
    }
  }
  
  // Get prayer times for Indonesia
  Future<PrayerTimes> getPrayerTimesIndonesia(String city, {DateTime? date}) async {
    try {
      String dateStr = date != null 
          ? date.toIso8601String().split('T')[0] 
          : DateTime.now().toIso8601String().split('T')[0];
      
      final response = await http.get(
        Uri.parse('$baseUrl/prayer/times/indonesia?city=$city&date=$dateStr')
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return PrayerTimes.fromJson(data);
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
      rethrow;
    }
  }
  
  // Get Qibla direction
  Future<QiblaDirection> getQiblaDirection(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prayer/qibla?lat=$lat&lng=$lng')
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return QiblaDirection.fromJson(data);
      } else {
        throw Exception('Failed to get Qibla direction');
      }
    } catch (e) {
      print('Error getting Qibla: $e');
      rethrow;
    }
  }
  
  // Get Malaysia zones
  Future<List<Map<String, String>>> getMalaysiaZones() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prayer/zones/malaysia')
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return (data['zones'] as List).map((z) => {
          'code': z['code'] as String,
          'name': z['name'] as String,
        }).toList();
      } else {
        throw Exception('Failed to load zones');
      }
    } catch (e) {
      print('Error fetching zones: $e');
      return [];
    }
  }
}
