import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'quran/reader_screen_enhanced.dart';
import 'ai/ai_chat_screen_enhanced.dart';
import 'prayer/prayer_screen_enhanced.dart';
import 'streaming/streaming_screen_enhanced.dart';

// ENHANCED Home Screen with ALL features from spec
class HomeScreenEnhanced extends StatefulWidget {
  @override
  _HomeScreenEnhancedState createState() => _HomeScreenEnhancedState();
}

class _HomeScreenEnhancedState extends State<HomeScreenEnhanced> {
  String dailyAyah = 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ';
  String dailyAyahTranslation = 'Sesungguhnya setiap amalan adalah bergantung kepada niat';
  String dailyAyahRef = 'Sahih al-Bukhari, Hadith 1';
  String dailyZikir = 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ';
  int streakDays = 15;
  
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hijriDate = 'Rabiulawal 1446H'; // TODO: Calculate actual Hijri using hijri package
    
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Al-Quran SuperApp', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF2D5F3F),
        elevation: 0,
        actions: [
          // Streak badge
          Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('$streakDays Hari', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan Hijri Date & Salam
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF2D5F3F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assalamualaikum Warahmatullahi Wabarakatuh',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy').format(now),
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    hijriDate,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Hadith Harian Card (Featured)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2D5F3F), Color(0xFF3D7F5F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                          SizedBox(width: 8),
                          Text('Hadith Harian', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('Sahih', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        dailyAyah,
                        style: TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'Amiri', height: 1.8),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      SizedBox(height: 12),
                      Text(
                        dailyAyahTranslation,
                        style: TextStyle(color: Colors.white70, fontSize: 15, fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(dailyAyahRef, style: TextStyle(color: Colors.white60, fontSize: 12)),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.share_outlined, color: Colors.white70, size: 20),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.bookmark_outline, color: Colors.white70, size: 20),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        'Sumber: myHadith.islam.gov.my (JAKIM)',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Zikir Harian Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.sunny, color: Colors.amber),
                  title: Text('Zikir Pagi', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(dailyZikir, style: TextStyle(fontFamily: 'Amiri', fontSize: 16)),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Quick Access Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Menu Utama', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D5F3F))),
                  SizedBox(height: 16),
                  
                  // Grid Buttons
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildQuickButton(
                        context,
                        icon: Icons.menu_book,
                        label: 'Baca Al-Quran',
                        color: Color(0xFF2D5F3F),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReaderScreenEnhanced())),
                      ),
                      _buildQuickButton(
                        context,
                        icon: Icons.mic_none,
                        label: 'Tanya AI Ustaz',
                        color: Color(0xFF4A7C9D),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIChatScreenEnhanced())),
                      ),
                      _buildQuickButton(
                        context,
                        icon: Icons.schedule,
                        label: 'Waktu Solat',
                        color: Color(0xFF8B5A3C),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrayerScreenEnhanced())),
                      ),
                      _buildQuickButton(
                        context,
                        icon: Icons.play_circle_fill,
                        label: 'Streaming',
                        color: Color(0xFFD35400),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StreamingScreenEnhanced())),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  Text('Fitur Lainnya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D5F3F))),
                  SizedBox(height: 12),
                  
                  // Additional Features
                  ListTile(
                    leading: Icon(Icons.bookmark_outline, color: Color(0xFF2D5F3F)),
                    title: Text('Bookmark Saya'),
                    subtitle: Text('78 ayat disimpan'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.favorite_outline, color: Colors.red),
                    title: Text('Derma & Sedekah'),
                    subtitle: Text('Tabung Masjid & Asnaf'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.people_outline, color: Color(0xFF4A7C9D)),
                    title: Text('Komuniti'),
                    subtitle: Text('Renungan & Dakwah'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.school_outlined, color: Color(0xFF8B5A3C)),
                    title: Text('e-Learning'),
                    subtitle: Text('Kursus Tafsir & Fiqh'),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('JAKIM', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // JAKIM Compliance Footer
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Aplikasi ini mematuhi Garis Panduan JAKIM/JAIS',
                      style: TextStyle(color: Colors.green.shade800, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar (5 tabs)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF2D5F3F),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Al-Quran'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'AI Ustaz'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Solat'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle), label: 'Video'),
        ],
        onTap: (index) {
          if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => ReaderScreenEnhanced()));
          if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => AIChatScreenEnhanced()));
          if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => PrayerScreenEnhanced()));
          if (index == 4) Navigator.push(context, MaterialPageRoute(builder: (_) => StreamingScreenEnhanced()));
        },
      ),
    );
  }
  
  Widget _buildQuickButton(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
