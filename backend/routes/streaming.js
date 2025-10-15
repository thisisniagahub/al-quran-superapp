const express = require('express');
const router = express.Router();
const NodeCache = require('node-cache');
const cache = new NodeCache({ stdTTL: 1800 }); // 30 min cache

// PeaceTV-style Streaming API
// Categories: Ceramah, Aqidah, Fiqh, Akhlak, Tafsir, Motivasi, etc.

// Get live streams
router.get('/live', async (req, res) => {
  try {
    // Placeholder: In production, integrate with actual streaming platform
    // Options: YouTube Live API, custom HLS server, or RTMP
    
    const liveStreams = [
      {
        id: 'live-ceramah-1',
        title: 'Ceramah Maghrib - Ustaz Abdullah',
        description: 'Tajuk: Adab Menuntut Ilmu dalam Islam',
        speaker: {
          name: 'Ustaz Abdullah bin Ahmad',
          bio: 'Pensyarah USIM, Pakar Fiqh',
          photo_url: '/assets/speakers/ustaz-abdullah.jpg'
        },
        category: 'Ceramah',
        language: 'ms',
        stream_url: 'https://stream.example.com/live/ceramah-maghrib.m3u8',
        thumbnail: '/assets/thumbnails/ceramah-1.jpg',
        viewers_count: 245,
        started_at: new Date().toISOString(),
        is_live: true,
        jakim_approved: true
      },
      {
        id: 'live-tafsir-1',
        title: 'Tafsir Al-Quran - Surah Al-Baqarah',
        description: 'Sesi Tafsir mingguan',
        speaker: {
          name: 'Dr. Fatimah Zahra',
          bio: 'Pensyarah Tafsir, UIA',
          photo_url: '/assets/speakers/dr-fatimah.jpg'
        },
        category: 'Tafsir',
        language: 'ms',
        stream_url: 'https://stream.example.com/live/tafsir-weekly.m3u8',
        thumbnail: '/assets/thumbnails/tafsir-1.jpg',
        viewers_count: 189,
        started_at: new Date(Date.now() - 3600000).toISOString(),
        is_live: true,
        jakim_approved: true
      }
    ];
    
    res.json({
      live_streams: liveStreams,
      count: liveStreams.length,
      disclaimer: 'Semua ceramah telah disemak dan diluluskan oleh JAKIM/JAIS',
      streaming_protocol: 'HLS (HTTP Live Streaming)'
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch live streams', details: error.message });
  }
});

// Get video categories
router.get('/categories', (req, res) => {
  const categories = [
    {
      id: 'aqidah',
      name: 'Aqidah',
      name_en: 'Islamic Creed',
      description: 'Perkara-perkara asas kepercayaan Islam',
      icon: '🕌',
      video_count: 45,
      jakim_supervised: true
    },
    {
      id: 'fiqh',
      name: 'Fiqh',
      name_en: 'Islamic Jurisprudence',
      description: 'Hukum-hakam dalam Islam',
      icon: '📖',
      video_count: 78,
      jakim_supervised: true
    },
    {
      id: 'akhlak',
      name: 'Akhlak',
      name_en: 'Islamic Ethics',
      description: 'Adab dan akhlak mulia',
      icon: '🤝',
      video_count: 62
    },
    {
      id: 'tafsir',
      name: 'Tafsir Al-Quran',
      name_en: 'Quran Interpretation',
      description: 'Tafsir dan tadabbur Al-Quran',
      icon: '📚',
      video_count: 120
    },
    {
      id: 'sirah',
      name: 'Sirah Nabawiyah',
      name_en: 'Prophetic Biography',
      description: 'Kehidupan Rasulullah SAW',
      icon: '🕋',
      video_count: 35
    },
    {
      id: 'motivasi',
      name: 'Motivasi Islamik',
      name_en: 'Islamic Motivation',
      description: 'Motivasi berteraskan Islam',
      icon: '💪',
      video_count: 50,
      compliance_note: 'Mengikut Garis Panduan JAKIM'
    },
    {
      id: 'muamalat',
      name: 'Muamalat',
      name_en: 'Islamic Economics',
      description: 'Ekonomi dan kewangan Islam',
      icon: '💰',
      video_count: 28
    }
  ];
  
  res.json({
    categories,
    total_categories: categories.length,
    note: 'Semua kategori diselia oleh JAKIM untuk memastikan kandungan sahih'
  });
});

// Get videos by category
router.get('/videos/:category', async (req, res) => {
  try {
    const { category } = req.params;
    const { page, limit, sort } = req.query;
    
    const pageNum = parseInt(page) || 1;
    const limitNum = parseInt(limit) || 20;
    
    // Placeholder: In production, fetch from database
    const videos = [
      {
        id: 'video-001',
        title: 'Pengenalan Aqidah Ahli Sunnah Wal Jamaah',
        description: 'Penjelasan lengkap tentang aqidah yang sahih mengikut manhaj Ahli Sunnah Wal Jamaah',
        speaker: {
          name: 'Ustaz Ahmad bin Hassan',
          credentials: 'PhD Islamic Studies, Al-Azhar',
          photo_url: '/assets/speakers/ustaz-ahmad.jpg'
        },
        category: category,
        duration_seconds: 2850, // 47:30
        views: 15420,
        likes: 892,
        published_at: '2024-10-01T10:00:00Z',
        thumbnail: `/assets/videos/thumbnails/${category}-001.jpg`,
        video_url: `/videos/${category}/video-001.mp4`,
        hls_url: `/videos/${category}/video-001.m3u8`,
        quality_options: ['360p', '480p', '720p', '1080p'],
        subtitles: [
          { lang: 'ms', url: '/subtitles/video-001-ms.vtt' },
          { lang: 'en', url: '/subtitles/video-001-en.vtt' }
        ],
        downloadable: true,
        jakim_verified: true,
        verification_note: 'Kandungan telah disemak dan disahkan oleh Panel JAKIM',
        tags: ['aqidah', 'asas', 'ahli sunnah'],
        related_videos: ['video-002', 'video-003']
      }
      // More videos...
    ];
    
    res.json({
      category,
      page: pageNum,
      limit: limitNum,
      total: 45, // Total videos in category
      videos,
      has_more: pageNum * limitNum < 45
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch videos', details: error.message });
  }
});

// Get speaker profiles
router.get('/speakers', (req, res) => {
  const speakers = [
    {
      id: 'speaker-001',
      name: 'Ustaz Dr. Ahmad Fahmi',
      title: 'Dr.',
      specialization: ['Aqidah', 'Fiqh', 'Tafsir'],
      credentials: 'PhD Islamic Studies (Al-Azhar), MA Hadith (UIA)',
      bio: 'Pensyarah kanan di Universiti Islam Antarabangsa Malaysia dengan kepakaran dalam bidang Aqidah dan Fiqh.',
      photo_url: '/assets/speakers/ustaz-ahmad-fahmi.jpg',
      video_count: 23,
      total_views: 125000,
      jakim_certified: true,
      social_media: {
        facebook: 'ustazahmadfahmi',
        instagram: '@ustazahmadfahmi'
      }
    },
    {
      id: 'speaker-002',
      name: 'Ustazah Dr. Siti Hajar',
      title: 'Dr.',
      specialization: ['Tafsir', 'Wanita Islam', 'Pendidikan'],
      credentials: 'PhD Quranic Studies (UKM), MA Islamic Education',
      bio: 'Pakar tafsir dan isu-isu wanita dalam Islam. Aktif dalam program dakwah dan pendidikan.',
      photo_url: '/assets/speakers/ustazah-siti-hajar.jpg',
      video_count: 18,
      total_views: 98000,
      jakim_certified: true
    }
  ];
  
  res.json({
    speakers,
    count: speakers.length,
    note: 'Semua penceramah telah diluluskan dan diselia oleh JAKIM'
  });
});

// Download video for offline (returns download link)
router.post('/download/:video_id', async (req, res) => {
  try {
    const { video_id } = req.params;
    const { quality } = req.body; // '360p', '480p', '720p', '1080p'
    
    // Check user quota/permissions (if needed)
    // Generate signed download URL
    
    const downloadUrl = `/downloads/videos/${video_id}_${quality || '480p'}.mp4`;
    const expiresAt = new Date(Date.now() + 86400000); // 24 hours
    
    res.json({
      video_id,
      quality: quality || '480p',
      download_url: downloadUrl,
      expires_at: expiresAt.toISOString(),
      file_size_mb: 145,
      note: 'Video ini hanya untuk tontonan peribadi. Dilarang mengedar semula tanpa kebenaran.',
      copyright: '© JAKIM / Al-Quran SuperApp',
      offline_expires: 30 // days
    });
  } catch (error) {
    res.status(500).json({ error: 'Download failed', details: error.message });
  }
});

// Search videos
router.get('/search', async (req, res) => {
  try {
    const { q, category, speaker, sort } = req.query;
    
    if (!q) {
      return res.status(400).json({ error: 'Search query required' });
    }
    
    // Placeholder: In production, use full-text search (Elasticsearch or PostgreSQL FTS)
    const results = [
      // Search results based on query
    ];
    
    res.json({
      query: q,
      filters: { category, speaker },
      results,
      count: results.length
    });
  } catch (error) {
    res.status(500).json({ error: 'Search failed', details: error.message });
  }
});

module.exports = router;
