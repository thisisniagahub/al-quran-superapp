const express = require('express');
const router = express.Router();

// Community Features: Feed, Reflections, Donations, Islamic Events

// Get community feed (reflections, quotes, etc.)
router.get('/feed', async (req, res) => {
  try {
    const { page, limit } = req.query;
    
    const feed = [
      {
        id: 'post-001',
        type: 'reflection',
        user: {
          id: 'user-123',
          name: 'Ahmad',
          avatar: '/avatars/user-123.jpg',
          badge: 'Hafiz Muda' // Gamification badge
        },
        content: 'Renungan pagi: Surah Al-Baqarah ayat 286 mengingatkan kita bahawa Allah tidak memberikan beban melebihi kemampuan kita. SubhanAllah!',
        related_ayah: {
          surah: 2,
          ayah: 286,
          text_ar: 'لَا يُكَلِّفُ ٱللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
          translation: 'Allah tidak membebani seseorang melainkan sesuai dengan kesanggupannya'
        },
        likes: 45,
        comments: 8,
        shares: 12,
        created_at: new Date(Date.now() - 3600000).toISOString(),
        moderation_status: 'approved'
      }
    ];
    
    res.json({
      feed,
      page: parseInt(page) || 1,
      has_more: true,
      moderation_note: 'Semua post disemak untuk mematuhi adab Islam'
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch feed', details: error.message });
  }
});

// Post reflection/quote
router.post('/post', async (req, res) => {
  try {
    const { user_id, content, ayah_reference, type } = req.body;
    
    // Validate content using JAKIM compliance
    const JAKIMValidator = require('../compliance/jakim_validator');
    const validation = JAKIMValidator.validateContent(content, 'social_post');
    
    if (!validation.is_compliant) {
      return res.status(400).json({
        error: 'Kandungan melanggar garis panduan JAKIM',
        violations: validation.violations,
        action: 'Sila semak semula kandungan anda'
      });
    }
    
    // Create post (pending moderation)
    const newPost = {
      id: 'post-' + Date.now(),
      user_id,
      content,
      ayah_reference,
      type: type || 'reflection',
      moderation_status: 'pending',
      created_at: new Date().toISOString()
    };
    
    res.json({
      success: true,
      post: newPost,
      message: 'Post anda akan disemak terlebih dahulu sebelum dipaparkan',
      moderation_sla: '24 jam'
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create post', details: error.message });
  }
});

// Donation Hub
router.get('/donations', (req, res) => {
  const causes = [
    {
      id: 'donation-001',
      title: 'Tabung Pembinaan Masjid Ar-Rahman',
      description: 'Projek pembinaan masjid di kampung terpencil',
      organization: 'Majlis Agama Islam Selangor (MAIS)',
      jakim_verified: true,
      target_amount: 500000,
      current_amount: 325000,
      currency: 'MYR',
      progress_percentage: 65,
      image: '/assets/donations/masjid-ar-rahman.jpg',
      category: 'Pembinaan Masjid',
      end_date: '2025-12-31',
      donation_methods: ['FPX', 'Credit Card', 'QR Pay'],
      tax_deductible: true
    },
    {
      id: 'donation-002',
      title: 'Bantuan Anak Yatim & Asnaf',
      description: 'Program pendidikan dan keperluan asas anak yatim',
      organization: 'Yayasan Al-Ikhlas',
      jakim_verified: true,
      target_amount: 200000,
      current_amount: 145000,
      currency: 'MYR',
      progress_percentage: 72.5,
      image: '/assets/donations/anak-yatim.jpg',
      category: 'Kebajikan',
      recurring_available: true
    },
    {
      id: 'donation-003',
      title: 'Tahfiz & Pendidikan Islam',
      description: 'Biasiswa pelajar tahfiz dan pendidikan Islam',
      organization: 'JAKIM Education Fund',
      jakim_verified: true,
      target_amount: 300000,
      current_amount: 89000,
      currency: 'MYR',
      progress_percentage: 29.6,
      image: '/assets/donations/tahfiz.jpg',
      category: 'Pendidikan',
      zakat_eligible: true
    }
  ];
  
  res.json({
    causes,
    total_causes: causes.length,
    verification_note: 'Semua organisasi telah disahkan oleh JAKIM/JAIS',
    receipt_policy: 'Resit rasmi untuk potongan cukai akan dikeluarkan'
  });
});

// Process donation
router.post('/donate', async (req, res) => {
  try {
    const { user_id, cause_id, amount, payment_method, is_recurring } = req.body;
    
    // In production: integrate with payment gateway (FPX, Stripe, etc.)
    
    const transaction = {
      id: 'txn-' + Date.now(),
      user_id,
      cause_id,
      amount,
      currency: 'MYR',
      payment_method,
      is_recurring,
      status: 'pending',
      created_at: new Date().toISOString(),
      payment_url: 'https://payment.gateway.com/donate/...' // Payment gateway URL
    };
    
    res.json({
      success: true,
      transaction,
      message: 'Jazakallahu khairan atas sumbangan anda',
      receipt_note: 'Resit akan dihantar ke email selepas pembayaran selesai',
      tax_benefit: 'Derma ini layak untuk rebat cukai'
    });
  } catch (error) {
    res.status(500).json({ error: 'Donation failed', details: error.message });
  }
});

// Islamic events calendar
router.get('/events', (req, res) => {
  const events = [
    {
      id: 'event-001',
      title: 'Majlis Ilmu: Fiqh Zakat',
      description: 'Ceramah tentang hukum-hakam zakat oleh Ustaz Dr. Ahmad',
      speaker: 'Ustaz Dr. Ahmad Fahmi',
      date: '2025-10-20T19:30:00Z',
      location: 'Masjid Negara, Kuala Lumpur',
      type: 'Ceramah',
      registration_required: true,
      registration_url: '/events/register/event-001',
      capacity: 500,
      registered: 342,
      jakim_approved: true
    },
    {
      id: 'event-002',
      title: 'Program Tadabbur Al-Quran',
      description: 'Sesi tadabbur mingguan Surah Al-Kahf',
      date: '2025-10-18T20:00:00Z',
      location: 'Online (Zoom)',
      type: 'Tadabbur',
      online: true,
      recurring: 'weekly',
      zoom_link: 'https://zoom.us/j/...'
    }
  ];
  
  res.json({
    events,
    count: events.length,
    note: 'Semua acara telah diluluskan oleh JAKIM/Jabatan Agama'
  });
});

// Report inappropriate content
router.post('/report', async (req, res) => {
  try {
    const { reporter_id, content_id, content_type, reason } = req.body;
    
    const report = {
      id: 'report-' + Date.now(),
      reporter_id,
      content_id,
      content_type,
      reason,
      status: 'pending_review',
      created_at: new Date().toISOString(),
      sla: '48 hours for review'
    };
    
    // In production: notify moderators, flag content
    
    res.json({
      success: true,
      report,
      message: 'Terima kasih. Laporan anda akan disemak oleh pasukan moderasi',
      review_time: 'Dalam 48 jam'
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to submit report', details: error.message });
  }
});

// User profile & badges (gamification)
router.get('/profile/:user_id', async (req, res) => {
  try {
    const { user_id } = req.params;
    
    const profile = {
      user_id,
      name: 'Ahmad bin Hassan',
      avatar: '/avatars/user-123.jpg',
      joined_date: '2024-01-15',
      stats: {
        total_ayah_read: 2856,
        streak_days: 45,
        bookmarks: 78,
        reflections_posted: 12,
        total_donations: 450, // MYR
        videos_watched: 23
      },
      badges: [
        {
          id: 'badge-hafiz-muda',
          name: 'Hafiz Muda',
          description: 'Selesai membaca 10 Juzuk',
          icon: '📖',
          earned_at: '2024-09-10'
        },
        {
          id: 'badge-dermawan',
          name: 'Dermawan',
          description: 'Sumbangan melebihi RM100',
          icon: '💰',
          earned_at: '2024-08-20'
        },
        {
          id: 'badge-istiqamah',
          name: 'Istiqamah 30 Hari',
          description: 'Baca Al-Quran selama 30 hari berturut-turut',
          icon: '⭐',
          earned_at: '2024-10-05'
        }
      ],
      level: 5,
      next_level_progress: 65, // %
      bio: 'Pencinta Al-Quran & Sunnah'
    };
    
    res.json(profile);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch profile', details: error.message });
  }
});

module.exports = router;
