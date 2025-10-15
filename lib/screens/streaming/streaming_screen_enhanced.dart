import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

// COMPLETE PeaceTV-style Streaming Screen!
class StreamingScreenEnhanced extends StatefulWidget {
  @override
  _StreamingScreenEnhancedState createState() => _StreamingScreenEnhancedState();
}

class _StreamingScreenEnhancedState extends State<StreamingScreenEnhanced> {
  List<VideoCategory> categories = [
    VideoCategory(id: 'aqidah', name: 'Aqidah', icon: '🕌', videoCount: 45),
    VideoCategory(id: 'fiqh', name: 'Fiqh', icon: '📖', videoCount: 78),
    VideoCategory(id: 'akhlak', name: 'Akhlak', icon: '🤝', videoCount: 62),
    VideoCategory(id: 'tafsir', name: 'Tafsir', icon: '📚', videoCount: 120),
    VideoCategory(id: 'sirah', name: 'Sirah', icon: '🕋', videoCount: 35),
    VideoCategory(id: 'motivasi', name: 'Motivasi', icon: '💪', videoCount: 50),
  ];
  
  bool showLiveOnly = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Streaming Ceramah', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFD35400),
        actions: [
          IconButton(
            icon: Icon(showLiveOnly ? Icons.live_tv : Icons.video_library),
            onPressed: () {
              setState(() => showLiveOnly = !showLiveOnly);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Streaming Banner
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.red.shade700],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      'https://via.placeholder.com/400x200',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ceramah Maghrib - Ustaz Abdullah',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tajuk: Adab Menuntut Ilmu • 245 menonton',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: Icon(Icons.play_arrow),
                          label: Text('Tonton Sekarang'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                          ),
                          onPressed: () => _playVideo('live-1'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Categories
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Kategori', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 12),
            
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Container(
                    width: 100,
                    margin: EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () => _openCategory(category),
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(category.icon, style: TextStyle(fontSize: 36)),
                            SizedBox(height: 8),
                            Text(
                              category.name,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '${category.videoCount} video',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: 24),
            
            // Video List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Video Terkini', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {},
                    child: Text('Lihat Semua'),
                  ),
                ],
              ),
            ),
            
            ...List.generate(5, (index) => _buildVideoCard(
              title: 'Pengenalan Aqidah Ahli Sunnah Wal Jamaah',
              speaker: 'Ustaz Dr. Ahmad Fahmi',
              views: '15.4K',
              duration: '47:30',
              thumbnail: 'https://via.placeholder.com/150',
              jakimVerified: true,
            )),
            
            SizedBox(height: 20),
            
            // JAKIM Verification Notice
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
                      'Semua ceramah telah disemak dan diluluskan oleh JAKIM/JAIS',
                      style: TextStyle(color: Colors.green.shade800, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVideoCard({
    required String title,
    required String speaker,
    required String views,
    required String duration,
    required String thumbnail,
    required bool jakimVerified,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _playVideo('video-1'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      thumbnail,
                      width: 120,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 90,
                        color: Colors.grey[300],
                        child: Icon(Icons.play_circle_outline, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        duration,
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(speaker, style: TextStyle(color: Colors.grey, fontSize: 12)),
                        if (jakimVerified) ...[
                          SizedBox(width: 4),
                          Icon(Icons.verified, color: Colors.green, size: 14),
                        ],
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$views tontonan',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              
              IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _openCategory(VideoCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryVideosScreen(category: category),
      ),
    );
  }
  
  void _playVideo(String videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(videoId: videoId),
      ),
    );
  }
}

class VideoCategory {
  final String id;
  final String name;
  final String icon;
  final int videoCount;
  
  VideoCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.videoCount,
  });
}

class CategoryVideosScreen extends StatelessWidget {
  final VideoCategory category;
  
  CategoryVideosScreen({required this.category});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${category.icon} ${category.name}'),
        backgroundColor: Color(0xFFD35400),
      ),
      body: Center(
        child: Text('${category.videoCount} videos in ${category.name}'),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  
  VideoPlayerScreen({required this.videoId});
  
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }
  
  Future<void> _initializePlayer() async {
    // Placeholder video URL
    _videoPlayerController = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    );
    
    await _videoPlayerController!.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      allowFullScreen: true,
    );
    
    setState(() {});
  }
  
  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Video Player
          if (_chewieController != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Chewie(controller: _chewieController!),
            )
          else
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(child: CircularProgressIndicator()),
            ),
          
          // Video Info
          Expanded(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ceramah Maghrib - Ustaz Abdullah',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.verified, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text('JAKIM Verified', style: TextStyle(color: Colors.green, fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Penjelasan lengkap tentang adab menuntut ilmu dalam Islam.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.thumb_up_outlined),
                          label: Text('Suka'),
                          onPressed: () {},
                        ),
                        SizedBox(width: 12),
                        OutlinedButton.icon(
                          icon: Icon(Icons.share),
                          label: Text('Kongsi'),
                          onPressed: () {},
                        ),
                        SizedBox(width: 12),
                        OutlinedButton.icon(
                          icon: Icon(Icons.download),
                          label: Text('Muat Turun'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
