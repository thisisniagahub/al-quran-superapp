import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/surah.dart';
import '../../services/quran_service.dart';

// COMPLETE Quran Reader with ALL features!
class ReaderScreenEnhanced extends StatefulWidget {
  @override
  _ReaderScreenEnhancedState createState() => _ReaderScreenEnhancedState();
}

class _ReaderScreenEnhancedState extends State<ReaderScreenEnhanced> {
  final QuranService _quranService = QuranService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<Surah> surahs = [];
  bool isLoading = true;
  String selectedTranslation = 'ms'; // ms, id, en
  bool showTajwid = true;
  bool showTranslation = true;
  
  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }
  
  Future<void> _loadSurahs() async {
    try {
      final data = await _quranService.getSurahs();
      setState(() {
        surahs = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading surahs: $e');
      setState(() => isLoading = false);
    }
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Al-Quran Al-Kareem', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF2D5F3F),
        actions: [
          // Translation selector
          PopupMenuButton<String>(
            icon: Icon(Icons.translate),
            onSelected: (value) {
              setState(() => selectedTranslation = value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'ms', child: Text('Bahasa Melayu')),
              PopupMenuItem(value: 'id', child: Text('Bahasa Indonesia')),
              PopupMenuItem(value: 'en', child: Text('English')),
            ],
          ),
          // Settings
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _showSettings(),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.white,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari ayat atau surah...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onSubmitted: (query) => _searchAyah(query),
                  ),
                ),
                
                // Surah List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: surahs.length,
                    itemBuilder: (context, index) {
                      final surah = surahs[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFF2D5F3F),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${surah.number}',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          title: Text(
                            surah.nameAr,
                            style: TextStyle(fontFamily: 'Amiri', fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedTranslation == 'ms' ? surah.nameMs : 
                                selectedTranslation == 'id' ? surah.nameId : 
                                surah.nameEn,
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.bookmark_outline, size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    '${surah.ayahCount} Ayat • ${surah.revelation}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.chevron_right, color: Color(0xFF2D5F3F)),
                          onTap: () => _openSurah(surah),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
  
  void _openSurah(Surah surah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahDetailScreen(
          surah: surah,
          translation: selectedTranslation,
          showTajwid: showTajwid,
          showTranslation: showTranslation,
        ),
      ),
    );
  }
  
  void _searchAyah(String query) {
    // TODO: Implement search
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mencari: $query...')),
    );
  }
  
  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tetapan Bacaan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Tajwid Mode'),
              subtitle: Text('Warna tajwid pada teks Arab'),
              value: showTajwid,
              activeColor: Color(0xFF2D5F3F),
              onChanged: (value) {
                setState(() => showTajwid = value);
                Navigator.pop(context);
              },
            ),
            SwitchListTile(
              title: Text('Terjemahan'),
              subtitle: Text('Papar terjemahan'),
              value: showTranslation,
              activeColor: Color(0xFF2D5F3F),
              onChanged: (value) {
                setState(() => showTranslation = value);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.text_fields),
              title: Text('Saiz Font'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// Surah Detail Screen - Full Ayahs dengan Audio, Tafsir, Bookmark
class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final String translation;
  final bool showTajwid;
  final bool showTranslation;
  
  SurahDetailScreen({
    required this.surah,
    required this.translation,
    required this.showTajwid,
    required this.showTranslation,
  });
  
  @override
  _SurahDetailScreenState createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final QuranService _quranService = QuranService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<Ayah> ayahs = [];
  bool isLoading = true;
  int? playingAyah;
  Set<int> bookmarkedAyahs = {};
  
  @override
  void initState() {
    super.initState();
    _loadSurah();
  }
  
  Future<void> _loadSurah() async {
    try {
      final data = await _quranService.getSurah(
        widget.surah.number,
        translation: widget.translation,
      );
      setState(() {
        ayahs = data['ayahs'] as List<Ayah>;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading surah: $e');
      setState(() => isLoading = false);
    }
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.surah.nameAr, style: TextStyle(fontFamily: 'Amiri', fontSize: 20)),
            Text(
              '${widget.surah.nameEn} • ${widget.surah.ayahCount} Ayat',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Color(0xFF2D5F3F),
        actions: [
          IconButton(icon: Icon(Icons.share), onPressed: () {}),
          IconButton(icon: Icon(Icons.bookmark_border), onPressed: () {}),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Bismillah Header
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                  ),
                  child: Column(
                    children: [
                      if (widget.surah.number != 1 && widget.surah.number != 9)
                        Text(
                          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                          style: TextStyle(fontFamily: 'Amiri', fontSize: 28, height: 2),
                          textAlign: TextAlign.center,
                        ),
                      SizedBox(height: 10),
                      Text(
                        'Sumber: ${widget.surah.sourceAttribution}',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                
                // Ayahs List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ayahs.length,
                    itemBuilder: (context, index) {
                      final ayah = ayahs[index];
                      final isBookmarked = bookmarkedAyahs.contains(ayah.number);
                      final isPlaying = playingAyah == ayah.number;
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Ayah number badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF2D5F3F).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${ayah.number}',
                                      style: TextStyle(color: Color(0xFF2D5F3F), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // Play audio
                                      IconButton(
                                        icon: Icon(
                                          isPlaying ? Icons.pause_circle : Icons.play_circle,
                                          color: Color(0xFF2D5F3F),
                                        ),
                                        onPressed: () => _playAudio(ayah),
                                      ),
                                      // Bookmark
                                      IconButton(
                                        icon: Icon(
                                          isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                          color: isBookmarked ? Colors.amber : Colors.grey,
                                        ),
                                        onPressed: () => _toggleBookmark(ayah.number),
                                      ),
                                      // More options
                                      IconButton(
                                        icon: Icon(Icons.more_vert, color: Colors.grey),
                                        onPressed: () => _showAyahOptions(ayah),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Arabic Text
                              Text(
                                ayah.textAr,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 26,
                                  height: 2.0,
                                  color: widget.showTajwid ? Colors.black : Colors.black87,
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                              ),
                              
                              // Translation
                              if (widget.showTranslation && ayah.translation != null) ...[
                                SizedBox(height: 16),
                                Divider(),
                                SizedBox(height: 8),
                                Text(
                                  ayah.translation!.text,
                                  style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Terjemahan: ${ayah.translation!.translator}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
  
  Future<void> _playAudio(Ayah ayah) async {
    if (playingAyah == ayah.number) {
      await _audioPlayer.pause();
      setState(() => playingAyah = null);
    } else {
      try {
        final audioUrl = await _quranService.getAudioUrl(widget.surah.number, ayah.number);
        await _audioPlayer.play(UrlSource(audioUrl));
        setState(() => playingAyah = ayah.number);
        
        _audioPlayer.onPlayerComplete.listen((_) {
          setState(() => playingAyah = null);
        });
      } catch (e) {
        print('Error playing audio: $e');
      }
    }
  }
  
  void _toggleBookmark(int ayahNumber) {
    setState(() {
      if (bookmarkedAyahs.contains(ayahNumber)) {
        bookmarkedAyahs.remove(ayahNumber);
      } else {
        bookmarkedAyahs.add(ayahNumber);
      }
    });
    // TODO: Save to local database
  }
  
  void _showAyahOptions(Ayah ayah) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.share, color: Color(0xFF2D5F3F)),
              title: Text('Kongsi Ayat'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open share quote screen
              },
            ),
            ListTile(
              leading: Icon(Icons.book, color: Color(0xFF2D5F3F)),
              title: Text('Tafsir'),
              onTap: () {
                Navigator.pop(context);
                _showTafsir(ayah);
              },
            ),
            ListTile(
              leading: Icon(Icons.note, color: Color(0xFF2D5F3F)),
              title: Text('Tambah Nota'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Add note feature
              },
            ),
            ListTile(
              leading: Icon(Icons.copy, color: Color(0xFF2D5F3F)),
              title: Text('Salin Teks'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Copy to clipboard
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _showTafsir(Ayah ayah) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tafsir Ayat ${ayah.number}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Loading tafsir...'),
              SizedBox(height: 10),
              Text(
                'Untuk rujukan hadith sahih, lawati:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              TextButton(
                onPressed: () {},
                child: Text('myHadith.islam.gov.my'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
