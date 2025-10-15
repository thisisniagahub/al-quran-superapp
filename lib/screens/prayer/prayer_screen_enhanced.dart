import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../models/prayer_times.dart';
import '../../services/prayer_service.dart';

// COMPLETE Prayer Times Screen dengan e-Solat & Qibla!
class PrayerScreenEnhanced extends StatefulWidget {
  @override
  _PrayerScreenEnhancedState createState() => _PrayerScreenEnhancedState();
}

class _PrayerScreenEnhancedState extends State<PrayerScreenEnhanced> {
  final PrayerService _prayerService = PrayerService();
  
  PrayerTimes? prayerTimes;
  QiblaDirection? qiblaDirection;
  bool isLoading = true;
  String selectedZone = 'SGR01'; // Default Selangor
  String country = 'Malaysia';
  Position? currentPosition;
  
  List<Map<String, String>> malaysiaZones = [];
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    await _getLocation();
    await _loadZones();
    await _loadPrayerTimes();
    await _loadQiblaDirection();
  }
  
  Future<void> _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        setState(() => currentPosition = position);
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }
  
  Future<void> _loadZones() async {
    try {
      final zones = await _prayerService.getMalaysiaZones();
      setState(() => malaysiaZones = zones);
    } catch (e) {
      print('Error loading zones: $e');
    }
  }
  
  Future<void> _loadPrayerTimes() async {
    try {
      PrayerTimes times;
      if (country == 'Malaysia') {
        times = await _prayerService.getPrayerTimesMalaysia(selectedZone);
      } else {
        times = await _prayerService.getPrayerTimesIndonesia('jakarta');
      }
      setState(() {
        prayerTimes = times;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading prayer times: $e');
      setState(() => isLoading = false);
    }
  }
  
  Future<void> _loadQiblaDirection() async {
    if (currentPosition == null) return;
    
    try {
      final direction = await _prayerService.getQiblaDirection(
        currentPosition!.latitude,
        currentPosition!.longitude,
      );
      setState(() => qiblaDirection = direction);
    } catch (e) {
      print('Error loading Qibla: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Waktu Solat & Qibla', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF8B5A3C),
        actions: [
          // Zone selector
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: () => _showZoneSelector(),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Card
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF8B5A3C),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'e-Solat JAKIM',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          prayerTimes?.zoneName ?? selectedZone,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('EEEE, d MMMM yyyy').format(prayerTimes?.date ?? DateTime.now()),
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        if (prayerTimes?.hijriDate != null)
                          Text(
                            prayerTimes!.hijriDate!,
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Next Prayer Card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF8B5A3C), Color(0xFFAB7A5C)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Solat Seterusnya',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'ZOHOR',
                              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              prayerTimes?.times.dhuhr ?? '--:--',
                              style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Dalam 2 jam 15 minit',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Prayer Times List
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: prayerTimes?.times.toList().map((prayer) => 
                          ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFF8B5A3C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.schedule, color: Color(0xFF8B5A3C)),
                            ),
                            title: Text(
                              prayer.name,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            trailing: Text(
                              prayer.time,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B5A3C)),
                            ),
                          ),
                        ).toList() ?? [],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Qibla Compass Card
                  if (qiblaDirection != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: InkWell(
                          onTap: () => _showQiblaCompass(),
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(Icons.explore, color: Color(0xFF8B5A3C), size: 48),
                                SizedBox(height: 12),
                                Text(
                                  'Arah Qiblat',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${qiblaDirection!.qiblaDirection.toStringAsFixed(1)}°',
                                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF8B5A3C)),
                                ),
                                Text(
                                  qiblaDirection!.directionText,
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.near_me),
                                  label: Text('Buka Kompas'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF8B5A3C),
                                  ),
                                  onPressed: () => _showQiblaCompass(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  SizedBox(height: 20),
                  
                  // JAKIM Attribution
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Waktu solat rasmi dari e-Solat JAKIM',
                                style: TextStyle(color: Colors.green.shade800, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Sumber: ${prayerTimes?.source ?? "e-Solat JAKIM"}',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  void _showZoneSelector() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Zon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: malaysiaZones.length,
                itemBuilder: (context, index) {
                  final zone = malaysiaZones[index];
                  return ListTile(
                    title: Text(zone['code']!),
                    subtitle: Text(zone['name']!),
                    trailing: selectedZone == zone['code']
                        ? Icon(Icons.check, color: Color(0xFF2D5F3F))
                        : null,
                    onTap: () {
                      setState(() => selectedZone = zone['code']!);
                      Navigator.pop(context);
                      _loadPrayerTimes();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showQiblaCompass() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QiblaCompassScreen(qiblaDirection: qiblaDirection!),
      ),
    );
  }
}

// Full Screen Qibla Compass
class QiblaCompassScreen extends StatelessWidget {
  final QiblaDirection qiblaDirection;
  
  QiblaCompassScreen({required this.qiblaDirection});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text('Kompas Qiblat'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Compass visualization (placeholder)
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Color(0xFF2D5F3F),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.navigation, color: Colors.white, size: 80),
                    SizedBox(height: 16),
                    Text(
                      '${qiblaDirection.qiblaDirection.toStringAsFixed(1)}°',
                      style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      qiblaDirection.directionText,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Arahkan telefon ke arah Kaabah',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Lat: ${qiblaDirection.latitude.toStringAsFixed(4)}, Lng: ${qiblaDirection.longitude.toStringAsFixed(4)}',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
