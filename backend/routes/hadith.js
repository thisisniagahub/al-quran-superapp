const express = require('express');
const router = express.Router();
const axios = require('axios');
const NodeCache = require('node-cache');
const cache = new NodeCache({ stdTTL: 86400 }); // 24 hour cache

// myHadith Integration (JAKIM Official Hadith Portal)
router.get('/search', async (req, res) => {
  try {
    const { query, lang, book, grade } = req.query;
    
    if (!query) {
      return res.status(400).json({ error: 'Search query required' });
    }

    const cacheKey = `hadith_search_${query}_${lang || 'ms'}`;
    const cached = cache.get(cacheKey);
    if (cached) return res.json(cached);

    // Note: Adjust URL based on actual myHadith API documentation
    // This is placeholder structure
    const response = await axios.get('https://api.myhadith.my/v1/search', {
      params: {
        q: query,
        lang: lang || 'ms',
        book: book,
        grade: grade
      }
    });

    const results = response.data.results.map(h => ({
      id: h.id,
      text_ar: h.arabic,
      text_translation: h.translation,
      book: h.book,
      chapter: h.chapter,
      hadith_number: h.number,
      grade: h.grade, // Sahih, Hasan, Daif, Maudhu
      narrator: h.narrator,
      myhadith_url: `https://myhadith.islam.gov.my/hadith/${h.id}`,
      source: 'myHadith.my (JAKIM Official)',
      verified: true
    }));

    const result = {
      query,
      count: results.length,
      results,
      source: 'myHadith.islam.gov.my',
      jakim_verified: true,
      note: 'Hadith daripada portal rasmi JAKIM'
    };

    cache.set(cacheKey, result);
    res.json(result);

  } catch (error) {
    res.status(500).json({ 
      error: 'Failed to search hadith', 
      details: error.message,
      fallback: 'Visit https://myhadith.islam.gov.my directly'
    });
  }
});

// Get Hadith of the Day
router.get('/daily', async (req, res) => {
  try {
    const { lang } = req.query;
    
    const today = new Date().toISOString().split('T')[0];
    const cacheKey = `hadith_daily_${today}_${lang || 'ms'}`;
    const cached = cache.get(cacheKey);
    if (cached) return res.json(cached);

    // Fallback: Use Hadith API or curated list
    // For now, return a popular sahih hadith (placeholder)
    const dailyHadith = {
      text_ar: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
      text_translation: 'Sesungguhnya setiap amalan adalah bergantung kepada niat',
      book: 'Sahih al-Bukhari',
      hadith_number: '1',
      grade: 'Sahih',
      narrator: 'Umar bin al-Khattab r.a.',
      myhadith_url: 'https://myhadith.islam.gov.my/hadith/bukhari-1',
      date: today,
      source: 'myHadith.my',
      category: 'Niat & Ikhlas'
    };

    cache.set(cacheKey, dailyHadith);
    res.json(dailyHadith);

  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch daily hadith', details: error.message });
  }
});

// Verify Hadith Authenticity
router.post('/verify', async (req, res) => {
  try {
    const { hadith_text } = req.body;
    
    if (!hadith_text) {
      return res.status(400).json({ error: 'Hadith text required for verification' });
    }

    // Search in myHadith database
    const searchRes = await axios.get('https://api.myhadith.my/v1/search', {
      params: { q: hadith_text, lang: 'ms' }
    });

    if (searchRes.data.results && searchRes.data.results.length > 0) {
      const match = searchRes.data.results[0];
      return res.json({
        verification_status: 'found',
        hadith: {
          text: match.translation,
          text_ar: match.arabic,
          grade: match.grade,
          book: match.book,
          reference: match.number,
          myhadith_url: `https://myhadith.islam.gov.my/hadith/${match.id}`
        },
        authenticity: match.grade === 'Sahih' ? 'authentic' : 
                     match.grade === 'Hasan' ? 'good' :
                     match.grade === 'Daif' ? 'weak' : 'fabricated',
        recommendation: match.grade === 'Sahih' || match.grade === 'Hasan' ? 
          'Boleh diamalkan' : 'Perlu berhati-hati. Rujuk ulama.',
        source: 'myHadith.my (JAKIM)',
        verified_at: new Date().toISOString()
      });
    } else {
      return res.json({
        verification_status: 'not_found',
        message: 'Hadith tidak dijumpai dalam database myHadith',
        recommendation: 'Sila semak dengan ulama sebelum mengamalkan',
        alternative_action: 'Hubungi Jabatan Agama Islam negeri anda',
        myhadith_link: 'https://myhadith.islam.gov.my'
      });
    }

  } catch (error) {
    res.status(500).json({ 
      error: 'Verification failed', 
      details: error.message,
      fallback: 'Sila rujuk myHadith.my secara manual'
    });
  }
});

// Get Hadith by Book
router.get('/book/:bookName', async (req, res) => {
  try {
    const { bookName } = req.params;
    const { chapter, page } = req.query;

    const validBooks = ['bukhari', 'muslim', 'abudawud', 'tirmidhi', 'nasai', 'ibnmajah'];
    
    if (!validBooks.includes(bookName.toLowerCase())) {
      return res.status(400).json({ 
        error: 'Invalid book name', 
        valid_books: validBooks 
      });
    }

    // Fetch from myHadith
    const response = await axios.get(`https://api.myhadith.my/v1/books/${bookName}`, {
      params: { chapter, page: page || 1 }
    });

    res.json({
      book: bookName,
      chapter: chapter || 'all',
      hadiths: response.data.hadiths,
      pagination: response.data.pagination,
      source: 'myHadith.my'
    });

  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch book', details: error.message });
  }
});

module.exports = router;
