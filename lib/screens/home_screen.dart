
import 'package:flutter/material.dart';
import 'quran/reader_screen.dart';
import 'ai/ai_chat_screen.dart';
import 'prayer/prayer_screen.dart';
import 'streaming/streaming_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Al-Quran SuperApp')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text('Ayat Harian'),
              subtitle: Text('“Innamal a'malu binniyat…” — Al-Bukhari'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            icon: Icon(Icons.menu_book),
            label: Text('Baca Al-Quran'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReaderScreen())),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            icon: Icon(Icons.mic),
            label: Text('Tanya AI Ustaz/Ustazah'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIChatScreen())),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            icon: Icon(Icons.schedule),
            label: Text('Waktu Solat & Qibla'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrayerScreen())),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            icon: Icon(Icons.play_circle_fill),
            label: Text('PeaceTV-style Streaming'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StreamingScreen())),
          ),
        ],
      ),
    );
  }
}
